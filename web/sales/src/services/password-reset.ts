import { getApiBase } from "./http";

export async function requestPasswordReset(phone: string, email: string) {
  const res = await fetch(`${getApiBase()}/api/v1/auth/password-reset/request/`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ phone: phone.trim(), email: email.trim() }),
  });
  const data = await res.json().catch(() => ({}));
  if (!res.ok) {
    const detail =
      typeof data === "object" && data && "detail" in data
        ? String((data as { detail: unknown }).detail)
        : "Request failed";
    throw new Error(detail);
  }
  return data as { message: string; debug_note?: string };
}

export async function confirmPasswordReset(
  phone: string,
  email: string,
  code: string,
  newPassword: string,
) {
  const res = await fetch(`${getApiBase()}/api/v1/auth/password-reset/confirm/`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      phone: phone.trim(),
      email: email.trim(),
      code: code.trim(),
      new_password: newPassword,
    }),
  });
  const data = await res.json().catch(() => ({}));
  if (!res.ok) {
    const detail =
      typeof data === "object" && data && "detail" in data
        ? String((data as { detail: unknown }).detail)
        : "Reset failed";
    throw new Error(detail);
  }
  return data as { message: string };
}
