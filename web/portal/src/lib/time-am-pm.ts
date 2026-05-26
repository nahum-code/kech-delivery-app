export type TimeAmPmParts = {
  hour: string;
  minute: string;
  period: "AM" | "PM";
};

export const TIME_HOUR_OPTIONS = Array.from({ length: 12 }, (_, i) =>
  String(i + 1).padStart(2, "0"),
);

export const TIME_MINUTE_OPTIONS = Array.from({ length: 60 }, (_, i) =>
  String(i).padStart(2, "0"),
);

export function time24ToParts(time24: string): TimeAmPmParts {
  const [hStr = "12", mStr = "00"] = time24.split(":");
  let h = parseInt(hStr, 10);
  const period: "AM" | "PM" = h >= 12 ? "PM" : "AM";
  if (h === 0) h = 12;
  else if (h > 12) h -= 12;
  return {
    hour: String(h).padStart(2, "0"),
    minute: mStr.padStart(2, "0"),
    period,
  };
}

export function partsToTime24(parts: TimeAmPmParts): string {
  let h = parseInt(parts.hour, 10);
  if (parts.period === "AM" && h === 12) h = 0;
  else if (parts.period === "PM" && h !== 12) h += 12;
  return `${String(h).padStart(2, "0")}:${parts.minute}`;
}
