#!/usr/bin/env bash
#
# Render a reveal.js presentation to a series of PNG images and combine them into a PDF.
#
# The slides are rendered one by one with headless Chromium/Chrome by navigating to the
# reveal.js URL hash of each slide (#/h/v/f), so the PNG images are pixel-exact screenshots
# of the presentation at the requested resolution.
#
# Usage: ./render.sh [options] <presentation.html|URL>
# Run "./render.sh --help" for the available options.

set -euo pipefail

# ---------------------------------------------------------------------------- defaults

RESOLUTION="1920x1080"
JOBS=4
WAIT=0
TIMEOUT=120
FRAGMENTS="all"
VERTICAL=false
SLIDE_COUNT=""
MAX_SLIDES=300
MAX_FRAGMENTS=50
OUTPUT_DIR=""
PDF_PATH=""
MAKE_PDF=true
BROWSER_BIN="${BROWSER_BIN:-}"
DPI=""
KEEP_TMP=false

usage() {
	cat <<'EOF'
Render a reveal.js presentation as PNG images and convert them into a PDF.

Usage: ./render.sh [options] <presentation.html|URL>

Options:
  -o, --output-dir DIR   Directory for the PNG images (default: render/<presentation>)
  -r, --resolution WxH   Resolution of the PNG images (default: 1920x1080)
  -j, --jobs N           Number of browser processes to run in parallel (default: 4)
  -w, --wait MS          Extra rendering time per slide as a virtual time budget in ms.
                         0 (default) takes the screenshot once the page has loaded.
                         Increase this if slides are missing content such as equations.
  -t, --timeout SEC      Kill and retry a browser that gets stuck on a slide, e.g. while
                         downloading a video (default: 120, 0 disables the timeout)
  -n, --slides N         Number of slides. By default the count is detected automatically.
      --fragments MODE   How to handle fragments (incremental content):
                           all   - one image per slide with all fragments shown (default)
                           none  - one image per slide with no fragments shown
                           steps - one image per fragment step, like the reveal.js PDF export
      --vertical         Also render vertical (nested) slides. Slower, and only needed for
                         presentations that use vertical slide stacks.
      --pdf FILE         Path of the PDF (default: <output-dir>/<presentation>.pdf)
      --no-pdf           Only render the PNG images
      --dpi N            Resolution metadata of the PDF pages (default: width / 20, so that
                         a 1920x1080 deck gives 20 x 11.25 inch pages like reveal.js does)
      --browser BIN      Browser binary (default: chromium, chrome or google-chrome)
      --max-slides N     Upper limit for the slide auto-detection (default: 300)
      --keep-temp        Keep the temporary browser profiles and work files
  -h, --help             Show this help

The rendering time is dominated by loading the presentation and its external resources
such as reveal.js, MathJax and videos, which takes roughly 5-30 seconds per slide.
Raise --jobs to render more slides at the same time.

Examples:
  ./render.sh 2026_sewm/sewm.html
  ./render.sh -r 3840x2160 -j 8 2026_sewm/sewm.html
  ./render.sh --fragments steps -o /tmp/sewm 2026_sewm/sewm.html
EOF
}

log() { printf '%s\n' "$*" >&2; }
die() { printf 'Error: %s\n' "$*" >&2; exit 1; }

# ---------------------------------------------------------------------------- arguments

INPUT=""
while [ $# -gt 0 ]; do
	case "$1" in
		-o|--output-dir) OUTPUT_DIR="${2:?missing value for $1}"; shift 2 ;;
		-r|--resolution) RESOLUTION="${2:?missing value for $1}"; shift 2 ;;
		-j|--jobs) JOBS="${2:?missing value for $1}"; shift 2 ;;
		-w|--wait) WAIT="${2:?missing value for $1}"; shift 2 ;;
		-t|--timeout) TIMEOUT="${2:?missing value for $1}"; shift 2 ;;
		-n|--slides) SLIDE_COUNT="${2:?missing value for $1}"; shift 2 ;;
		--fragments) FRAGMENTS="${2:?missing value for $1}"; shift 2 ;;
		--vertical) VERTICAL=true; shift ;;
		--pdf) PDF_PATH="${2:?missing value for $1}"; shift 2 ;;
		--no-pdf) MAKE_PDF=false; shift ;;
		--dpi) DPI="${2:?missing value for $1}"; shift 2 ;;
		--browser) BROWSER_BIN="${2:?missing value for $1}"; shift 2 ;;
		--max-slides) MAX_SLIDES="${2:?missing value for $1}"; shift 2 ;;
		--keep-temp) KEEP_TMP=true; shift ;;
		-h|--help) usage; exit 0 ;;
		--) shift; INPUT="${1:-}"; break ;;
		-*) die "unknown option: $1 (see --help)" ;;
		*) [ -n "$INPUT" ] && die "only one presentation can be rendered at a time"; INPUT="$1"; shift ;;
	esac
done

[ -n "$INPUT" ] || { usage >&2; die "no presentation given"; }

case "$RESOLUTION" in
	[0-9]*x[0-9]*) WIDTH="${RESOLUTION%%x*}"; HEIGHT="${RESOLUTION##*x}" ;;
	*) die "invalid resolution: $RESOLUTION (expected e.g. 1920x1080)" ;;
esac
[ "$WIDTH" -gt 0 ] 2>/dev/null && [ "$HEIGHT" -gt 0 ] 2>/dev/null || die "invalid resolution: $RESOLUTION"
[ "$JOBS" -ge 1 ] 2>/dev/null || die "invalid number of jobs: $JOBS"
[ "$WAIT" -ge 0 ] 2>/dev/null || die "invalid wait time: $WAIT"
[ "$TIMEOUT" -ge 0 ] 2>/dev/null || die "invalid timeout: $TIMEOUT"
[ "$MAX_SLIDES" -ge 1 ] 2>/dev/null || die "invalid maximum number of slides: $MAX_SLIDES"
case "$FRAGMENTS" in all|none|steps) ;; *) die "invalid fragment mode: $FRAGMENTS" ;; esac
if [ -n "$SLIDE_COUNT" ]; then
	[ "$SLIDE_COUNT" -ge 1 ] 2>/dev/null || die "invalid slide count: $SLIDE_COUNT"
fi

# ------------------------------------------------------------------------------- inputs

# The presentation can be given either as a local file or as a URL.
case "$INPUT" in
	http://*|https://*|file://*)
		URL="$INPUT"
		NAME="$(basename "${URL%%[?#]*}")"
		NAME="${NAME%.html}"
		;;
	*)
		[ -f "$INPUT" ] || die "no such file: $INPUT"
		ABS="$(cd "$(dirname "$INPUT")" && pwd)/$(basename "$INPUT")"
		# Percent-encode the characters that are not allowed in a URL as such.
		ENC="${ABS// /%20}"; ENC="${ENC//\#/%23}"; ENC="${ENC//\?/%3F}"
		URL="file://$ENC"
		NAME="$(basename "$INPUT" .html)"
		;;
esac
[ -n "$NAME" ] || NAME="presentation"

# The slides are selected with the URL hash, so the presentation itself must not have one.
case "$URL" in *\#*) die "the presentation URL must not contain a hash (#)" ;; esac

[ -n "$OUTPUT_DIR" ] || OUTPUT_DIR="render/$NAME"
[ -n "$PDF_PATH" ] || PDF_PATH="$OUTPUT_DIR/$NAME.pdf"
[ -n "$DPI" ] || DPI=$(( (WIDTH + 10) / 20 ))
[ "$DPI" -ge 1 ] 2>/dev/null || die "invalid dpi: $DPI"

# The browser is used for rendering and ImageMagick for the image comparisons and the PDF.
if [ -z "$BROWSER_BIN" ]; then
	for candidate in chromium chromium-browser google-chrome google-chrome-stable chrome; do
		if command -v "$candidate" >/dev/null 2>&1; then BROWSER_BIN="$candidate"; break; fi
	done
fi
[ -n "$BROWSER_BIN" ] || die "no Chromium/Chrome found, install one or use --browser"
command -v "$BROWSER_BIN" >/dev/null 2>&1 || die "browser not found: $BROWSER_BIN"

COMPARE_CMD=()
if command -v compare >/dev/null 2>&1; then COMPARE_CMD=(compare)
elif command -v magick >/dev/null 2>&1; then COMPARE_CMD=(magick compare)
fi
if [ ${#COMPARE_CMD[@]} -eq 0 ] && { [ -z "$SLIDE_COUNT" ] || [ "$FRAGMENTS" = steps ] || [ "$VERTICAL" = true ]; }; then
	die "ImageMagick is required for detecting the number of slides. Install it, or give the slide count with --slides N."
fi

TIMEOUT_CMD=()
if [ "$TIMEOUT" -gt 0 ] && command -v timeout >/dev/null 2>&1; then
	TIMEOUT_CMD=(timeout --foreground -k 5 "$TIMEOUT")
fi

# The auto-detection compares screenshots, so a small amount of noise has to be tolerated.
DIFF_THRESHOLD=$(( WIDTH * HEIGHT / 100 ))

WORK="$(mktemp -d "${TMPDIR:-/tmp}/revealjs-render-XXXXXX")"
cleanup() { if [ "$KEEP_TMP" = true ]; then log "Temporary files: $WORK"; else rm -rf "$WORK"; fi; }
trap cleanup EXIT

# ------------------------------------------------------------------------------ helpers

# Chromium refuses to run as root without disabling its sandbox.
SANDBOX_ARGS=()
if [ "$(id -u)" -eq 0 ]; then SANDBOX_ARGS=(--no-sandbox); fi

# browser <hash> <output.png> <profile>
browser() {
	local budget=()
	if [ "$WAIT" -gt 0 ]; then budget=(--virtual-time-budget="$WAIT"); fi
	"${TIMEOUT_CMD[@]}" "$BROWSER_BIN" \
		--headless \
		--disable-gpu \
		--hide-scrollbars \
		--force-device-scale-factor=1 \
		--force-color-profile=srgb \
		--no-first-run \
		--no-default-browser-check \
		--disable-extensions \
		--disable-sync \
		--disable-background-networking \
		--disable-component-update \
		"${SANDBOX_ARGS[@]}" \
		"${budget[@]}" \
		--user-data-dir="$3" \
		--window-size="$WIDTH,$HEIGHT" \
		--screenshot="$2" \
		"$URL$1" >/dev/null 2>&1 || true
}

# shoot <hash> <output.png> <slot>
# Takes a screenshot of a single slide. Each parallel slot has its own browser profile,
# which avoids clashes between simultaneously running browsers.
shoot() {
	local hash="$1" out="$2" slot="${3:-0}"
	local profile="$WORK/profile-$slot"
	rm -f "$out"
	browser "$hash" "$out" "$profile"
	if [ ! -s "$out" ]; then
		# The browser may get stuck e.g. on a video that never finishes loading.
		log "Warning: retrying $URL$hash"
		rm -rf "$profile"
		browser "$hash" "$out" "$profile"
	fi
	if [ ! -s "$out" ]; then log "Warning: failed to render $URL$hash"; return 1; fi
}

# slide_url_hash <h> <v> [fragment]
# Builds the reveal.js URL hash of a slide. Out-of-range indices are clamped by reveal.js,
# so 9999 can be used to reach the last slide, the last vertical slide or the last fragment.
slide_url_hash() {
	if [ -n "${3:-}" ]; then printf '#/%s/%s/%s' "$1" "$2" "$3"; else printf '#/%s/%s' "$1" "$2"; fi
}

# slide_hash <h> <v>
# The hash of a slide in the configured fragment mode.
slide_hash() {
	case "$FRAGMENTS" in
		none) slide_url_hash "$1" "$2" ;;
		*) slide_url_hash "$1" "$2" 9999 ;;
	esac
}

# images_equal <a.png> <b.png>
# True if the two screenshots show the same slide. An exact comparison cannot be used,
# because antialiasing and video frames make otherwise identical renderings differ slightly.
images_equal() {
	[ -s "$1" ] && [ -s "$2" ] || return 1
	if [ ${#COMPARE_CMD[@]} -eq 0 ]; then cmp -s "$1" "$2"; return; fi
	local diff
	diff="$("${COMPARE_CMD[@]}" -metric AE -fuzz 3% "$1" "$2" null: 2>&1 || true)"
	diff="${diff%% *}"
	awk -v d="$diff" -v t="$DIFF_THRESHOLD" 'BEGIN { exit !(d ~ /^[0-9.eE+-]+$/ && d + 0 < t) }'
}

# ------------------------------------------------------------------------------ renderer

log "Presentation: $URL"
log "Resolution:   ${WIDTH}x${HEIGHT}"
log "Browser:      $BROWSER_BIN"

# The images are collected into the work directory first and numbered only at the end,
# because the total number of slides is not known in advance.
PAGES=()
COORDS=()

# The last slide of the presentation is used as the end marker of the auto-detection.
LAST_REF="$WORK/last.png"
if [ -z "$SLIDE_COUNT" ]; then
	log "Detecting the number of slides..."
	shoot "$(slide_url_hash 9999 9999 9999)" "$LAST_REF" 0 || die "failed to render the presentation"
fi

h=0
finished=false
while [ "$finished" = false ] && [ "$h" -lt "$MAX_SLIDES" ]; do
	# Render a batch of slides in parallel. With a known slide count the batch is not
	# allowed to run past the last slide.
	batch=()
	for (( slot = 0; slot < JOBS; slot++ )); do
		index=$(( h + slot ))
		if [ -n "$SLIDE_COUNT" ] && [ "$index" -ge "$SLIDE_COUNT" ]; then break; fi
		[ "$index" -lt "$MAX_SLIDES" ] || break
		out="$WORK/slide-$index.png"
		batch+=("$index:$out")
		shoot "$(slide_hash "$index" 0)" "$out" "$slot" &
	done
	[ ${#batch[@]} -gt 0 ] || break
	wait

	for entry in "${batch[@]}"; do
		index="${entry%%:*}"; out="${entry#*:}"
		if [ ! -s "$out" ]; then log "Warning: skipping slide $((index + 1))"; continue; fi
		if [ "$finished" = true ]; then
			# A slide past the end of the presentation, rendered by the parallel batch.
			rm -f "$out"
			continue
		fi
		PAGES+=("$out")
		COORDS+=("$index 0")
		log "Rendered slide $((index + 1))"
		# reveal.js clamps out-of-range slide indices, so a slide that is identical to the
		# last slide of the presentation means that the end has been reached.
		if [ -z "$SLIDE_COUNT" ] && images_equal "$out" "$LAST_REF"; then finished=true; fi
	done

	h=$(( h + ${#batch[@]} ))
	if [ -n "$SLIDE_COUNT" ] && [ "$h" -ge "$SLIDE_COUNT" ]; then finished=true; fi
done

[ ${#PAGES[@]} -gt 0 ] || die "no slides were rendered"
if [ "$finished" = false ]; then log "Warning: stopped at the --max-slides limit of $MAX_SLIDES slides"; fi
log "Found ${#PAGES[@]} slides"

# Vertical slides are rendered only on request, as probing for them requires an extra
# screenshot per slide even when the presentation has none.
if [ "$VERTICAL" = true ]; then
	log "Rendering vertical slides..."
	EXPANDED=(); EXPANDED_COORDS=()
	for (( page = 0; page < ${#PAGES[@]}; page++ )); do
		read -r h v <<< "${COORDS[page]}"
		EXPANDED+=("${PAGES[page]}"); EXPANDED_COORDS+=("$h $v")
		# The bottom slide of the stack is the end marker, just like with the horizontal slides.
		bottom="$WORK/bottom-$h.png"
		shoot "$(slide_hash "$h" 9999)" "$bottom" 0 || continue
		images_equal "${PAGES[page]}" "$bottom" && continue
		v=1
		while [ "$v" -lt "$MAX_SLIDES" ]; do
			out="$WORK/slide-$h-$v.png"
			shoot "$(slide_hash "$h" "$v")" "$out" 0 || break
			EXPANDED+=("$out"); EXPANDED_COORDS+=("$h $v")
			log "Rendered slide $((h + 1)), vertical slide $((v + 1))"
			images_equal "$out" "$bottom" && break
			v=$(( v + 1 ))
		done
	done
	PAGES=("${EXPANDED[@]}"); COORDS=("${EXPANDED_COORDS[@]}")
fi

# In the steps mode every fragment step gets its own image, like in the reveal.js PDF export.
# The already rendered image of the slide has all the fragments shown, so it is the last step.
if [ "$FRAGMENTS" = steps ]; then
	log "Rendering fragment steps..."
	EXPANDED=(); EXPANDED_COORDS=()
	for (( page = 0; page < ${#PAGES[@]}; page++ )); do
		read -r h v <<< "${COORDS[page]}"
		f=0
		while [ "$f" -lt "$MAX_FRAGMENTS" ]; do
			out="$WORK/frag-$h-$v-$f.png"
			shoot "$(slide_url_hash "$h" "$v" "$f")" "$out" 0 || break
			# The step that looks like the fully built slide is the last one.
			if images_equal "$out" "${PAGES[page]}"; then rm -f "$out"; break; fi
			EXPANDED+=("$out"); EXPANDED_COORDS+=("$h $v")
			log "Rendered slide $((h + 1)), fragment step $((f + 1))"
			f=$(( f + 1 ))
		done
		EXPANDED+=("${PAGES[page]}"); EXPANDED_COORDS+=("$h $v")
	done
	PAGES=("${EXPANDED[@]}"); COORDS=("${EXPANDED_COORDS[@]}")
fi

# ------------------------------------------------------------------------------- outputs

mkdir -p "$OUTPUT_DIR"
rm -f "$OUTPUT_DIR"/slide-[0-9]*.png

PAD=3
[ ${#PAGES[@]} -gt 999 ] && PAD=4
IMAGES=()
number=1
for page in "${PAGES[@]}"; do
	target="$(printf '%s/slide-%0*d.png' "$OUTPUT_DIR" "$PAD" "$number")"
	mv -f "$page" "$target"
	IMAGES+=("$target")
	number=$(( number + 1 ))
done
log "Wrote ${#IMAGES[@]} PNG images to $OUTPUT_DIR"

if [ "$MAKE_PDF" = true ]; then
	mkdir -p "$(dirname "$PDF_PATH")"
	if command -v img2pdf >/dev/null 2>&1; then
		img2pdf --dpi "$DPI" --output "$PDF_PATH" "${IMAGES[@]}"
	elif command -v magick >/dev/null 2>&1; then
		magick "${IMAGES[@]}" -units PixelsPerInch -density "$DPI" -compress Zip "$PDF_PATH"
	elif command -v convert >/dev/null 2>&1; then
		convert "${IMAGES[@]}" -units PixelsPerInch -density "$DPI" -compress Zip "$PDF_PATH"
	else
		die "no img2pdf or ImageMagick found for creating the PDF (use --no-pdf to skip it)"
	fi
	log "Wrote the PDF to $PDF_PATH"
fi
