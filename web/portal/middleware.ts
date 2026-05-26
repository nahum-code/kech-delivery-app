import { NextRequest, NextResponse } from "next/server";

export function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;
  const accessToken = request.cookies.get("kech_portal_access_token")?.value;
  const userRole = request.cookies.get("kech_portal_role")?.value;

  if (pathname === "/") {
    if (!accessToken) return NextResponse.redirect(new URL("/login", request.url));
    if (userRole === "admin") return NextResponse.redirect(new URL("/admin/dashboard", request.url));
    if (userRole === "sales") return NextResponse.redirect(new URL("/sales/create-order", request.url));
    return NextResponse.redirect(new URL("/login", request.url));
  }

  if (pathname === "/login" || pathname.startsWith("/login/")) {
    if (accessToken && pathname === "/login") {
      const dest = userRole === "admin" ? "/admin/dashboard" : "/sales/create-order";
      return NextResponse.redirect(new URL(dest, request.url));
    }
    return NextResponse.next();
  }

  if (pathname.startsWith("/admin")) {
    if (!accessToken || userRole !== "admin") {
      return NextResponse.redirect(new URL("/login", request.url));
    }
    return NextResponse.next();
  }

  if (pathname.startsWith("/sales")) {
    if (!accessToken || userRole !== "sales") {
      return NextResponse.redirect(new URL("/login", request.url));
    }
    return NextResponse.next();
  }

  return NextResponse.next();
}

export const config = {
  matcher: [
    "/",
    "/login",
    "/login/:path*",
    "/admin/:path*",
    "/sales/:path*",
  ],
};
