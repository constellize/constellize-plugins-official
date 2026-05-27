# Constellize Marketplace

Official Constellize methodology plugins for Claude Code.

## Overview

This marketplace provides the complete Constellize methodology as Claude Code plugins:
- **69 Skills** across 5 plugins
- **14 Agents** for expert-in-role consultation

## Installation

Add this marketplace to Claude Code:

```bash
/plugin marketplace add constellize/marketplace
```

Then install individual plugins:

```bash
/plugin install constellize:memory
/plugin install constellize:craft
```

## Available Plugins

| Plugin | Description |
|--------|-------------|
| `constellize:memory` | Knowledge persistence across context resets |
| `constellize:design` | Planning and architecture for software projects |
| `constellize:craft` | Code quality, testing, and continuous excellence |
| `constellize:deliver` | Deployment, operations, and incident management |
| `constellize:grow` | Team learning, system evolution, and adoption |

## Source

Generated from [prompt-factory](https://github.com/constellize/prompt-factory).

## License

MIT
