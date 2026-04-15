import type { Metadata } from "next";
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
    <html lang="en" className="h-full antialiased">
      <body className="min-h-full">{children}</body>
    </html>
  );
}
