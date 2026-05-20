"use client";

import { useEffect, useState } from "react";
import { clearSession, hasClientSession } from "@/lib/auth-storage";
import { fetchMe, logoutRemote, type MeResponse } from "@/services/auth";

export function useAuthGuard() {
  // Keep SSR and first client paint identical; auth is resolved in useEffect only.
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [user, setUser] = useState<MeResponse | null>(null);

  useEffect(() => {
    let mounted = true;

    if (!hasClientSession()) {
      clearSession();
      // eslint-disable-next-line react-hooks/set-state-in-effect
      setError("Not signed in");
      setLoading(false);
      return () => {
        mounted = false;
      };
    }

    fetchMe()
      .then((me) => {
        if (!mounted) return;
        setUser(me);
      })
      .catch((e) => {
        if (!mounted) return;
        clearSession();
        setError(e instanceof Error ? e.message : "Authentication failed");
      })
      .finally(() => {
        if (!mounted) return;
        setLoading(false);
      });

    return () => {
      mounted = false;
    };
  }, []);

  return {
    loading,
    error,
    user,
    logout: logoutRemote,
  };
}
