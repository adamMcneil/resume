#!/usr/bin/env bash
# Build the three resume PDFs (one US Letter page each) from resume.md.
# Regenerates dist/*.html, then prints each theme to dist/*.pdf with headless
# Chrome or Edge. No LaTeX. Run from anywhere:  bash build-pdf.sh
set -euo pipefail
cd "$(dirname "$0")"

# Ensure dependencies, then rebuild the HTML from the Markdown source.
[ -d node_modules ] || npm install
node build.mjs

# Find a Chromium-based browser.
browser=""
for c in \
  "/c/Program Files/Google/Chrome/Application/chrome.exe" \
  "/c/Program Files (x86)/Google/Chrome/Application/chrome.exe" \
  "${LOCALAPPDATA:-}/Google/Chrome/Application/chrome.exe" \
  "/c/Program Files/Microsoft/Edge/Application/msedge.exe" \
  "/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe" \
  "google-chrome" "chromium" "chromium-browser"; do
  if [ -x "$c" ] || command -v "$c" >/dev/null 2>&1; then browser="$c"; break; fi
done
if [ -z "$browser" ]; then
  echo "No Chrome or Edge found. Open dist/*.html in a browser and use Ctrl+P -> Save as PDF." >&2
  exit 1
fi

# Use a Windows-style path for the file:// URL on Git Bash; fall back to POSIX.
dir="$(pwd -W 2>/dev/null || pwd)"

# Print each theme to a one-page PDF. A throwaway --user-data-dir forces a fresh
# headless instance; without it a running Chrome can swallow --print-to-pdf and
# write nothing. (If a future Chrome drops --headless=old, change it to --headless.)
for theme in minimal modern classic; do
  profile="$(mktemp -d)"
  "$browser" --headless=old --disable-gpu --no-first-run --no-pdf-header-footer \
    --user-data-dir="$profile" \
    --print-to-pdf="$dir/dist/$theme.pdf" "file:///$dir/dist/$theme.html" >/dev/null 2>&1 || true
  rm -rf "$profile"
  [ -f "$dir/dist/$theme.pdf" ] || { echo "Failed to write $theme.pdf" >&2; exit 1; }
  echo "wrote dist/$theme.pdf"
done
echo "Done. PDFs are in dist/."
