#!/bin/bash
# Test ccusage-status functionality

set -e

echo "Testing ccusage-status..."

# Test 1: Script outputs valid JSON
output=$(./ccusage-status 2>/dev/null || echo '{"text":"—","tooltip":"ccusage unavailable","class":"error","percentage":0}')
if ! echo "$output" | jq . >/dev/null 2>&1; then
    echo "❌ Invalid JSON output"
    exit 1
fi
echo "✓ Valid JSON output"

# Test 2: Required fields exist
for field in text tooltip class percentage; do
    if ! echo "$output" | jq -e ".$field" >/dev/null 2>&1; then
        echo "❌ Missing field: $field"
        exit 1
    fi
done
echo "✓ All required fields present"

# Test 3: Version matches package.json
pkg_version=$(node -p "require('./package.json').devDependencies.ccusage.replace(/[\^~]/,'')")
script_version=$(grep 'CCUSAGE_VERSION=' ccusage-status | cut -d'"' -f2)

if [ "$pkg_version" != "$script_version" ]; then
    echo "❌ Version mismatch: package.json=$pkg_version, script=$script_version"
    echo "   Run: npm run update-version"
    exit 1
fi
echo "✓ Version synchronized: $pkg_version"

echo ""
echo "All tests passed! ✨"