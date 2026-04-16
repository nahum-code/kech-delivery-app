const ACCESS_KEY = "kech_sales_access_token";
const REFRESH_KEY = "kech_sales_refresh_token";
const ACCESS_COOKIE = "kech_sales_access_token";
const REFRESH_COOKIE = "kech_sales_refresh_token";

function writeCookie(name: string, value: string, maxAgeSeconds: number): void {
  const secure = typeof window !== "undefined" && window.location.protocol === "https:" ? "; Secure" : "";
  document.cookie = `${name}=${encodeURIComponent(value)}; Path=/; Max-Age=${maxAgeSeconds}; SameSite=Lax${secure}`;
}

function clearCookie(name: string): void {
  const secure = typeof window !== "undefined" && window.location.protocol === "https:" ? "; Secure" : "";
  document.cookie = `${name}=; Path=/; Max-Age=0; SameSite=Lax${secure}`;
}

export function getAccessToken(): string | null {
  if (typeof window === "undefined") return null;
  return sessionStorage.getItem(ACCESS_KEY);
}

export function getRefreshToken(): string | null {
  if (typeof window === "undefined") return null;
  return sessionStorage.getItem(REFRESH_KEY);
}

export function setSessionTokens(access: string, refresh: string | null): void {
  sessionStorage.setItem(ACCESS_KEY, access);
  writeCookie(ACCESS_COOKIE, access, 60 * 60 * 24 * 7);
  if (refresh) sessionStorage.setItem(REFRESH_KEY, refresh);
  if (refresh) writeCookie(REFRESH_COOKIE, refresh, 60 * 60 * 24 * 7);
}

export function clearSession(): void {
  sessionStorage.removeItem(ACCESS_KEY);
  sessionStorage.removeItem(REFRESH_KEY);
  clearCookie(ACCESS_COOKIE);
  clearCookie(REFRESH_COOKIE);
}
