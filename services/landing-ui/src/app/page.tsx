"use client";
import { useEffect, useRef, useState } from "react";
import { menuItems } from "./menu-data";
import styles from "./page.module.css";
export default function Home() {
  const [open, setOpen] = useState<"features" | "industry" | "resources" | null>(null);
  const navRef = useRef<HTMLElement | null>(null);
  useEffect(() => {
    const onPointerDown = (event: PointerEvent) => {
      if (!navRef.current?.contains(event.target as Node)) {
        setOpen(null);
      }
    };

    const onKeyDown = (event: KeyboardEvent) => {
      if (event.key === "Escape") {
        setOpen(null);
      }
    };

    window.addEventListener("pointerdown", onPointerDown);
    window.addEventListener("keydown", onKeyDown);

    return () => {
      window.removeEventListener("pointerdown", onPointerDown);
      window.removeEventListener("keydown", onKeyDown);
    };
  }, []);
  const items = open ? menuItems[open] : [];

  return (
    <main className={styles.page}>
      <header className={styles.header}>
        <h1 className={styles.logo}>Sage</h1>
        <nav ref={navRef} className={styles.nav}>
          <button aria-controls="menu-panel" type="button" aria-haspopup="menu" aria-expanded={open === "features"} className={styles.navButton} onClick={() => setOpen(open === "features" ? null : "features")} onKeyDown={(event) => {
              if (event.key === "ArrowDown") {
                event.preventDefault();
                setOpen("features");
              }
            }}>Features</button>
          <button aria-controls="menu-panel" type="button" aria-haspopup="menu" aria-expanded={open === "industry"} className={styles.navButton} onClick={() => setOpen(open === "industry" ? null : "industry")} onKeyDown={(event) => {
              if (event.key === "ArrowDown") {
                event.preventDefault();
                setOpen("industry");
              }
            }}>Industry</button>
          <button aria-controls="menu-panel" type="button" aria-haspopup="menu" aria-expanded={open === "resources"} className={styles.navButton} onClick={() => setOpen(open === "resources" ? null : "resources")} onKeyDown={(event) => {
              if (event.key === "ArrowDown") {
                event.preventDefault();
                setOpen("resources");
              }
            }}>Resources</button>
        </nav>
      </header>

      {open && (
        <section id="menu-panel" className={styles.menuPanel} role="menu" aria-label={` menu`}>
          {items.map((item) => (
            <div key={item} role="menuitem" tabIndex={0} className={styles.menuItem}>{item}</div>
          ))}
        </section>
      )}
    </main>
  );
}
