import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Kech Sales",
  description: "Kech Delivery sales frontend",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className="h-full antialiased">
      <body className="min-h-full">{children}</body>
    </html>
  );
}
