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
