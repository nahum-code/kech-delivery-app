"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { useState } from "react";
import { Eye, EyeOff, Loader2, Lock, Phone, Shield } from "lucide-react";

import { loginWithPhone } from "@/lib/api";
import { Alert, AlertDescription } from "@/features/admin/components/ui/alert";
import { Button } from "@/features/admin/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/features/admin/components/ui/card";
import { Input } from "@/features/admin/components/ui/input";
import { Label } from "@/features/admin/components/ui/label";

const BRAND = "#800020";
const BRAND_DARK = "#600018";

export default function LoginPage() {
  const router = useRouter();
  const [phone, setPhone] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    setLoading(true);
    try {
      await loginWithPhone(phone.trim(), password);
      router.push("/dashboard");
      router.refresh();
    } catch (err) {
      setError(err instanceof Error ? err.message : "Login failed");
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="flex min-h-screen flex-col lg:flex-row">
      <section
        className="relative hidden flex-col justify-between overflow-hidden px-10 py-12 text-white lg:flex lg:w-[44%] xl:w-[42%]"
        style={{
          background: `linear-gradient(145deg, ${BRAND_DARK} 0%, ${BRAND} 42%, #9a3d5c 100%)`,
        }}
      >
        <div className="pointer-events-none absolute -right-24 -top-24 h-72 w-72 rounded-full bg-white/10 blur-3xl" />
        <div className="relative z-10">
          <div className="inline-flex items-center gap-3 rounded-2xl bg-white/10 px-4 py-3 backdrop-blur-sm">
            <span
              className="flex h-11 w-11 items-center justify-center rounded-xl bg-white text-lg font-bold"
              style={{ color: BRAND }}
            >
              K
            </span>
            <div>
              <p className="text-lg font-semibold tracking-tight">Kech Delivery</p>
              <p className="text-sm text-white/80">Admin operations portal</p>
            </div>
          </div>
        </div>
        <div className="relative z-10 space-y-6">
          <h1 className="text-3xl font-semibold leading-tight tracking-tight xl:text-4xl">
            Manage restaurants, orders, and drivers
          </h1>
          <p className="max-w-md text-base leading-relaxed text-white/85">
            Sign in with your admin credentials to monitor live operations, approve drivers,
            and configure the platform.
          </p>
          <ul className="space-y-3 text-sm text-white/90">
            <li className="flex items-center gap-3">
              <Shield className="h-5 w-5 shrink-0" />
              Secure staff-only access
            </li>
          </ul>
        </div>
        <p className="relative z-10 text-xs text-white/60">Authorized administrators only.</p>
      </section>

      <section className="flex flex-1 flex-col items-center justify-center bg-[#f7f6f8] px-4 py-10 sm:px-8">
        <div className="mb-8 text-center lg:hidden">
          <div
            className="mx-auto mb-3 flex h-12 w-12 items-center justify-center rounded-xl text-lg font-bold text-white"
            style={{ backgroundColor: BRAND }}
          >
            K
          </div>
          <p className="text-xl font-semibold" style={{ color: BRAND }}>
            Kech Admin
          </p>
          <p className="mt-1 text-sm text-muted-foreground">Sign in to continue</p>
        </div>

        <Card className="w-full max-w-[420px] border-0 shadow-lg shadow-[#800020]/10">
          <CardHeader className="space-y-1 pb-2 text-center sm:text-left">
            <CardTitle className="text-2xl font-semibold tracking-tight">Admin sign in</CardTitle>
            <CardDescription>
              Use your registered phone number and password.
            </CardDescription>
          </CardHeader>
          <CardContent>
            <form onSubmit={onSubmit} className="space-y-5">
              <div className="space-y-2">
                <Label htmlFor="phone">Phone number</Label>
                <div className="relative">
                  <Phone className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                  <Input
                    id="phone"
                    name="phone"
                    type="tel"
                    autoComplete="tel"
                    required
                    placeholder="+251912345678"
                    value={phone}
                    onChange={(e) => setPhone(e.target.value)}
                    className="h-11 pl-10"
                  />
                </div>
              </div>
              <div className="space-y-2">
                <div className="flex items-center justify-between">
                  <Label htmlFor="password">Password</Label>
                  <Link
                    href="/login/forgot-password"
                    className="text-xs font-medium hover:underline"
                    style={{ color: BRAND }}
                  >
                    Forgot password?
                  </Link>
                </div>
                <div className="relative">
                  <Lock className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                  <Input
                    id="password"
                    name="password"
                    type={showPassword ? "text" : "password"}
                    autoComplete="current-password"
                    required
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    className="h-11 pl-10 pr-10"
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword((v) => !v)}
                    className="absolute right-3 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground"
                    aria-label={showPassword ? "Hide password" : "Show password"}
                  >
                    {showPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                  </button>
                </div>
              </div>
              {error ? (
                <Alert variant="destructive">
                  <AlertDescription>{error}</AlertDescription>
                </Alert>
              ) : null}
              <Button
                type="submit"
                disabled={loading}
                className="h-11 w-full text-base text-white"
                style={{ backgroundColor: BRAND }}
                size="lg"
              >
                {loading ? (
                  <>
                    <Loader2 className="h-4 w-4 animate-spin" />
                    Signing in…
                  </>
                ) : (
                  "Sign in"
                )}
              </Button>
            </form>
          </CardContent>
        </Card>
      </section>
    </div>
  );
}
