// Login UI lives in `src/app/login` (shared implementation). This file wires it into
// the root `app/` tree so `/login` resolves — middleware redirects here when unauthenticated.
export { default } from "../../src/app/login/page";
