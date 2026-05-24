#!/usr/bin/env node
/**
 * Entry point for npm / npx. Delegates to the Bash CLI.
 * Requires: bash (Linux, macOS, Git Bash / WSL on Windows).
 */
'use strict';

const { spawnSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const pkgRoot = path.resolve(__dirname, '..');
const cadehSh = path.join(pkgRoot, 'bin', 'cadeh');

if (!fs.existsSync(cadehSh)) {
  console.error('cadeh: bin/cadeh não encontrado em', pkgRoot);
  process.exit(1);
}

const bash = process.platform === 'win32' ? 'bash' : '/bin/bash';
const args = process.argv.slice(2);

const result = spawnSync(bash, [cadehSh, ...args], {
  stdio: 'inherit',
  env: {
    ...process.env,
    CADEH_PACKAGE_ROOT: pkgRoot,
  },
});

if (result.error) {
  console.error('cadeh:', result.error.message);
  console.error('Instale Bash (WSL ou Git Bash no Windows).');
  process.exit(1);
}

process.exit(result.status === null ? 1 : result.status);
