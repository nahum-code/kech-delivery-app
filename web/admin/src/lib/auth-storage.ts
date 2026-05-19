const ACCESS_KEY = "kech_admin_access_token";
const REFRESH_KEY = "kech_admin_refresh_token";
const ACCESS_COOKIE = "kech_admin_access_token";
const REFRESH_COOKIE = "kech_admin_refresh_token";

function writeCookie(name: string, value: string, maxAgeSeconds: number): void {
  const secure = typeof window !== "undefined" && window.location.protocol === "https:" ? "; Secure" : "";
  document.cookie = `${name}=${encodeURIComponent(value)}; Path=/; Max-Age=${maxAgeSeconds}; SameSite=Lax${secure}`;
}

function clearCookie(name: string): void {
  const secure = typeof window !== "undefined" && window.location.protocol === "https:" ? "; Secure" : "";
  document.cookie = `${name}=; Path=/; Max-Age=0; SameSite=Lax${secure}`;
}

function readCookie(name: string): string | null {
  if (typeof document === "undefined") return null;
  const prefix = `${name}=`;
  for (const part of document.cookie.split(";")) {
    const trimmed = part.trim();
    if (trimmed.startsWith(prefix)) {
      return decodeURIComponent(trimmed.slice(prefix.length));
    }
  }
  return null;
}

/** Copy cookie tokens into sessionStorage (e.g. after a full page reload). */
export function hydrateSessionFromCookies(): void {
  if (typeof window === "undefined") return;
  const access = readCookie(ACCESS_COOKIE);
  const refresh = readCookie(REFRESH_COOKIE);
  if (access && !sessionStorage.getItem(ACCESS_KEY)) {
    sessionStorage.setItem(ACCESS_KEY, access);
  }
  if (refresh && !sessionStorage.getItem(REFRESH_KEY)) {
    sessionStorage.setItem(REFRESH_KEY, refresh);
  }
}

export function getAccessToken(): string | null {
  if (typeof window === "undefined") return null;
  hydrateSessionFromCookies();
  return sessionStorage.getItem(ACCESS_KEY) || readCookie(ACCESS_COOKIE);
}

export function getRefreshToken(): string | null {
  if (typeof window === "undefined") return null;
  hydrateSessionFromCookies();
  return sessionStorage.getItem(REFRESH_KEY) || readCookie(REFRESH_COOKIE);
}

export function hasClientSession(): boolean {
  return Boolean(getAccessToken());
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
