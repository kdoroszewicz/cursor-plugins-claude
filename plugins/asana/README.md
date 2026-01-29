# Asana Plugin

Asana MCP server integration for task and project management.

## Installation

```bash
agent install asana
```

## Configuration

This plugin requires an Asana Personal Access Token to authenticate with the Asana API.

### Getting an Access Token

1. Go to [Asana Developer Console](https://app.asana.com/0/developer-console)
2. Click **Create new token**
3. Give your token a descriptive name
4. Copy the generated token

### Setting the Environment Variable

Set the `ASANA_ACCESS_TOKEN` environment variable with your token:

```bash
export ASANA_ACCESS_TOKEN="your-token-here"
```

Or add it to your shell profile (`.bashrc`, `.zshrc`, etc.):

```bash
echo 'export ASANA_ACCESS_TOKEN="your-token-here"' >> ~/.bashrc
```

## MCP Server

This plugin provides the official [Asana MCP server](https://github.com/Asana/asana-mcp-server) which enables:

- Creating, updating, and searching tasks
- Managing projects and sections
- Accessing workspaces and teams
- Working with comments and attachments

## Resources

- [Asana MCP Server Documentation](https://developers.asana.com/docs/using-asanas-mcp-server)
- [Asana API Documentation](https://developers.asana.com/docs)
- [Asana MCP Server GitHub](https://github.com/Asana/asana-mcp-server)

## License

MIT
