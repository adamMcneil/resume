# Markdown Resume Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the LaTeX resume with a single Markdown source rendered into three CSS-styled, standalone HTML files (minimal, modern, classic), each printing to exactly one US Letter page.

**Architecture:** `resume.md` is the single content source. `build.mjs` converts it to HTML once with `marked`, wraps the leading name+contact in a `<header class="head">`, then for each theme inlines that theme's CSS into a standalone `dist/<theme>.html`. The user opens a `dist` file and prints to PDF.

**Tech Stack:** Node.js (ESM), `marked` (Markdown→HTML), plain CSS with `@page` print rules. Build via `npm run build` / `make`. Print to PDF from Chrome/Edge.

## Global Constraints

- Content is **identical** across all three versions — only CSS differs.
- Each version prints to **exactly one US Letter page** (portrait).
- **No LaTeX** in the new pipeline.
- `resume.md` is the **single source of truth** — no content duplicated into CSS or HTML.
- Leave existing `resume.tex` and the old `*.pdf` files untouched.
- Port content verbatim from `resume.tex` except fixing the typo `DevOps Enginner → DevOps Engineer`.

---

### Task 1: Project scaffolding

**Files:**
- Create: `package.json`
- Create: `.gitignore`

**Interfaces:**
- Produces: `npm run build` → runs `node build.mjs`; dependency `marked`.

- [ ] **Step 1: Create `package.json`**

```json
{
  "name": "adam-mcneil-resume",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "description": "Adam McNeil's resume: one Markdown source, three CSS themes, one page each.",
  "scripts": {
    "build": "node build.mjs"
  },
  "dependencies": {
    "marked": "^14.1.2"
  }
}
```

- [ ] **Step 2: Create `.gitignore`**

```gitignore
node_modules/
*.aux
*.log
*.out
*.toc
```

- [ ] **Step 3: Install the dependency**

Run: `npm install`
Expected: creates `node_modules/` and `package-lock.json`, no errors. (If `^14.1.2` is unavailable, accept whatever current `marked` 12+ resolves; the API `marked.parse(string)` is stable across these versions.)

- [ ] **Step 4: Commit**

```bash
git add package.json package-lock.json .gitignore
git commit -m "chore: scaffold Node build for Markdown resume"
```

---

### Task 2: Resume content (`resume.md`)

**Files:**
- Create: `resume.md`

**Interfaces:**
- Produces: a Markdown document whose first line is an `# h1` (name) immediately followed by a single contact `<p>`; sections are `##`; each entry is `###` followed by a meta line, a bullet list, and an italic technology line.

- [ ] **Step 1: Write `resume.md`**

```markdown
# Adam McNeil

St. Louis, Missouri · [github.com/adamMcneil](https://github.com/adamMcneil) · (636) 312-7281 · [adamwmcneil@gmail.com](mailto:adamwmcneil@gmail.com)

## Profile

I graduated from the University of Illinois Urbana-Champaign with a Master's of Computer Science in 2025. I have experience as a backend developer with technologies such as Java, SQL, and Git, and as a full-stack developer using React and Svelte. I like using the best tools for the job — and learning new ones — and enjoy languages and technologies such as TypeScript, Rust, OCaml, Go, C#, Svelte, Tailwind, Neovim, Linux, and React.

## Experience

### Conference Technologies Inc. — DevOps Engineer
St. Louis, Missouri · 2025–Present
- Developed React front ends integrated with a Dynamics 365 backend.
- Built a C# application to automate pulling data from public APIs into internal storage.
- Developed CI/CD pipelines using Azure Pipelines.
- Monitored application performance using Grafana dashboards.

*Technology: JavaScript, Git, React, Full-Stack, Azure Pipelines, CI/CD, Grafana*

### NISC — Software Developer Intern
Lake St. Louis, Missouri · 2023–2024
- Helped maintain a batch-processing workflow written in Java.
- Streamlined data retrieval from an Oracle database.
- Created a test environment for migrating to a PostgreSQL database.
- Wrote PowerShell scripts to automate code-base analysis and modification.

*Technology: Java, PowerShell, Git, PostgreSQL, Oracle, Docker, Gradle, Windows*

### Oasis Digital — Software Development Intern
Chesterfield, Missouri · 2022
- Designed and developed a 3D project-planning application using Unity.
- Used Firebase to manage and store persistent data.
- Competed in a company-wide game jam, building a game within a single day.

*Technology: C#, Unity, Git, Firebase*

## Projects

### Lichess Engine
[github.com/adamMcneil/chess-engine](https://github.com/adamMcneil/chess-engine) · 2021, 2025
- Developed a Lichess bot in Java.
- Used flame graphs and other performance metrics to find and optimize slow code.
- Built a unit and integration test suite.
- Implemented the minimax algorithm with alpha-beta pruning to select the best move.

*Technology: Java, IntelliJ, Gradle, Git*

### Fullstack Project
[github.com/adamMcneil/mcneil-web-games](https://github.com/adamMcneil/mcneil-web-games) · 2023–2024
- Developed a web API in Rust using the Rocket web framework.
- Built a static front end in Svelte and Tailwind.
- Deployed a CI/CD pipeline with Render and GitHub Pages to host the backend and frontend.

*Technology: Rust, Svelte, TypeScript, HTTP, CSS, Tailwind, Render, Git*

### Streaming Platform
Distributed Systems Course Project · 2024
- Developed a distributed group-membership service.
- Built a distributed file system on top of the membership service.
- Developed a distributed stream-processing framework similar to Spark Streaming.
- Implemented with gRPC and tested in a Docker virtual environment.

*Technology: Go, Protocol Buffers, gRPC, Docker, Spark Streaming*

## Education

### University of Illinois Urbana-Champaign — Master of Computer Science
Urbana-Champaign, Illinois · Aug 2024–May 2025 · GPA 3.80

### University of Science and Technology — B.S. Computer Science, Minor in Mathematics
Rolla, Missouri · Aug 2021–May 2024 · GPA 3.94
```

- [ ] **Step 2: Sanity-check rendering**

Run: `npx marked -i resume.md | head -20` (or open `resume.md` on GitHub)
Expected: clean HTML — `<h1>Adam McNeil</h1>`, then a `<p>` contact line, `<h2>` sections, `<h3>` entries, `<ul>` bullets, `<em>` technology lines. No raw Markdown leaking.

- [ ] **Step 3: Commit**

```bash
git add resume.md
git commit -m "feat: add resume content as single Markdown source"
```

---

### Task 3: Build script (`build.mjs`)

**Files:**
- Create: `build.mjs`

**Interfaces:**
- Consumes: `resume.md`, `styles/<theme>.css` (created in Task 4).
- Produces: `dist/<theme>.html` standalone files (CSS inlined). `THEMES` array is the single list of styles.

- [ ] **Step 1: Write `build.mjs`**

```js
import { readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import { marked } from 'marked';

const THEMES = ['minimal', 'modern', 'classic'];
const root = new URL('./', import.meta.url);

// Render Markdown once, then wrap the leading name (h1) + contact line (first p)
// into a header block so themes can lay out the masthead.
let body = marked.parse(readFileSync(new URL('resume.md', root), 'utf8'));
body = body.replace(
  /^<h1>([\s\S]*?)<\/h1>\s*<p>([\s\S]*?)<\/p>/,
  '<header class="head"><h1>$1</h1><p class="contact">$2</p></header>'
);

mkdirSync(new URL('dist/', root), { recursive: true });

for (const theme of THEMES) {
  const css = readFileSync(new URL(`styles/${theme}.css`, root), 'utf8');
  const html = `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Adam McNeil — Resume (${theme})</title>
<style>
${css}</style>
</head>
<body>
<main class="resume">
${body}</main>
</body>
</html>
`;
  writeFileSync(new URL(`dist/${theme}.html`, root), html);
  console.log(`built dist/${theme}.html`);
}
```

- [ ] **Step 2: Verify the header-wrap transform**

This cannot fully run until Task 4 supplies CSS, but the regex can be checked now by temporarily creating empty CSS files:

Run: `mkdir -p styles && : > styles/minimal.css && : > styles/modern.css && : > styles/classic.css && node build.mjs`
Expected: prints `built dist/minimal.html` ×3; `dist/minimal.html` contains `<header class="head"><h1>Adam McNeil</h1><p class="contact">St. Louis...` exactly once.

- [ ] **Step 3: Commit**

```bash
git add build.mjs
git commit -m "feat: add build script (md -> 3 standalone themed HTML files)"
```

---

### Task 4: CSS themes

**Files:**
- Create: `styles/minimal.css`
- Create: `styles/modern.css`
- Create: `styles/classic.css`

**Interfaces:**
- Consumes: the HTML shape from Task 3 — `.resume` wrapper, `.head`/`h1`/`.contact`, `h2` sections, `h3` entries, `h3 + p` meta line, `ul`/`li` bullets, `p > em` technology line.
- Produces: each file defines `@page { size: Letter }` and typography tuned to one page.

All three share the same print/screen scaffold: in print, `.resume` width equals the printable area (page width minus `@page` margins) so margins are not doubled; on screen, `.resume` is rendered as a page-sized white card for WYSIWYG.

- [ ] **Step 1: Write `styles/minimal.css`**

```css
@page { size: Letter; margin: 0.5in; }
:root { --ink:#111; --muted:#555; --rule:#d0d0d0; }
* { box-sizing: border-box; }
html, body { margin: 0; padding: 0; }
body {
  font-family: -apple-system, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
  color: var(--ink); font-size: 10pt; line-height: 1.32;
}
.resume { width: 7.5in; margin: 0 auto; }
@media screen {
  body { background:#eee; }
  .resume { width:8.5in; padding:0.5in; margin:24px auto; background:#fff;
            box-shadow:0 2px 12px rgba(0,0,0,.15); }
}
.head { margin-bottom: 12px; }
h1 { font-size: 22pt; font-weight: 600; letter-spacing: 0.3px; }
.contact { font-size: 9pt; color: var(--muted); margin-top: 3px; }
.contact a { color: var(--muted); }
h2 {
  font-size: 9pt; font-weight: 700; text-transform: uppercase; letter-spacing: 2.5px;
  margin: 14px 0 6px; padding-bottom: 3px; border-bottom: 1px solid var(--rule);
}
h3 { font-size: 10.5pt; font-weight: 600; margin-top: 9px; }
h3 + p { font-size: 8.5pt; color: var(--muted); margin: 1px 0 3px; }
p { margin: 3px 0; }
ul { margin: 2px 0 4px; padding-left: 16px; }
li { margin: 1.5px 0; }
li::marker { color: #999; }
em { font-style: italic; color: var(--muted); font-size: 8.5pt; }
a { color: inherit; text-decoration: none; }
```

- [ ] **Step 2: Write `styles/modern.css`**

```css
@page { size: Letter; margin: 0.5in; }
:root { --ink:#1f2937; --muted:#6b7280; --accent:#2563eb; }
* { box-sizing: border-box; }
html, body { margin: 0; padding: 0; }
body {
  font-family: "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
  color: var(--ink); font-size: 10pt; line-height: 1.3;
}
.resume { width: 7.5in; margin: 0 auto; }
@media screen {
  body { background:#e5e7eb; }
  .resume { width:8.5in; padding:0.5in; margin:24px auto; background:#fff;
            box-shadow:0 2px 12px rgba(0,0,0,.15); }
}
.head { display:flex; justify-content:space-between; align-items:flex-end;
        border-bottom:2.5px solid var(--accent); padding-bottom:7px; margin-bottom:12px; }
h1 { font-size: 23pt; font-weight: 700; color: var(--accent); letter-spacing: 0.3px; }
.contact { font-size: 8.5pt; color: var(--muted); text-align: right; line-height: 1.5; }
.contact a { color: var(--muted); }
h2 { font-size: 11pt; font-weight: 700; color: var(--accent); margin: 13px 0 5px; }
h3 { font-size: 10.5pt; font-weight: 600; margin-top: 8px; }
h3 + p { font-size: 8.5pt; color: var(--muted); margin: 1px 0 3px; }
p { margin: 3px 0; }
ul { margin: 2px 0 4px; padding-left: 16px; }
li { margin: 1.5px 0; }
li::marker { color: var(--accent); }
em { font-style: italic; color: var(--muted); font-size: 8.5pt; }
a { color: inherit; text-decoration: none; }
```

- [ ] **Step 3: Write `styles/classic.css`**

```css
@page { size: Letter; margin: 0.6in; }
:root { --ink:#1a1a1a; --muted:#444; }
* { box-sizing: border-box; }
html, body { margin: 0; padding: 0; }
body {
  font-family: Georgia, "Times New Roman", Cambria, serif;
  color: var(--ink); font-size: 10.5pt; line-height: 1.32;
}
.resume { width: 7.3in; margin: 0 auto; }
@media screen {
  body { background:#efece6; }
  .resume { width:8.5in; padding:0.6in; margin:24px auto; background:#fff;
            box-shadow:0 2px 12px rgba(0,0,0,.15); }
}
.head { text-align: center; margin-bottom: 10px; }
h1 { font-size: 22pt; font-weight: 700; letter-spacing: 1px; }
.contact { font-size: 9pt; color: var(--muted); margin-top: 4px; }
.contact a { color: var(--muted); }
h2 {
  font-size: 11pt; font-weight: 700; text-transform: uppercase; letter-spacing: 1.5px;
  text-align: center; margin: 13px 0 6px; padding-bottom: 4px; border-bottom: 1.2px solid #333;
}
h3 { font-size: 11pt; font-weight: 700; margin-top: 8px; }
h3 + p { font-size: 9pt; font-style: italic; color: var(--muted); margin: 1px 0 3px; }
p { margin: 3px 0; }
ul { margin: 2px 0 4px; padding-left: 18px; }
li { margin: 1.5px 0; }
em { font-style: italic; color: var(--muted); font-size: 9pt; }
a { color: inherit; text-decoration: none; }
```

- [ ] **Step 4: Rebuild and commit**

Run: `node build.mjs`
Expected: three files written, each now containing real CSS in the `<style>` block.

```bash
git add styles/ dist/
git commit -m "feat: add minimal, modern, and classic CSS themes"
```

---

### Task 5: Build wrapper + docs

**Files:**
- Create: `Makefile` (overwrites the old LaTeX one — the LaTeX flow is retired; `resume.tex` itself stays)
- Modify: `README.md` (replace LaTeX instructions with the new workflow)

**Interfaces:**
- Produces: `make` builds all themes; `make clean` removes `dist/`.

- [ ] **Step 1: Overwrite `Makefile`**

```makefile
.PHONY: build clean

build: node_modules
	node build.mjs

node_modules: package.json
	npm install

clean:
	rm -rf dist
```

- [ ] **Step 2: Replace `README.md`**

```markdown
# Adam McNeil — Résumé

One Markdown source, three print-ready styles, each exactly one US Letter page.

## Edit
Edit **`resume.md`** only. It also renders cleanly on GitHub as-is.

## Build
```
npm install      # first time only
npm run build    # or: make
```
Generates three standalone files in `dist/`:
- `dist/minimal.html` — clean, understated, ATS-friendly
- `dist/modern.html` — accent color, contemporary
- `dist/classic.html` — serif, traditional

## Save as PDF
1. Open a `dist/*.html` file in Chrome or Edge.
2. Press **Ctrl+P**.
3. Destination **Save as PDF**, Margins **Default**, Scale **100%**, and
   uncheck **Headers and footers**.
4. Save — each is exactly one page.

## Add a style
Add `styles/<name>.css` and append `'<name>'` to the `THEMES` array in `build.mjs`.

The legacy LaTeX source (`resume.tex`) is kept for reference but is no longer part of the build.
```

- [ ] **Step 3: Commit**

```bash
git add Makefile README.md
git commit -m "docs: replace LaTeX workflow with Markdown build instructions"
```

---

### Task 6: Verify one-page fit and finalize

**Files:**
- Modify (as needed): `styles/minimal.css`, `styles/modern.css`, `styles/classic.css`

**Interfaces:**
- Consumes: `dist/*.html` from the build.
- Produces: confirmed single-page PDFs for all three themes.

- [ ] **Step 1: Render each theme to PDF headlessly**

Detect a Chromium binary (Edge or Chrome) and print each `dist/*.html` to PDF. Example (Edge on Windows):

```bash
EDGE="/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe"
for t in minimal modern classic; do
  "$EDGE" --headless --disable-gpu --no-pdf-header-footer \
    --print-to-pdf="dist/$t.pdf" "file:///c/git-repos/resume/dist/$t.html"
done
```
Expected: `dist/minimal.pdf`, `dist/modern.pdf`, `dist/classic.pdf` created.
(If neither Edge nor Chrome is found, fall back to the Playwright MCP browser: navigate to each file URL and measure `document.querySelector('.resume')` overflow against one printable page.)

- [ ] **Step 2: Assert each PDF is exactly one page**

```bash
node -e '
const fs=require("fs");
for (const t of ["minimal","modern","classic"]) {
  const b=fs.readFileSync(`dist/${t}.pdf`).toString("latin1");
  const n=(b.match(/\/Type\s*\/Page(?![s])/g)||[]).length;
  console.log(t, n, n===1?"OK":"TOO LONG");
}'
```
Expected: every line prints `OK` (count = 1).

- [ ] **Step 3: Tune any overflowing theme**

If a theme reports `TOO LONG`, reduce density in that theme's CSS in small steps until it fits, then rebuild (`node build.mjs`) and re-run Steps 1–2. Tuning levers, in order of preference:
1. Reduce `body { line-height }` by 0.02–0.04.
2. Reduce section spacing (`h2 { margin-top }`) and `h3 { margin-top }` by 1–2px.
3. Reduce `body { font-size }` by 0.5pt.
4. Reduce `@page { margin }` by 0.05in (not below 0.4in).
Do not change wording — content stays fixed.

- [ ] **Step 4: Visual check**

Open each `dist/*.html` in a browser (or take a Playwright screenshot) and confirm the three look meaningfully different and nothing is clipped or awkwardly spaced.

- [ ] **Step 5: Remove the throwaway PDFs and commit final CSS**

The verification PDFs are artifacts, not deliverables (the deliverables are the HTML files printed by the user). Remove them:

```bash
rm -f dist/*.pdf
git add styles/ dist/
git commit -m "fix: tune themes so each resume fits exactly one page"
```

---

## Self-Review

**1. Spec coverage:**
- Single Markdown source → Task 2. ✅
- Three CSS themes → Task 4. ✅
- Build (md→3 HTML, no LaTeX) → Tasks 1, 3, 5. ✅
- Exactly one Letter page → Task 6 (render + assert + tune). ✅
- Identical content across versions → guaranteed structurally (one source, Task 2). ✅
- Typo fix → Task 2 content. ✅
- Leave `resume.tex` / old PDFs untouched → not modified by any task; Makefile overwrite called out in Task 5. ✅
- README how-to → Task 5. ✅

**2. Placeholder scan:** No TBD/TODO; every file has full contents; verification commands are concrete. ✅

**3. Type/name consistency:** Selectors used in Task 4 (`.resume`, `.head`, `.contact`, `h2`, `h3 + p`, `li::marker`, `em`) match the HTML shape produced by Task 3 (`.resume` wrapper, `<header class="head">`, `<p class="contact">`, marked's `h2/h3/ul/em`). `THEMES` array (Task 3) matches the three CSS filenames (Task 4) and the README/Makefile. ✅
