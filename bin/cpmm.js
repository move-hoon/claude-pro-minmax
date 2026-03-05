#!/usr/bin/env node

const { runCli } = require("../lib/cli");

process.exit(runCli(process.argv.slice(2)));
