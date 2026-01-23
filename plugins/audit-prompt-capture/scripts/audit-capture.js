#!/usr/bin/env node
/**
 * Audit Capture Script
 * 
 * Captures prompt data from Cursor hooks and sends to a configurable audit endpoint.
 * 
 * Environment Variables:
 *   AUDIT_ENDPOINT_URL - The URL to send audit data to (required)
 *   AUDIT_API_KEY      - API key for authentication (optional)
 *   AUDIT_LOG_LOCAL    - Also log to local file (default: false)
 *   AUDIT_LOG_PATH     - Path for local audit log (default: ./audit.log)
 *   AUDIT_BATCH_SIZE   - Number of events to batch before sending (default: 1)
 *   AUDIT_TIMEOUT_MS   - Request timeout in milliseconds (default: 5000)
 *   AUDIT_RETRY_COUNT  - Number of retries on failure (default: 3)
 *   AUDIT_INCLUDE_CONTENT - Include full content in audit (default: true)
 *   AUDIT_ANONYMIZE    - Anonymize sensitive data (default: false)
 */

const https = require('https');
const http = require('http');
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

// Configuration from environment
const CONFIG = {
  endpointUrl: process.env.AUDIT_ENDPOINT_URL || process.env.CURSOR_AUDIT_ENDPOINT,
  apiKey: process.env.AUDIT_API_KEY || process.env.CURSOR_AUDIT_API_KEY,
  logLocal: process.env.AUDIT_LOG_LOCAL === 'true',
  logPath: process.env.AUDIT_LOG_PATH || './audit.log',
  batchSize: parseInt(process.env.AUDIT_BATCH_SIZE || '1', 10),
  timeoutMs: parseInt(process.env.AUDIT_TIMEOUT_MS || '5000', 10),
  retryCount: parseInt(process.env.AUDIT_RETRY_COUNT || '3', 10),
  includeContent: process.env.AUDIT_INCLUDE_CONTENT !== 'false',
  anonymize: process.env.AUDIT_ANONYMIZE === 'true',
};

// Hook type from command line argument
const hookType = process.argv[2] || process.env.AUDIT_HOOK_TYPE || 'unknown';

/**
 * Generate a unique event ID
 */
function generateEventId() {
  return `evt_${Date.now()}_${crypto.randomBytes(8).toString('hex')}`;
}

/**
 * Get session ID from environment or generate one
 */
function getSessionId() {
  return process.env.CURSOR_SESSION_ID || 
         process.env.SESSION_ID || 
         `session_${crypto.randomBytes(4).toString('hex')}`;
}

/**
 * Anonymize potentially sensitive data
 */
function anonymizeData(data) {
  if (!CONFIG.anonymize || !data) return data;
  
  const sensitivePatterns = [
    // API keys
    /([a-zA-Z0-9_-]*(?:key|token|secret|password|api)[a-zA-Z0-9_-]*\s*[=:]\s*)(['"]?)([^'"\s]+)\2/gi,
    // Email addresses
    /[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/g,
    // IP addresses
    /\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b/g,
    // UUIDs
    /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/gi,
  ];
  
  let result = typeof data === 'string' ? data : JSON.stringify(data);
  
  sensitivePatterns.forEach((pattern, index) => {
    result = result.replace(pattern, `[REDACTED_${index}]`);
  });
  
  return typeof data === 'string' ? result : JSON.parse(result);
}

/**
 * Read input from stdin
 */
async function readStdin() {
  return new Promise((resolve) => {
    let data = '';
    
    // Set a timeout in case stdin is empty
    const timeout = setTimeout(() => {
      resolve(data || null);
    }, 100);
    
    process.stdin.setEncoding('utf8');
    process.stdin.on('readable', () => {
      let chunk;
      while ((chunk = process.stdin.read()) !== null) {
        data += chunk;
      }
    });
    
    process.stdin.on('end', () => {
      clearTimeout(timeout);
      resolve(data || null);
    });
    
    process.stdin.on('error', () => {
      clearTimeout(timeout);
      resolve(null);
    });
    
    // Resume stdin to trigger data flow
    process.stdin.resume();
  });
}

/**
 * Parse hook payload from stdin or environment
 */
async function parseHookPayload() {
  // Try reading from stdin first (Cursor may pipe data)
  const stdinData = await readStdin();
  
  if (stdinData) {
    try {
      return JSON.parse(stdinData);
    } catch {
      // If not JSON, treat as raw content
      return { rawContent: stdinData };
    }
  }
  
  // Fall back to environment variables
  const payload = {};
  
  // Common Cursor hook environment variables
  const envMappings = {
    CURSOR_PROMPT: 'prompt',
    CURSOR_RESPONSE: 'response',
    CURSOR_MODEL: 'model',
    CURSOR_USER_ID: 'userId',
    CURSOR_WORKSPACE: 'workspace',
    CURSOR_FILE_PATH: 'filePath',
    CURSOR_FILE_CONTENT: 'fileContent',
    CURSOR_COMMAND: 'command',
    CURSOR_COMMAND_OUTPUT: 'commandOutput',
    CURSOR_TOOL_NAME: 'toolName',
    CURSOR_TOOL_INPUT: 'toolInput',
    CURSOR_TOOL_OUTPUT: 'toolOutput',
    CURSOR_CONTEXT_TYPE: 'contextType',
    CURSOR_CONTEXT_VALUE: 'contextValue',
    CURSOR_ERROR_MESSAGE: 'errorMessage',
    CURSOR_ERROR_STACK: 'errorStack',
    CURSOR_PREVIOUS_MODEL: 'previousModel',
    CURSOR_NEW_MODEL: 'newModel',
  };
  
  for (const [envVar, key] of Object.entries(envMappings)) {
    if (process.env[envVar]) {
      payload[key] = process.env[envVar];
    }
  }
  
  return Object.keys(payload).length > 0 ? payload : null;
}

/**
 * Build audit event
 */
function buildAuditEvent(hookType, payload) {
  const event = {
    id: generateEventId(),
    timestamp: new Date().toISOString(),
    timestampUnix: Date.now(),
    hookType: hookType,
    sessionId: getSessionId(),
    metadata: {
      hostname: process.env.HOSTNAME || require('os').hostname(),
      platform: process.platform,
      nodeVersion: process.version,
      workingDirectory: process.cwd(),
      user: process.env.USER || process.env.USERNAME,
    },
  };
  
  // Add payload data based on hook type
  if (payload && CONFIG.includeContent) {
    event.payload = CONFIG.anonymize ? anonymizeData(payload) : payload;
  } else if (payload) {
    // Include metadata about payload without full content
    event.payload = {
      hasContent: true,
      contentType: typeof payload,
      contentLength: JSON.stringify(payload).length,
    };
  }
  
  // Add hook-specific metadata
  switch (hookType) {
    case 'pre-prompt':
    case 'post-prompt':
      event.category = 'prompt';
      break;
    case 'pre-response':
    case 'post-response':
      event.category = 'response';
      break;
    case 'pre-tool-call':
    case 'post-tool-call':
      event.category = 'tool';
      break;
    case 'pre-file-edit':
    case 'post-file-edit':
      event.category = 'file';
      break;
    case 'pre-command':
    case 'post-command':
      event.category = 'command';
      break;
    case 'session-start':
    case 'session-end':
      event.category = 'session';
      break;
    case 'context-attach':
      event.category = 'context';
      break;
    case 'model-switch':
      event.category = 'model';
      break;
    case 'error':
      event.category = 'error';
      break;
    default:
      event.category = 'other';
  }
  
  return event;
}

/**
 * Send event to audit endpoint
 */
async function sendToEndpoint(event, retryCount = 0) {
  if (!CONFIG.endpointUrl) {
    console.error('[Audit] No endpoint URL configured. Set AUDIT_ENDPOINT_URL environment variable.');
    return false;
  }
  
  const url = new URL(CONFIG.endpointUrl);
  const isHttps = url.protocol === 'https:';
  const client = isHttps ? https : http;
  
  const payload = JSON.stringify(event);
  
  const options = {
    hostname: url.hostname,
    port: url.port || (isHttps ? 443 : 80),
    path: url.pathname + url.search,
    method: 'POST',
    timeout: CONFIG.timeoutMs,
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(payload),
      'User-Agent': 'CursorAuditPlugin/1.0.0',
      'X-Audit-Event-Id': event.id,
      'X-Audit-Hook-Type': event.hookType,
      'X-Audit-Session-Id': event.sessionId,
    },
  };
  
  // Add API key if configured
  if (CONFIG.apiKey) {
    options.headers['Authorization'] = `Bearer ${CONFIG.apiKey}`;
    options.headers['X-API-Key'] = CONFIG.apiKey;
  }
  
  return new Promise((resolve) => {
    const req = client.request(options, (res) => {
      let responseData = '';
      res.on('data', (chunk) => { responseData += chunk; });
      res.on('end', () => {
        if (res.statusCode >= 200 && res.statusCode < 300) {
          resolve(true);
        } else {
          console.error(`[Audit] Endpoint returned status ${res.statusCode}: ${responseData}`);
          resolve(false);
        }
      });
    });
    
    req.on('error', async (error) => {
      console.error(`[Audit] Request error: ${error.message}`);
      if (retryCount < CONFIG.retryCount) {
        // Exponential backoff
        const delay = Math.pow(2, retryCount) * 1000;
        await new Promise(r => setTimeout(r, delay));
        resolve(await sendToEndpoint(event, retryCount + 1));
      } else {
        resolve(false);
      }
    });
    
    req.on('timeout', () => {
      req.destroy();
      console.error('[Audit] Request timed out');
      resolve(false);
    });
    
    req.write(payload);
    req.end();
  });
}

/**
 * Log event locally
 */
function logLocally(event) {
  if (!CONFIG.logLocal) return;
  
  try {
    const logLine = JSON.stringify(event) + '\n';
    const logPath = path.resolve(CONFIG.logPath);
    fs.appendFileSync(logPath, logLine);
  } catch (error) {
    console.error(`[Audit] Failed to write local log: ${error.message}`);
  }
}

/**
 * Main execution
 */
async function main() {
  try {
    // Parse the hook payload
    const payload = await parseHookPayload();
    
    // Build the audit event
    const event = buildAuditEvent(hookType, payload);
    
    // Log locally if configured
    logLocally(event);
    
    // Send to endpoint
    const success = await sendToEndpoint(event);
    
    if (!success && !CONFIG.logLocal) {
      // If sending failed and no local log, exit with error
      process.exit(1);
    }
    
    // Exit successfully
    process.exit(0);
  } catch (error) {
    console.error(`[Audit] Fatal error: ${error.message}`);
    process.exit(1);
  }
}

// Run main function
main();
