const ACCESS_KEY = "kech_access_token";
const REFRESH_KEY = "kech_refresh_token";

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
  if (refresh) sessionStorage.setItem(REFRESH_KEY, refresh);
}

export function clearSession(): void {
  sessionStorage.removeItem(ACCESS_KEY);
  sessionStorage.removeItem(REFRESH_KEY);
}
