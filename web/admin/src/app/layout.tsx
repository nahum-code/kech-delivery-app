import type { Metadata } from "next";
import { AppProviders } from "@/components/providers";
import "./globals.css";

export const metadata: Metadata = {
  title: "Kech Admin",
  description: "Kech Delivery admin frontend",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    // Extensions (e.g. ColorZilla inject `cz-shortcut-listen`) and some theme scripts
    // mutate <html>/<body> before hydrate; suppressHydrationWarning only silences
    // mismatch warnings for these nodes, not their descendants.
    <html lang="en" className="h-full antialiased" suppressHydrationWarning>
      <body className="min-h-full" suppressHydrationWarning>
        <AppProviders>{children}</AppProviders>
      </body>
    </html>
  );
}
