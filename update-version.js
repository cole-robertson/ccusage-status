#!/usr/bin/env node
// Update ccusage version in shell script from package.json

const fs = require('fs');
const pkg = require('./package.json');

const ccusageVersion = pkg.devDependencies.ccusage.replace(/[\^~]/, '');
const scriptPath = './ccusage-status';

let script = fs.readFileSync(scriptPath, 'utf8');
script = script.replace(
  /CCUSAGE_VERSION="[\d.]+"/,
  `CCUSAGE_VERSION="${ccusageVersion}"`
);

fs.writeFileSync(scriptPath, script);
console.log(`Updated ccusage version to ${ccusageVersion}`);