export function formatTime12h(value: string | null | undefined): string {
  if (!value) return "";
  const match = /^(\d{1,2}):(\d{2})/.exec(value);
  if (!match) return value;
  let hour = Number(match[1]);
  const minute = match[2];
  const suffix = hour < 12 ? "AM" : "PM";
  hour = hour % 12 || 12;
  return minute === "00" ? `${hour} ${suffix}` : `${hour}:${minute} ${suffix}`;
}

export function normalizeApiTime(value: string | null | undefined): string {
  if (!value) return "";
  const trimmed = value.trim();
  if (/^\d{2}:\d{2}$/.test(trimmed)) return trimmed;
  const match = /^(\d{2}):(\d{2}):\d{2}$/.exec(trimmed);
  return match ? `${match[1]}:${match[2]}` : trimmed;
}

export function formatHoursRange(opensAt?: string | null, closesAt?: string | null): string {
  const open = formatTime12h(normalizeApiTime(opensAt));
  const close = formatTime12h(normalizeApiTime(closesAt));
  if (!open || !close) return "";
  return `${open} – ${close}`;
}
