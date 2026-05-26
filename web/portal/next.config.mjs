import { createRequire } from "module";
import { dirname } from "path";
import { fileURLToPath } from "url";

const require = createRequire(import.meta.url);
const { loadEnvConfig } = require("@next/env");

const rootDir = dirname(fileURLToPath(import.meta.url));

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
