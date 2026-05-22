"use client";

import { Label } from "../components/ui/label";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "../components/ui/select";
import {
  TIME_HOUR_OPTIONS,
  TIME_MINUTE_OPTIONS,
  time24ToParts,
  partsToTime24,
  type TimeAmPmParts,
} from "@/lib/time-am-pm";

type Props = {
  label: string;
  value: string;
  onChange: (time24: string) => void;
};

export function TimeAmPmPicker({ label, value, onChange }: Props) {
  const parts = time24ToParts(value);

  const update = (patch: Partial<TimeAmPmParts>) => {
    onChange(partsToTime24({ ...parts, ...patch }));
  };

  return (
    <div>
      <Label>{label}</Label>
      <div className="mt-2 grid grid-cols-3 gap-2">
        <Select value={parts.hour} onValueChange={(hour) => update({ hour })}>
          <SelectTrigger>
            <SelectValue placeholder="Hour" />
          </SelectTrigger>
          <SelectContent>
            {TIME_HOUR_OPTIONS.map((h) => (
              <SelectItem key={h} value={h}>
                {h}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
        <Select value={parts.minute} onValueChange={(minute) => update({ minute })}>
          <SelectTrigger>
            <SelectValue placeholder="Min" />
          </SelectTrigger>
          <SelectContent>
            {TIME_MINUTE_OPTIONS.map((m) => (
              <SelectItem key={m} value={m}>
                {m}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
        <Select
          value={parts.period}
          onValueChange={(period) => update({ period: period as TimeAmPmParts["period"] })}
        >
          <SelectTrigger>
            <SelectValue />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="AM">AM</SelectItem>
            <SelectItem value="PM">PM</SelectItem>
          </SelectContent>
        </Select>
      </div>
    </div>
  );
}
