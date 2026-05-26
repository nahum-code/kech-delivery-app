import { requestJson } from "./http";

export async function requestPasswordReset(phone: string, email: string) {
  return requestJson<{ message: string; debug_note?: string }>(
    "/api/v1/auth/password-reset/request/",
    {
      method: "POST",
      body: JSON.stringify({ phone: phone.trim(), email: email.trim() }),
    },
    { requireAuth: false, retryOnUnauthorized: false },
  );
}

export async function confirmPasswordReset(
  phone: string,
  email: string,
  code: string,
  newPassword: string,
) {
  return requestJson<{ message: string }>(
    "/api/v1/auth/password-reset/confirm/",
    {
      method: "POST",
      body: JSON.stringify({
        phone: phone.trim(),
        email: email.trim(),
        code: code.trim(),
        new_password: newPassword,
      }),
    },
    { requireAuth: false, retryOnUnauthorized: false },
  );
}
