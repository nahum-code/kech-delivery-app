import { NextRequest, NextResponse } from "next/server";

const PROTECTED_PATHS = [
  "/dashboard",
  "/analytics",
  "/orders",
  "/payments",
  "/restaurants",
  "/menus",
  "/drivers",
  "/users",
  "/customers",
  "/sales",
];

function isProtectedPath(pathname: string): boolean {
  return PROTECTED_PATHS.some(
    (path) => pathname === path || pathname.startsWith(`${path}/`),
  );
}

export function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;
  const accessToken = request.cookies.get("kech_admin_access_token")?.value;

  if (pathname === "/") {
    return NextResponse.redirect(
      new URL(accessToken ? "/dashboard" : "/login", request.url),
    );
  }

  if (pathname === "/login") {
    return accessToken
      ? NextResponse.redirect(new URL("/dashboard", request.url))
      : NextResponse.next();
  }

  if (!isProtectedPath(pathname)) {
    return NextResponse.next();
  }

  if (!accessToken) {
    return NextResponse.redirect(new URL("/login", request.url));
  }

  return NextResponse.next();
}

export const config = {
  matcher: [
    "/",
    "/login",
    "/dashboard/:path*",
    "/analytics/:path*",
    "/orders/:path*",
    "/payments/:path*",
    "/restaurants/:path*",
    "/menus/:path*",
    "/drivers/:path*",
    "/users/:path*",
    "/customers/:path*",
    "/sales/:path*",
  ],
};
