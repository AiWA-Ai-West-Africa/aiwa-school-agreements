#!/usr/bin/env bash
# .github/scripts/build-documents.sh
#
# Converts all substantive AIWA Markdown documents to PDF and DOCX.
# Mirrors the source directory structure under dist/.
#
# Usage (from repo root):
#   bash .github/scripts/build-documents.sh
#
# Optional:
#   - Place a branded templates/reference/reference.docx to apply AIWA Word styling.
#   - The Eisvogel LaTeX template (if installed) is used automatically for richer PDFs.

set -euo pipefail

# ── Directories containing publishable documents ─────────────────────────────
# README.md files are excluded from all directories.
DOCUMENT_DIRS=(
  "contracts/templates"
  "forms"
  "policies"
  "governance"
  "programs"
  "templates/letters"
)

# ── Optional reference DOCX template ─────────────────────────────────────────
REFERENCE_DOC_OPT=()
if [ -f "templates/reference/reference.docx" ]; then
  REFERENCE_DOC_OPT=(--reference-doc "templates/reference/reference.docx")
  echo "ℹ Using reference DOCX template: templates/reference/reference.docx"
fi

# ── Optional Eisvogel PDF template ────────────────────────────────────────────
EISVOGEL_OPT=()
EISVOGEL_PATH="$HOME/.local/share/pandoc/templates/eisvogel.latex"
if [ -f "$EISVOGEL_PATH" ]; then
  EISVOGEL_OPT=(--template eisvogel
    --metadata "titlepage=false"
    --metadata "disable-header-and-footer=false"
    --metadata "book=false"
  )
  echo "ℹ Using Eisvogel PDF template"
else
  echo "ℹ Eisvogel not found — using Pandoc default PDF template"
fi

# ── Common metadata ───────────────────────────────────────────────────────────
AUTHOR="AI West Africa (AIWA)"
BUILD_DATE="$(date '+%B %Y')"
FORM_FILTER=".github/scripts/pandoc-form-compact.lua"
FORM_DOCX_FILTER=".github/scripts/pandoc-form-docx.lua"
FORM_LATEX_HEADER=".github/scripts/form-pdf-header.tex"
FORM_REFERENCE_DOCX=""

font_available() {
  local font_name="$1"

  if ! command -v fc-match >/dev/null 2>&1; then
    return 1
  fi

  [ "$(fc-match -f '%{family[0]}\n' "$font_name" 2>/dev/null | head -n1)" = "$font_name" ]
}

pick_font() {
  local preferred="$1"
  local fallback="$2"

  if font_available "$preferred"; then
    echo "$preferred"
  else
    echo "$fallback"
  fi
}

FORM_MAINFONT="$(pick_font "Noto Sans" "Liberation Sans")"
FORM_MONOFONT="$(pick_font "Noto Sans Mono" "Liberation Mono")"

is_form_document() {
  local md_file="$1"
  [[ "$md_file" == forms/* ]]
}

prepare_form_reference_docx() {
  if ! command -v pandoc >/dev/null 2>&1; then
    return
  fi

  local tmp_docx
  tmp_docx="$(mktemp --suffix=.docx)"

  # Start from Pandoc's default reference document so form-specific styles
  # such as Body Text, Compact, and list variants remain available.
  if ! pandoc --print-default-data-file reference.docx > "$tmp_docx"; then
    if [ -f "templates/reference/reference.docx" ]; then
      cp "templates/reference/reference.docx" "$tmp_docx"
    else
      rm -f "$tmp_docx"
      return
    fi
  fi

  if ! FORM_DOCX_FONT="$FORM_MAINFONT" FORM_DOCX_MONOFONT="$FORM_MONOFONT" \
    python - "$tmp_docx" <<'PY'
import os
import shutil
import tempfile
import zipfile
import xml.etree.ElementTree as ET

path = os.path.abspath(__import__('sys').argv[1])
ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
W = '{%s}' % ns['w']
FORM_FONT = os.environ.get('FORM_DOCX_FONT', 'Noto Sans')
FORM_MONOFONT = os.environ.get('FORM_DOCX_MONOFONT', 'Noto Sans Mono')

with zipfile.ZipFile(path, 'r') as zin:
    blobs = {name: zin.read(name) for name in zin.namelist()}

styles_xml = blobs.get('word/styles.xml')
doc_xml = blobs.get('word/document.xml')
if styles_xml is None or doc_xml is None:
    raise SystemExit(1)

styles_root = ET.fromstring(styles_xml)
doc_root = ET.fromstring(doc_xml)

def ensure_child(parent, tag):
    child = parent.find(f'w:{tag}', ns)
    if child is None:
        child = ET.SubElement(parent, W + tag)
    return child

def find_style(style_id):
    return styles_root.find(f".//w:style[@w:styleId='{style_id}']", ns)

def set_fonts(rpr, font_name, monofont=False):
    fonts = ensure_child(rpr, 'rFonts')
    fonts.set(W + 'ascii', font_name)
    fonts.set(W + 'hAnsi', font_name)
    fonts.set(W + 'cs', font_name)
    if monofont:
        fonts.set(W + 'eastAsia', font_name)

def set_size(rpr, size):
    sz = ensure_child(rpr, 'sz')
    sz.set(W + 'val', str(size))
    szcs = ensure_child(rpr, 'szCs')
    szcs.set(W + 'val', str(size))

def set_spacing(ppr, before=None, after=None, line=None):
    spacing = ensure_child(ppr, 'spacing')
    if before is not None:
        spacing.set(W + 'before', str(before))
    if after is not None:
        spacing.set(W + 'after', str(after))
    if line is not None:
        spacing.set(W + 'line', str(line))
        spacing.set(W + 'lineRule', 'auto')

def set_color(rpr, color):
    color_el = ensure_child(rpr, 'color')
    color_el.set(W + 'val', color)

def set_bold(rpr):
    ensure_child(rpr, 'b')
    ensure_child(rpr, 'bCs')

def clear_paragraph_border(ppr):
    border = ppr.find('w:pBdr', ns)
    if border is not None:
        ppr.remove(border)

doc_defaults = styles_root.find('w:docDefaults', ns)
if doc_defaults is None:
    doc_defaults = ET.SubElement(styles_root, W + 'docDefaults')
rpr_default = doc_defaults.find('w:rPrDefault', ns)
if rpr_default is None:
    rpr_default = ET.SubElement(doc_defaults, W + 'rPrDefault')
rpr = ensure_child(rpr_default, 'rPr')
set_fonts(rpr, FORM_FONT)
set_size(rpr, 20)

for style_id, size, before, after, line, color in [
    ('Normal', 20, 0, 40, 264, None),
    ('BodyText', 20, 0, 40, 264, None),
    ('BodyText2', 20, 0, 40, 264, None),
    ('FirstParagraph', 20, 0, 40, 264, None),
    ('ListParagraph', 20, 0, 20, 240, None),
    ('Compact', 18, 0, 10, 220, None),
]:
    style = find_style(style_id)
    if style is None:
        continue
    style_rpr = ensure_child(style, 'rPr')
    set_fonts(style_rpr, FORM_FONT)
    set_size(style_rpr, size)
    if color:
        set_color(style_rpr, color)
    style_ppr = ensure_child(style, 'pPr')
    set_spacing(style_ppr, before=before, after=after, line=line)

for style_id, size, before, after, color in [
    ('Title', 28, 0, 100, '000000'),
    ('Heading1', 24, 100, 60, '000000'),
    ('Heading2', 22, 80, 40, '000000'),
    ('Heading3', 20, 60, 30, '000000'),
    ('Heading4', 20, 50, 24, '000000'),
    ('Subtitle', 20, 0, 50, '000000'),
]:
    style = find_style(style_id)
    if style is None:
        continue
    style_rpr = ensure_child(style, 'rPr')
    set_fonts(style_rpr, FORM_FONT)
    set_size(style_rpr, size)
    set_bold(style_rpr)
    set_color(style_rpr, color)
    style_ppr = ensure_child(style, 'pPr')
    clear_paragraph_border(style_ppr)
    ensure_child(style_ppr, 'keepNext')
    set_spacing(style_ppr, before=before, after=after, line=240)

for style_id in ('SourceCode', 'VerbatimChar', 'CodeBlock'):
    style = find_style(style_id)
    if style is None:
        continue
    style_rpr = ensure_child(style, 'rPr')
    set_fonts(style_rpr, FORM_MONOFONT, monofont=True)

for sect in doc_root.findall('.//w:sectPr', ns):
    pg_sz = ensure_child(sect, 'pgSz')
    pg_sz.set(W + 'w', '11906')
    pg_sz.set(W + 'h', '16838')

    pg_mar = ensure_child(sect, 'pgMar')
    for attr, value in {
        'top': '709',
        'right': '709',
        'bottom': '709',
        'left': '709',
        'header': '340',
        'footer': '340',
        'gutter': '0',
    }.items():
        pg_mar.set(W + attr, value)

    cols = ensure_child(sect, 'cols')
    cols.set(W + 'num', '1')
    cols.set(W + 'space', '360')

blobs['word/styles.xml'] = ET.tostring(styles_root, encoding='utf-8', xml_declaration=True)
blobs['word/document.xml'] = ET.tostring(doc_root, encoding='utf-8', xml_declaration=True)

fd, tmppath = tempfile.mkstemp(suffix='.docx')
os.close(fd)
try:
    with zipfile.ZipFile(tmppath, 'w', compression=zipfile.ZIP_DEFLATED) as zout:
        for name, data in blobs.items():
            zout.writestr(name, data)
    shutil.move(tmppath, path)
finally:
    if os.path.exists(tmppath):
        os.remove(tmppath)
PY
  then
    rm -f "$tmp_docx"
    return
  fi

  FORM_REFERENCE_DOCX="$tmp_docx"
}

cleanup() {
  if [ -n "$FORM_REFERENCE_DOCX" ] && [ -f "$FORM_REFERENCE_DOCX" ]; then
    rm -f "$FORM_REFERENCE_DOCX"
  fi
}
trap cleanup EXIT

prepare_form_reference_docx
if [ -n "$FORM_REFERENCE_DOCX" ]; then
  echo "ℹ Using generated form DOCX reference template"
fi

echo "ℹ Form PDF font: $FORM_MAINFONT"
echo "ℹ Form monospace font: $FORM_MONOFONT"

# ── PDF build ─────────────────────────────────────────────────────────────────
build_pdf() {
  local md_file="$1" out_file="$2" title="$3" is_form="$4"
  local -a pandoc_args=(
    "$md_file"
    --standalone
    --pdf-engine=xelatex
    -V colorlinks=true
    -V linkcolor=NavyBlue
    -V urlcolor=NavyBlue
    -V toccolor=NavyBlue
  )

  if [ "$is_form" = true ]; then
    pandoc_args+=(
      --lua-filter "$FORM_FILTER"
      --lua-filter "$FORM_DOCX_FILTER"
      -H "$FORM_LATEX_HEADER"
      -V mainfont="$FORM_MAINFONT"
      -V sansfont="$FORM_MAINFONT"
      -V monofont="$FORM_MONOFONT"
      -V geometry:margin=1.25cm
      -V fontsize=10pt
      -V linestretch=1.05
    )
  else
    pandoc_args+=(
      --toc
      --toc-depth=3
      --metadata "title=$title"
      --metadata "author=$AUTHOR"
      --metadata "date=$BUILD_DATE"
      -V mainfont="Liberation Serif"
      -V sansfont="Liberation Sans"
      -V monofont="Liberation Mono"
      -V geometry:margin=2.5cm
    )
  fi

  pandoc "${pandoc_args[@]}" \
    "${EISVOGEL_OPT[@]}" \
    -o "$out_file"
}

# ── DOCX build ────────────────────────────────────────────────────────────────
build_docx() {
  local md_file="$1" out_file="$2" title="$3" is_form="$4"
  local -a pandoc_args=(
    "$md_file"
    --standalone
  )

  if [ "$is_form" = true ]; then
    pandoc_args+=(
      --lua-filter "$FORM_FILTER"
      --lua-filter "$FORM_DOCX_FILTER"
    )
    if [ -n "$FORM_REFERENCE_DOCX" ] && [ -f "$FORM_REFERENCE_DOCX" ]; then
      pandoc_args+=(--reference-doc "$FORM_REFERENCE_DOCX")
    elif [ "${#REFERENCE_DOC_OPT[@]}" -gt 0 ]; then
      pandoc_args+=("${REFERENCE_DOC_OPT[@]}")
    fi
  else
    pandoc_args+=(
      --toc
      --toc-depth=3
      --metadata "title=$title"
      --metadata "author=$AUTHOR"
      --metadata "date=$BUILD_DATE"
      "${REFERENCE_DOC_OPT[@]}"
    )
  fi

  pandoc "${pandoc_args[@]}" \
    -o "$out_file"
}

# ── Extract title from the first H1 heading ───────────────────────────────────
extract_title() {
  local md_file="$1"
  local title
  title=$(grep -m1 '^# ' "$md_file" | sed 's/^# //' || true)
  if [ -z "$title" ]; then
    # Fall back to filename: strip path, extension, and version suffix
    title=$(basename "${md_file%.md}" \
      | sed 's/-v[0-9][0-9]*\.[0-9][0-9]*$//' \
      | tr '-' ' ')
  fi
  echo "$title"
}

# ── Main build loop ───────────────────────────────────────────────────────────
success_count=0
fail_count=0
failed_files=()

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║          AIWA Document Build — PDF + DOCX                ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

for dir in "${DOCUMENT_DIRS[@]}"; do
  [ -d "$dir" ] || continue

  while IFS= read -r md_file; do
    out_base="dist/${md_file%.md}"
    mkdir -p "$(dirname "$out_base")"

    title="$(extract_title "$md_file")"
    is_form=false
    if is_form_document "$md_file"; then
      is_form=true
    fi

    echo "▶  $md_file"
    echo "   Title: $title"

    pdf_ok=true
    docx_ok=true

    if ! build_pdf "$md_file" "${out_base}.pdf" "$title" "$is_form" \
         2>"${out_base}.pdf.log"; then
      echo "   ⚠  PDF failed — see ${out_base}.pdf.log"
      pdf_ok=false
    fi

    if ! build_docx "$md_file" "${out_base}.docx" "$title" "$is_form" \
         2>"${out_base}.docx.log"; then
      echo "   ⚠  DOCX failed — see ${out_base}.docx.log"
      docx_ok=false
    fi

    if $pdf_ok && $docx_ok; then
      echo "   ✓  PDF + DOCX generated"
      success_count=$(( success_count + 1 ))
    else
      failed_files+=("$md_file")
      fail_count=$(( fail_count + 1 ))
    fi

    echo ""
  done < <(find "$dir" -name "*.md" ! -name "README.md" | sort)
done

# ── Summary ───────────────────────────────────────────────────────────────────
echo "══════════════════════════════════════════════════════════"
echo "  Build complete: ${success_count} succeeded, ${fail_count} failed"

if [ "${fail_count}" -gt 0 ]; then
  echo ""
  echo "  Failed documents:"
  for f in "${failed_files[@]}"; do
    echo "    ✗  $f"
  done
  echo ""
  echo "  Check the .log files in dist/ for details."
  exit 1
fi
