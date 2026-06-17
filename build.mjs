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
