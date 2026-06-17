# Markdown Resume — Design Spec

**Date:** 2026-06-17
**Author:** Adam McNeil (with Claude)
**Status:** Approved design, pending spec review

## Goal

Replace the LaTeX resume (`resume.tex` + `pdflatex` Makefile) with a
Markdown-authored resume that produces **three visual styles** of the **same
content**, each printing to **exactly one US Letter page** via HTML/CSS in the
browser (Print → Save as PDF). No LaTeX.

## Constraints (locked)

- **Content is identical across all three versions.** Only visual style varies.
- **Each version is exactly one page** (US Letter, portrait).
- **No LaTeX.** Rendering is HTML + CSS, printed to PDF from a browser.
- **Single source of truth** for content (no per-style content duplication).

## Architecture (Recommendation A)

```
resume/
  resume.md            # SINGLE SOURCE OF TRUTH — content in clean Markdown
  styles/
    minimal.css        # theme 1
    modern.css         # theme 2
    classic.css        # theme 3
  build.mjs            # reads resume.md, emits 3 standalone HTML files
  package.json         # { build: node build.mjs }, dep: marked
  Makefile             # `make` -> build all three (replaces LaTeX Makefile)
  dist/
    minimal.html       # open -> Ctrl+P -> Save as PDF -> 1 page
    modern.html
    classic.html
  README.md            # how to edit content + print to PDF
```

**Data flow:**
1. Author edits `resume.md` (Markdown, renders fine on GitHub on its own).
2. `build.mjs` converts `resume.md` → HTML once with `marked`, then for each
   theme wraps it in an HTML template and **inlines** the theme CSS, writing a
   self-contained file to `dist/<style>.html` (portable — no external assets).
3. User opens `dist/<style>.html`, prints to PDF (margins: Default, scale 100%).

**Components & boundaries:**
- `resume.md` — content only, no styling. Owns *what* the resume says.
- `styles/*.css` — presentation + page sizing only. Owns *how it looks* and the
  one-page fit (`@page { size: Letter; margin }`, typography scale).
- `build.mjs` — glue. Owns md→html conversion and template assembly. Knows the
  list of themes; otherwise dumb.

Each can change without breaking the others: edit content without touching CSS;
restyle without touching content; add a 4th theme by dropping a CSS file and
adding one line to the theme list in `build.mjs`.

## The three styles (same content, one Letter page each)

- **Minimal** — system sans-serif, generous whitespace, hairline rule dividers,
  uppercase letter-spaced section labels, no color, no icons. ATS-friendly.
- **Modern** — sans-serif, one accent color, bold section headers with a colored
  underline bar, name-left / contact-right header row. Contemporary tech look.
- **Classic** — serif (Georgia/Charter stack), centered name header, full-width
  ruled lines under section titles, black-on-white, traditional.

## Content (ported verbatim from `resume.tex`)

Header: **Adam McNeil** — St. Louis, Missouri · github.com/adamMcneil ·
(636) 312-7281 · adamwmcneil@gmail.com

**Profile** — UIUC MCS 2025; backend (Java, SQL, Git), full-stack (React,
Svelte); enjoys TypeScript, Rust, OCaml, Go, C#, Svelte, Tailwind, Neovim,
Linux, React.

**Experience**
- Conference Technologies Inc. — DevOps Engineer — St. Louis, MO — 2025–Now
  (React + Dynamics 365; C# data-pull automation; Azure Pipelines CI/CD; Grafana)
- NISC — Software Developer Intern — Lake St. Louis, MO — 2023–2024
  (Java batch workflow; Oracle retrieval; Postgres migration test env; PowerShell)
- Oasis Digital — Software Development Intern — Chesterfield, MO — 2022
  (Unity 3D planning app; Firebase; game jam)

**Projects**
- Lichess Engine (2021, 2025) — Java chess bot, flame-graph optimization, tests,
  minimax + alpha-beta — github.com/adamMcneil/chess-engine
- Fullstack Project (2023–2024) — Rust/Rocket API, Svelte+Tailwind front end,
  Render + GitHub Pages CI/CD — github.com/adamMcneil/mcneil-web-games
- Streaming Platform (2024) — distributed membership/file system + stream
  processing, gRPC, Docker — Distributed Systems course project

**Education**
- University of Illinois Urbana-Champaign — Master of Computer Science —
  Aug 2024–May 2025 — GPA 3.80
- University of Science and Technology, Rolla, MO — B.S. Computer Science,
  Minor in Mathematics — Aug 2021–May 2024 — GPA 3.94

**Typo fixes during port:** correct obvious source typos (e.g. "DevOps Enginner"
→ "DevOps Engineer"). No other content changes.

## Verification (definition of done)

- `npm install` then `make` (or `npm run build`) produces three `dist/*.html`.
- Each renders correctly and prints to **exactly one Letter page** (verified by
  generating each PDF and confirming page count = 1).
- The three look meaningfully different per the style descriptions above.
- `resume.md` renders cleanly as standalone Markdown on GitHub.
- Existing `resume.tex` and old PDFs left untouched.

## Out of scope

- Tailoring content per job/role (content is identical across versions).
- Hosting/deploying the resume as a website.
- Automating browser print (manual Ctrl+P is the print step).
