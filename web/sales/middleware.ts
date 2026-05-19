import { NextRequest, NextResponse } from "next/server";

const PROTECTED_PATHS = ["/dashboard", "/create-order", "/catalog", "/assign-driver", "/monitor-orders"];

export function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;
  const accessToken = request.cookies.get("kech_sales_access_token")?.value;

  if (pathname === "/login") {
    return accessToken
      ? NextResponse.redirect(new URL("/dashboard", request.url))
      : NextResponse.next();
  }

  const isProtected = PROTECTED_PATHS.some(
    (path) => pathname === path || pathname.startsWith(`${path}/`),
  );

  if (!isProtected) {
    return NextResponse.next();
  }

  if (!accessToken) {
    return NextResponse.redirect(new URL("/login", request.url));
  }

  return NextResponse.next();
}

export const config = {
  matcher: ["/dashboard/:path*", "/create-order/:path*", "/catalog/:path*", "/assign-driver/:path*", "/monitor-orders/:path*", "/login"],
};