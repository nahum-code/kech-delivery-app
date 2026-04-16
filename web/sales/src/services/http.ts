import { getAccessToken } from "@/lib/auth-storage";

export function getApiBase(): string {
  const base = process.env.NEXT_PUBLIC_API_URL;
  if (!base) {
    throw new Error("NEXT_PUBLIC_API_URL is not set (e.g. http://127.0.0.1:8000)");
  }
  return base.replace(/\/$/, "");
}

export async function authJson<T>(path: string, init: RequestInit = {}): Promise<T> {
  const token = getAccessToken();
  const headers = new Headers(init.headers || {});
  headers.set("Content-Type", "application/json");
  if (token) headers.set("Authorization", `Bearer ${token}`);

  const res = await fetch(`${getApiBase()}${path}`, { ...init, headers });
  if (!res.ok) {
    const body = await res.text();
    throw new Error(body || `Request failed (${res.status})`);
  }
  return (await res.json()) as T;
}
