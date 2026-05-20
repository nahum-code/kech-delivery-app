/**
 * Run the Next.js CLI without relying on `node_modules/.bin` shims.
 *
 * On Windows, npm scripts invoke `next` via `%PATH%` + `.bin`; if `.bin`
 * was never linked (broken install, cache restore, tooling), CMD reports
 * "'next' is not recognized..." even when `next` exists under `node_modules/next`.
 */
/* eslint-disable @typescript-eslint/no-require-imports */

const fs = require("fs");
const path = require("path");
const { spawnSync } = require("child_process");

const projectRoot = path.join(__dirname, "..");
const nextCliPath = path.join(
  projectRoot,
  "node_modules",
  "next",
  "dist",
  "bin",
  "next",
);
/** Loaded by Next’s CLI bootstrap; absent when an install/sync was interrupted. */
const nextRequireHook = path.join(
  projectRoot,
  "node_modules",
  "next",
  "dist",
  "server",
  "require-hook.js",
);

if (!fs.existsSync(nextCliPath)) {
  console.error(
    `[next-admin] Missing Next.js CLI:\n  ${nextCliPath}\n` +
      "Install dependencies from this folder: npm ci   (or: npm install)\n",
  );
  process.exit(1);
}

if (!fs.existsSync(nextRequireHook)) {
  console.error(
    "[next-admin] Next.js installation is incomplete or corrupted " +
      "(expected file missing).\n\n" +
      `  Missing:\n    ${nextRequireHook}\n\n` +
      "Repair (PowerShell), from folder web\\admin :\n\n" +
      "  npx --yes rimraf node_modules\n" +
      "  npm ci\n\n" +
      "If deletion fails on Windows (locked files): close terminals/IDE antivirus scan " +
      "on this folder temporarily, retry, then run npm ci again.\n",
  );
  process.exit(1);
}

const result = spawnSync(
  process.execPath,
  [nextCliPath, ...process.argv.slice(2)],
  {
    cwd: projectRoot,
    env: process.env,
    stdio: "inherit",
    shell: false,
  },
);

process.exit(Number.isInteger(result.status) ? result.status : 1);
