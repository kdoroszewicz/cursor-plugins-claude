#!/usr/bin/env node
/**
 * Audit MCP Server
 * 
 * Provides MCP tools for querying and managing audit data.
 */

const { Server } = require('@modelcontextprotocol/sdk/server/index.js');
const { StdioServerTransport } = require('@modelcontextprotocol/sdk/server/stdio.js');
const fs = require('fs');
const path = require('path');

const CONFIG = {
  logPath: process.env.AUDIT_LOG_PATH || './audit.log',
  endpointUrl: process.env.AUDIT_ENDPOINT_URL || process.env.CURSOR_AUDIT_ENDPOINT,
};

const server = new Server(
  {
    name: 'audit-prompt-capture-server',
    version: '1.0.0',
  },
  {
    capabilities: {
      tools: {},
      resources: {},
    },
  }
);

// Register tools
server.setRequestHandler('tools/list', async () => {
  return {
    tools: [
      {
        name: 'get_audit_stats',
        description: 'Get statistics about captured audit events',
        inputSchema: {
          type: 'object',
          properties: {
            since: {
              type: 'string',
              description: 'ISO timestamp to filter events since',
            },
            hookType: {
              type: 'string',
              description: 'Filter by hook type',
            },
          },
        },
      },
      {
        name: 'query_audit_log',
        description: 'Query the local audit log',
        inputSchema: {
          type: 'object',
          properties: {
            limit: {
              type: 'number',
              description: 'Maximum number of events to return',
              default: 100,
            },
            hookType: {
              type: 'string',
              description: 'Filter by hook type',
            },
            sessionId: {
              type: 'string',
              description: 'Filter by session ID',
            },
            since: {
              type: 'string',
              description: 'ISO timestamp to filter events since',
            },
          },
        },
      },
      {
        name: 'export_audit_log',
        description: 'Export audit log to a file',
        inputSchema: {
          type: 'object',
          properties: {
            outputPath: {
              type: 'string',
              description: 'Path to export the audit log to',
            },
            format: {
              type: 'string',
              enum: ['json', 'csv', 'ndjson'],
              description: 'Export format',
              default: 'json',
            },
          },
          required: ['outputPath'],
        },
      },
      {
        name: 'test_endpoint',
        description: 'Test the audit endpoint connectivity',
        inputSchema: {
          type: 'object',
          properties: {
            endpointUrl: {
              type: 'string',
              description: 'Endpoint URL to test (uses configured if not provided)',
            },
          },
        },
      },
    ],
  };
});

// Parse audit log
function parseAuditLog() {
  const logPath = path.resolve(CONFIG.logPath);
  if (!fs.existsSync(logPath)) {
    return [];
  }
  
  const content = fs.readFileSync(logPath, 'utf-8');
  const lines = content.trim().split('\n').filter(Boolean);
  
  return lines.map(line => {
    try {
      return JSON.parse(line);
    } catch {
      return null;
    }
  }).filter(Boolean);
}

// Handle tool calls
server.setRequestHandler('tools/call', async (request) => {
  const { name, arguments: args } = request.params;
  
  switch (name) {
    case 'get_audit_stats': {
      const events = parseAuditLog();
      const filtered = events.filter(e => {
        if (args?.since && new Date(e.timestamp) < new Date(args.since)) return false;
        if (args?.hookType && e.hookType !== args.hookType) return false;
        return true;
      });
      
      const stats = {
        totalEvents: filtered.length,
        byHookType: {},
        byCategory: {},
        sessions: new Set(),
        timeRange: {
          earliest: null,
          latest: null,
        },
      };
      
      filtered.forEach(e => {
        stats.byHookType[e.hookType] = (stats.byHookType[e.hookType] || 0) + 1;
        stats.byCategory[e.category] = (stats.byCategory[e.category] || 0) + 1;
        stats.sessions.add(e.sessionId);
        
        const ts = new Date(e.timestamp);
        if (!stats.timeRange.earliest || ts < new Date(stats.timeRange.earliest)) {
          stats.timeRange.earliest = e.timestamp;
        }
        if (!stats.timeRange.latest || ts > new Date(stats.timeRange.latest)) {
          stats.timeRange.latest = e.timestamp;
        }
      });
      
      stats.uniqueSessions = stats.sessions.size;
      delete stats.sessions;
      
      return {
        content: [{ type: 'text', text: JSON.stringify(stats, null, 2) }],
      };
    }
    
    case 'query_audit_log': {
      const events = parseAuditLog();
      let filtered = events.filter(e => {
        if (args?.since && new Date(e.timestamp) < new Date(args.since)) return false;
        if (args?.hookType && e.hookType !== args.hookType) return false;
        if (args?.sessionId && e.sessionId !== args.sessionId) return false;
        return true;
      });
      
      // Sort by timestamp descending (most recent first)
      filtered.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));
      
      // Apply limit
      const limit = args?.limit || 100;
      filtered = filtered.slice(0, limit);
      
      return {
        content: [{ type: 'text', text: JSON.stringify(filtered, null, 2) }],
      };
    }
    
    case 'export_audit_log': {
      const events = parseAuditLog();
      const format = args?.format || 'json';
      const outputPath = path.resolve(args.outputPath);
      
      let content;
      switch (format) {
        case 'json':
          content = JSON.stringify(events, null, 2);
          break;
        case 'ndjson':
          content = events.map(e => JSON.stringify(e)).join('\n');
          break;
        case 'csv': {
          if (events.length === 0) {
            content = '';
          } else {
            const headers = ['id', 'timestamp', 'hookType', 'category', 'sessionId'];
            const rows = events.map(e => 
              headers.map(h => JSON.stringify(e[h] || '')).join(',')
            );
            content = [headers.join(','), ...rows].join('\n');
          }
          break;
        }
      }
      
      fs.writeFileSync(outputPath, content);
      
      return {
        content: [{ 
          type: 'text', 
          text: `Exported ${events.length} events to ${outputPath} in ${format} format` 
        }],
      };
    }
    
    case 'test_endpoint': {
      const endpointUrl = args?.endpointUrl || CONFIG.endpointUrl;
      
      if (!endpointUrl) {
        return {
          content: [{ 
            type: 'text', 
            text: 'Error: No endpoint URL configured. Set AUDIT_ENDPOINT_URL environment variable.' 
          }],
        };
      }
      
      try {
        const url = new URL(endpointUrl);
        const isHttps = url.protocol === 'https:';
        const client = isHttps ? require('https') : require('http');
        
        return new Promise((resolve) => {
          const testPayload = JSON.stringify({
            type: 'test',
            timestamp: new Date().toISOString(),
          });
          
          const req = client.request({
            hostname: url.hostname,
            port: url.port || (isHttps ? 443 : 80),
            path: url.pathname,
            method: 'POST',
            timeout: 5000,
            headers: {
              'Content-Type': 'application/json',
              'Content-Length': Buffer.byteLength(testPayload),
            },
          }, (res) => {
            resolve({
              content: [{ 
                type: 'text', 
                text: `Endpoint test result: ${res.statusCode} ${res.statusMessage}\nURL: ${endpointUrl}` 
              }],
            });
          });
          
          req.on('error', (error) => {
            resolve({
              content: [{ 
                type: 'text', 
                text: `Endpoint test failed: ${error.message}\nURL: ${endpointUrl}` 
              }],
            });
          });
          
          req.on('timeout', () => {
            req.destroy();
            resolve({
              content: [{ 
                type: 'text', 
                text: `Endpoint test timed out\nURL: ${endpointUrl}` 
              }],
            });
          });
          
          req.write(testPayload);
          req.end();
        });
      } catch (error) {
        return {
          content: [{ 
            type: 'text', 
            text: `Invalid endpoint URL: ${error.message}` 
          }],
        };
      }
    }
    
    default:
      throw new Error(`Unknown tool: ${name}`);
  }
});

// Start server
async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error('Audit MCP server running on stdio');
}

main().catch(console.error);
