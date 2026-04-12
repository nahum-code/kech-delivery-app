import Link from "next/link";

export default function Home() {
  return (
    <div className="flex min-h-full flex-1 flex-col items-center justify-center gap-8 px-6 py-24">
      <div className="max-w-md text-center">
        <h1 className="text-3xl font-semibold tracking-tight text-zinc-900 dark:text-zinc-50">
          Kech Delivery Dashboard
        </h1>
        <p className="mt-3 text-zinc-600 dark:text-zinc-400">
          Next.js frontend wired to the Django auth API (JWT, refresh, logout, /me).
        </p>
      </div>
      <div className="flex flex-wrap items-center justify-center gap-4">
        <Link
          href="/login"
          className="rounded-full bg-zinc-900 px-6 py-3 text-sm font-medium text-white hover:bg-zinc-800 dark:bg-zinc-100 dark:text-zinc-900 dark:hover:bg-zinc-200"
        >
          Sign in
        </Link>
        <Link
          href="/dashboard"
          className="rounded-full border border-zinc-300 px-6 py-3 text-sm font-medium text-zinc-800 hover:bg-zinc-50 dark:border-zinc-700 dark:text-zinc-200 dark:hover:bg-zinc-900"
        >
          Open dashboard
        </Link>
      </div>
    </div>
  );
}
