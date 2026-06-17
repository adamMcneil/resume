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

## Build the PDFs (one command)
Builds the HTML and prints all three one-page PDFs to `dist/` using headless
Chrome or Edge (auto-detected — no LaTeX):
```
./build-pdf.sh                              # macOS / Linux / Git Bash
pwsh -ExecutionPolicy Bypass -File build-pdf.ps1   # Windows PowerShell
```
Output: `dist/minimal.pdf`, `dist/modern.pdf`, `dist/classic.pdf`.

## Save as PDF (manual alternative)
1. Run `npm run build` (or `make`) to refresh `dist/*.html`.
2. Open a `dist/*.html` file in Chrome or Edge and press **Ctrl+P**.
3. Destination **Save as PDF**, Margins **Default**, Scale **100%**, uncheck
   **Headers and footers**, then save — each is exactly one page.

## Add a style
Add `styles/<name>.css` and append `'<name>'` to the `THEMES` array in `build.mjs`.

## Legacy files
The old LaTeX resume (`resume.tex`), its PDF, and prior cover letters live in
`old/` for reference; they are no longer part of the build.
