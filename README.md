# ccusage-status

Minimal status bar widget for Claude usage. Shows cost and time remaining.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/cole-robertson/ccusage-status/main/install.sh | bash
```

**Requires**: `jq` and `node` (for npx)

## Configure

### Waybar
```json
"custom/ccusage": {
  "format": "󰚩 {text}",
  "return-type": "json",
  "interval": 10,
  "exec": "ccusage-status",
  "tooltip": true
}
```

### Polybar
```ini
[module/ccusage]
type = custom/script
exec = ccusage-status | jq -r '.text'
interval = 10
```

### i3blocks
```
[ccusage]
command=ccusage-status | jq -r '.text'
interval=10
```

## Output

- **Text**: `$12.34 [2h 30m]` (cost + time remaining)
- **Colors**: Green → Yellow (80%) → Red (95%)
- **Tooltip**: Detailed breakdown on hover

## Manual Install

```bash
curl -o ~/.local/bin/ccusage-status https://raw.githubusercontent.com/cole-robertson/ccusage-status/main/ccusage-status
chmod +x ~/.local/bin/ccusage-status
```

That's it! One script, 3KB, no complexity.

## Development

For maintainers only - users don't need this:

```bash
npm install          # Install dev dependencies
npm test            # Run tests
npm run update-version  # Sync version from package.json
```

The ccusage version is managed via `package.json` for automated updates.