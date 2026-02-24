"use client";
import { useState } from "react";
import { menuItems } from "./menu-data";
import styles from "./page.module.css";
export default function Home() {
  const [open, setOpen] = useState<string | null>(null);
  const items = open ? menuItems[open] ?? [] : [];

  return (
    <main className={styles.page}>
      <header className={styles.header}>
        <h1 className={styles.logo}>Sage</h1>
        <nav className={styles.nav}>
          <button className={styles.navButton} onClick={() => setOpen(open === "features" ? null : "features")}>Features</button>
          <button className={styles.navButton} onClick={() => setOpen(open === "industry" ? null : "industry")}>Industry</button>
          <button className={styles.navButton} onClick={() => setOpen(open === "resources" ? null : "resources")}>Resources</button>
        </nav>
      </header>

      {open && (
        <section className={styles.menuPanel}>
          {items.map((item) => (
            <div key={item} className={styles.menuItem}>{item}</div>
          ))}
        </section>
      )}
    </main>
  );
}
