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
FORM_LATEX_HEADER=".github/scripts/form-pdf-header.tex"
FORM_REFERENCE_DOCX=""

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

  # Seed from the branded committed template when present so custom heading
  # styles, margins, and fonts are preserved; fall back to Pandoc's default.
  if [ -f "templates/reference/reference.docx" ]; then
    cp "templates/reference/reference.docx" "$tmp_docx"
  elif ! pandoc --print-default-data-file reference.docx > "$tmp_docx"; then
    rm -f "$tmp_docx"
    return
  fi

  if ! python - "$tmp_docx" <<'PY'
import os
import shutil
import tempfile
import zipfile
import xml.etree.ElementTree as ET

path = os.path.abspath(__import__('sys').argv[1])
ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
W = '{%s}' % ns['w']

with zipfile.ZipFile(path, 'r') as zin:
    blobs = {name: zin.read(name) for name in zin.namelist()}

styles_xml = blobs.get('word/styles.xml')
doc_xml = blobs.get('word/document.xml')
if styles_xml is None or doc_xml is None:
    raise SystemExit(1)

styles_root = ET.fromstring(styles_xml)
normal = styles_root.find(".//w:style[@w:styleId='Normal']", ns)
if normal is not None:
    rpr = normal.find('w:rPr', ns)
    if rpr is None:
        rpr = ET.SubElement(normal, W + 'rPr')
    sz = rpr.find('w:sz', ns)
    if sz is None:
        sz = ET.SubElement(rpr, W + 'sz')
    sz.set(W + 'val', '18')
    szcs = rpr.find('w:szCs', ns)
    if szcs is None:
        szcs = ET.SubElement(rpr, W + 'szCs')
    szcs.set(W + 'val', '18')

doc_root = ET.fromstring(doc_xml)
for sect in doc_root.findall('.//w:sectPr', ns):
    cols = sect.find('w:cols', ns)
    if cols is None:
        cols = ET.SubElement(sect, W + 'cols')
    cols.set(W + 'num', '2')
    cols.set(W + 'space', '560')

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
  echo "ℹ Using generated compact form DOCX reference template"
fi

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
    -V mainfont="Liberation Serif"
    -V sansfont="Liberation Sans"
    -V monofont="Liberation Mono"
  )

  if [ "$is_form" = true ]; then
    pandoc_args+=(
      --lua-filter "$FORM_FILTER"
      -H "$FORM_LATEX_HEADER"
      -V geometry:margin=1.0cm
      -V fontsize=9pt
      -V linestretch=1.0
    )
  else
    pandoc_args+=(
      --toc
      --toc-depth=3
      --metadata "title=$title"
      --metadata "author=$AUTHOR"
      --metadata "date=$BUILD_DATE"
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
