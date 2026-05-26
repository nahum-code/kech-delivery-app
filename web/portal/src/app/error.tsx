"use client";

import { AlertCircle } from "lucide-react";

const BRAND = "#800020";

export default function ErrorPage({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  return (
    <div className="flex min-h-screen items-center justify-center bg-[#f7f6f8] px-4">
      <div className="w-full max-w-md text-center">
        <div
          className="mx-auto mb-6 flex h-16 w-16 items-center justify-center rounded-full"
          style={{ backgroundColor: `${BRAND}10` }}
        >
          <AlertCircle className="h-8 w-8" style={{ color: BRAND }} />
        </div>
        <h1 className="text-2xl font-semibold text-gray-900">Something went wrong</h1>
        <p className="mt-3 text-sm leading-relaxed text-gray-500">
          {error.message || "An unexpected error occurred. Please try again."}
        </p>
        <div className="mt-8 flex items-center justify-center gap-3">
          <button
            onClick={reset}
            className="rounded-lg px-5 py-2.5 text-sm font-medium text-white"
            style={{ backgroundColor: BRAND }}
          >
            Try again
          </button>
          <a
            href="/login"
            className="rounded-lg border border-gray-300 bg-white px-5 py-2.5 text-sm font-medium text-gray-700 hover:bg-gray-50"
          >
            Back to login
          </a>
        </div>
      </div>
    </div>
  );
}
