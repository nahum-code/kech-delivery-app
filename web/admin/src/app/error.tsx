"use client";

export default function ErrorPage({ error }: { error: Error & { digest?: string } }) {
  return (
    <div className="mx-auto max-w-2xl px-6 py-16">
      <h2 className="text-2xl font-semibold text-red-700">Something went wrong</h2>
      <p className="mt-3 text-sm text-gray-600">{error.message || "Unexpected application error."}</p>
    </div>
  );
}
