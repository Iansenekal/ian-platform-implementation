"use client";
import { useState } from "react";

const menuItems: Record<string, string[]> = {
  features: ["Invoicing", "Cashflow", "Payroll", "Reports"],
  industry: ["Creative", "Handymen", "Non-profit", "Self-employed"],
  resources: ["Help Center", "Guides", "Pricing FAQ", "Contact"],
};

export default function Home() {
  const [open, setOpen] = useState<string | null>(null);
  const items = open ? menuItems[open] ?? [] : [];

  return (
    <main style={{ minHeight: "100vh", background: "#070707", color: "#fff", padding: 24 }}>
      <header style={{ display: "flex", alignItems: "center", justifyContent: "space-between" }}>
        <h1 style={{ color: "#22c55e", fontSize: 42, margin: 0 }}>Sage</h1>
        <nav style={{ display: "flex", gap: 12 }}>
          <button onClick={() => setOpen(open === "features" ? null : "features")}>Features</button>
          <button onClick={() => setOpen(open === "industry" ? null : "industry")}>Industry</button>
          <button onClick={() => setOpen(open === "resources" ? null : "resources")}>Resources</button>
        </nav>
      </header>

      {open && (
        <section style={{ marginTop: 16, background: "#fff", color: "#111", width: 280, borderRadius: 12, padding: 12 }}>
          {items.map((item) => (
            <div key={item} style={{ padding: "8px 4px" }}>{item}</div>
          ))}
        </section>
      )}
    </main>
  );
}
