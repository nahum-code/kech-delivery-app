"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { useEffect, useState } from "react";
import { fetchMe, logoutRemote, type MeResponse } from "@/lib/api";
import { getAccessToken } from "@/lib/auth-storage";

export default function DashboardPage() {
  const router = useRouter();
  const [me, setMe] = useState<MeResponse | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!getAccessToken()) {
      router.replace("/login");
      return;
    }
    fetchMe()
      .then(setMe)
      .catch((e) => {
        setError(e instanceof Error ? e.message : "Failed to load profile");
      });
  }, [router]);

  async function onLogout() {
    await logoutRemote();
    router.replace("/login");
    router.refresh();
  }

  if (error) {
    return (
      <div className="mx-auto max-w-lg px-6 py-16 text-center">
        <p className="text-red-600 dark:text-red-400">{error}</p>
        <Link href="/login" className="mt-4 inline-block text-sm text-zinc-600 underline">
          Back to login
        </Link>
      </div>
    );
  }

  if (!me) {
    return (
      <div className="flex min-h-full flex-1 items-center justify-center text-zinc-500">
        Loading…
      </div>
    );
  }

  return (
    <div className="mx-auto max-w-lg space-y-6 px-6 py-16">
      <div>
        <h1 className="text-2xl font-semibold text-zinc-900 dark:text-zinc-50">Dashboard</h1>
        <p className="mt-1 text-sm text-zinc-600 dark:text-zinc-400">
          Loaded from <code className="text-xs">GET /api/v1/auth/me</code>
        </p>
      </div>
      <dl className="space-y-2 rounded-xl border border-zinc-200 bg-white p-4 text-sm dark:border-zinc-800 dark:bg-zinc-950">
        <div className="flex justify-between gap-4">
          <dt className="text-zinc-500">Phone</dt>
          <dd className="font-medium text-zinc-900 dark:text-zinc-50">{me.phone}</dd>
        </div>
        <div className="flex justify-between gap-4">
          <dt className="text-zinc-500">Role</dt>
          <dd className="font-medium text-zinc-900 dark:text-zinc-50">{me.role}</dd>
        </div>
        <div className="flex justify-between gap-4">
          <dt className="text-zinc-500">Profile</dt>
          <dd className="text-right text-zinc-800 dark:text-zinc-200">
            <pre className="whitespace-pre-wrap break-all text-xs">{JSON.stringify(me.profile, null, 2)}</pre>
          </dd>
        </div>
      </dl>
      <button
        type="button"
        onClick={() => void onLogout()}
        className="rounded-lg border border-zinc-300 px-4 py-2 text-sm font-medium text-zinc-800 hover:bg-zinc-50 dark:border-zinc-700 dark:text-zinc-200 dark:hover:bg-zinc-900"
      >
        Log out
      </button>
    </div>
  );
}
