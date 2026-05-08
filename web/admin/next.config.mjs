import { createRequire } from "module";
import { dirname } from "path";
import { fileURLToPath } from "url";

/** @next/env is CJS — named `import {}` breaks when Next evaluates `next.config.mjs`. */
const require = createRequire(import.meta.url);
const { loadEnvConfig } = require("@next/env");

const rootDir = dirname(fileURLToPath(import.meta.url));

// Ensure `.env*` are merged into `process.env` before we read `NEXT_PUBLIC_*` here.
// Some Turbopack dev setups were not inlining `NEXT_PUBLIC_API_URL` into client chunks
// even though the dev banner listed `.env.local`; loading explicitly + `env` below fixes that.
loadEnvConfig(rootDir);

const publicApiUrl = process.env.NEXT_PUBLIC_API_URL?.trim() ?? "";

const nextConfig = {
	turbopack: {
		root: rootDir,
	},
	env: {
		NEXT_PUBLIC_API_URL: publicApiUrl,
	},
};

export default nextConfig;
