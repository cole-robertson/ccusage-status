#!/bin/bash

# Auto-setup ccusage-status for waybar

WAYBAR_CONFIG="$HOME/.config/waybar/config.jsonc"
WAYBAR_CONFIG_ALT="$HOME/.config/waybar/config.json"
WAYBAR_CONFIG_ALT2="$HOME/.config/waybar/config"

# Find the waybar config file
if [ -f "$WAYBAR_CONFIG" ]; then
    CONFIG_FILE="$WAYBAR_CONFIG"
elif [ -f "$WAYBAR_CONFIG_ALT" ]; then
    CONFIG_FILE="$WAYBAR_CONFIG_ALT"
elif [ -f "$WAYBAR_CONFIG_ALT2" ]; then
    CONFIG_FILE="$WAYBAR_CONFIG_ALT2"
else
    echo "❌ No waybar config found. Please create one first."
    exit 1
fi

echo "Found waybar config at: $CONFIG_FILE"

# Check if ccusage is already configured
if grep -q '"custom/ccusage"' "$CONFIG_FILE"; then
    echo "✓ ccusage-status is already configured in waybar!"
    exit 0
fi

# Create backup
BACKUP_FILE="${CONFIG_FILE}.bak.$(date +%Y%m%d_%H%M%S)"
cp "$CONFIG_FILE" "$BACKUP_FILE"
echo "Created backup: $BACKUP_FILE"

# Use jq to add the module if the config is valid JSON
if command -v jq &> /dev/null && jq . "$CONFIG_FILE" &> /dev/null; then
    # Valid JSON, use jq to modify it
    TMP_FILE=$(mktemp)
    
    # Add to modules-right if it exists, otherwise modules-left
    jq '
    # Add ccusage module definition
    . += {
        "custom/ccusage": {
            "format": "󰚩 {text}",
            "return-type": "json",
            "interval": 10,
            "exec": "ccusage-status",
            "tooltip": true
        }
    } |
    # Add to modules array
    if ."modules-right" then
        ."modules-right" = (["custom/ccusage"] + ."modules-right")
    elif ."modules-left" then
        ."modules-left" = (."modules-left" + ["custom/ccusage"])
    elif .modules then
        .modules = (.modules + ["custom/ccusage"])
    else
        . += {"modules-right": ["custom/ccusage"]}
    end
    ' "$CONFIG_FILE" > "$TMP_FILE"
    
    if [ $? -eq 0 ]; then
        mv "$TMP_FILE" "$CONFIG_FILE"
        echo "✓ Successfully added ccusage-status to waybar config!"
        echo ""
        echo "You may need to reload waybar:"
        echo "  killall -SIGUSR2 waybar"
        echo ""
        echo "Or restart waybar:"
        echo "  killall waybar && waybar &"
    else
        echo "❌ Failed to modify config with jq"
        rm -f "$TMP_FILE"
        exit 1
    fi
else
    # Fallback: manual text manipulation for JSONC or invalid JSON
    echo "⚠️  jq not available or config is JSONC. Using text manipulation..."
    
    # Find where to insert the module
    if grep -q "modules-right" "$CONFIG_FILE"; then
        # Add after modules-right
        sed -i '/modules-right.*\[/,/\]/{/\[/a\    "custom/ccusage",
        }' "$CONFIG_FILE"
    elif grep -q "modules-left" "$CONFIG_FILE"; then
        # Add before the last item in modules-left
        sed -i '/modules-left.*\[/,/\]/{/\]/i\    ,"custom/ccusage"
        }' "$CONFIG_FILE"
    else
        echo "❌ Could not find modules section in config"
        exit 1
    fi
    
    # Add the module definition before the last closing brace
    cat >> "$CONFIG_FILE" << 'EOF'
  ,
  "custom/ccusage": {
    "format": "󰚩 {text}",
    "return-type": "json",
    "interval": 10,
    "exec": "ccusage-status",
    "tooltip": true
  }
EOF
    
    # Fix the JSON by removing the last comma if needed
    sed -i ':a;N;$!ba;s/,\n}$/\n}/g' "$CONFIG_FILE"
    
    echo "✓ Added ccusage-status to waybar config!"
    echo ""
    echo "Please verify the config is valid and reload waybar:"
    echo "  killall -SIGUSR2 waybar"
fi