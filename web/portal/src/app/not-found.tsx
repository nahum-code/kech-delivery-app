import Link from "next/link";

const BRAND = "#800020";

export default function NotFound() {
  return (
    <div className="flex min-h-screen items-center justify-center bg-[#f7f6f8] px-4">
      <div className="w-full max-w-md text-center">
        <p className="text-6xl font-bold" style={{ color: BRAND }}>
          404
        </p>
        <h1 className="mt-4 text-2xl font-semibold text-gray-900">Page not found</h1>
        <p className="mt-3 text-sm leading-relaxed text-gray-500">
          The page you are looking for doesn&apos;t exist or has been moved.
        </p>
        <div className="mt-8 flex items-center justify-center gap-3">
          <Link
            href="/login"
            className="rounded-lg px-5 py-2.5 text-sm font-medium text-white"
            style={{ backgroundColor: BRAND }}
          >
            Back to login
          </Link>
        </div>
      </div>
    </div>
  );
}
