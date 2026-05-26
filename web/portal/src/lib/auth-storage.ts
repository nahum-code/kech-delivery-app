const ACCESS_KEY = "kech_portal_access_token";
const REFRESH_KEY = "kech_portal_refresh_token";
const ROLE_KEY = "kech_portal_role";
const ACCESS_COOKIE = "kech_portal_access_token";
const REFRESH_COOKIE = "kech_portal_refresh_token";
const ROLE_COOKIE = "kech_portal_role";

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

export function hydrateSessionFromCookies(): void {
  if (typeof window === "undefined") return;
  const access = readCookie(ACCESS_COOKIE);
  const refresh = readCookie(REFRESH_COOKIE);
  const role = readCookie(ROLE_COOKIE);
  if (access && !sessionStorage.getItem(ACCESS_KEY)) {
    sessionStorage.setItem(ACCESS_KEY, access);
  }
  if (refresh && !sessionStorage.getItem(REFRESH_KEY)) {
    sessionStorage.setItem(REFRESH_KEY, refresh);
  }
  if (role && !sessionStorage.getItem(ROLE_KEY)) {
    sessionStorage.setItem(ROLE_KEY, role);
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

export function getRole(): string | null {
  if (typeof window === "undefined") return null;
  hydrateSessionFromCookies();
  return sessionStorage.getItem(ROLE_KEY) || readCookie(ROLE_COOKIE);
}

export function hasClientSession(): boolean {
  return Boolean(getAccessToken());
}

export function setSessionTokens(access: string, refresh: string | null, role: string): void {
  const maxAge = 60 * 60 * 24 * 7;
  sessionStorage.setItem(ACCESS_KEY, access);
  sessionStorage.setItem(ROLE_KEY, role);
  writeCookie(ACCESS_COOKIE, access, maxAge);
  writeCookie(ROLE_COOKIE, role, maxAge);
  if (refresh) {
    sessionStorage.setItem(REFRESH_KEY, refresh);
    writeCookie(REFRESH_COOKIE, refresh, maxAge);
  }
}

export function clearSession(): void {
  sessionStorage.removeItem(ACCESS_KEY);
  sessionStorage.removeItem(REFRESH_KEY);
  sessionStorage.removeItem(ROLE_KEY);
  clearCookie(ACCESS_COOKIE);
  clearCookie(REFRESH_COOKIE);
  clearCookie(ROLE_COOKIE);
}
