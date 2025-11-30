# Relay Agent

Backend agent for the Relay VPS Operations Platform.

## Setup

1. Install Node.js dependencies:

```bash
npm install
```

2. Install Python dependencies for plugins:

```bash
pip install -r requirements.txt
```

3. (Optional) Install global npm packages for JavaScript plugins:

```bash
npm install -g <package-name>
```

4. Create a `.env` file (copy from `sample.env`):

```bash
cp sample.env .env
```

5. Edit `.env` and set your `AGENT_SECRET`

6. Start the server:

```bash
npm start
```

## API Endpoints

### GET /api/status

Returns the status and all plugin data.

**Authentication**: Requires `x-agent-secret` header matching `AGENT_SECRET`.

**Response**:

```json
{
  "status": "alive",
  "data": [
    {
      "title": "CPU",
      "widgets": [...]
    }
  ]
}
```

## Plugins

Place executable scripts (.py, .sh, .js) in the `plugins/` directory. Each plugin should output JSON to stdout in the following format:

```json
{
  "title": "Plugin Name",
  "widgets": [
    {
      "type": "metric_card",
      "data": {
        "label": "Metric Label",
        "value": "Metric Value",
        "status": "success|warning|error"
      }
    }
  ]
}
```

### Plugin Dependencies

- **Python plugins**: Add dependencies to `requirements.txt`
- **Shell plugins**: Use system commands (no dependencies)
- **JavaScript plugins**: Install packages globally with `npm install -g <package>`

## Environment Variables

- `PORT` - Server port (default: 3000)
- `AGENT_SECRET` - Required authentication secret
