"use client";
import { useEffect, useRef, useState } from "react";
import { menuItems } from "./menu-data";
import { featureCards, hero, trustPoints } from "./landing-content";
const organizationJsonLd = {"@context":"https://schema.org","@type":"Organization","name":"Sage","url":"http://10.10.5.186:3000"};
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
    <>
      <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(organizationJsonLd) }} />
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

      <section className={styles.heroSection}>
        <p className={styles.eyebrow}>{hero.eyebrow}</p>
        <h2 className={styles.heroTitle}>{hero.title}</h2>
        <p className={styles.heroBody}>{hero.body}</p>
        <div className={styles.heroActions}>
          <button type="button" className={styles.primaryCta}>{hero.primaryCta}</button>
          <button type="button" className={styles.secondaryCta}>{hero.secondaryCta}</button>
        </div>
      </section>

      <section className={styles.trustSection}>
        {trustPoints.map((point) => (
          <p key={point} className={styles.trustItem}>{point}</p>
        ))}
      </section>

      <section className={styles.featuresSection}>
        {featureCards.map((card) => (
          <article key={card.title} className={styles.featureCard}>
            <h3 className={styles.featureTitle}>{card.title}</h3>
            <p className={styles.featureBody}>{card.description}</p>
          </article>
        ))}
      </section>

      {open && (
        <section id="menu-panel" className={styles.menuPanel} role="menu" aria-label={`${open} menu`}>
          {items.map((item) => (
            <div key={item} role="menuitem" tabIndex={0} className={styles.menuItem}>{item}</div>
          ))}
        </section>
      )}
    </main>
    </>
  );
}
