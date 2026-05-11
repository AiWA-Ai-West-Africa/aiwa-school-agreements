# Reference Document Templates

This folder holds styling templates used during automated document generation.

---

## `reference.docx` — Branded Word Document Template

When this file is present, all DOCX outputs from the automated build will use
its heading styles, fonts, margins, and header/footer instead of Word defaults.
This is the fastest way to apply AIWA branding to every generated document.

### How to create or update `reference.docx`

**Option A — Start from the auto-generated default (recommended)**

1. Run the *Generate Documents* GitHub Actions workflow once (via the Actions tab
   → *Run workflow*).
2. Download the `aiwa-documents-docx-*` artifact.
3. Open any of the generated `.docx` files in Microsoft Word or Google Docs.
4. Modify the paragraph and heading styles, fonts, margins, colours, and header/footer
   to match AIWA branding.
5. Save as **`templates/reference/reference.docx`** and commit the file.

All subsequent builds will use your customised styles automatically.

**Option B — Generate a blank Pandoc reference document locally**

If you have Pandoc installed:

```sh
pandoc --print-default-data-file reference.docx > templates/reference/reference.docx
```

Then open and style it in Word before committing.

### What to customise

| Element | Recommendation |
|---|---|
| **Normal** paragraph style | Set your preferred body font (e.g., Gill Sans, Calibri) |
| **Heading 1–4** styles | Apply AIWA brand colours and weights |
| **First Paragraph** style | Remove indent for first paragraph after headings |
| **Table** style | Match AIWA table styling |
| Header/Footer | Add AIWA logo, document title field, page numbers |
| Page margins | 2.5 cm all sides recommended |

### Further reading

- [Pandoc Manual — `--reference-doc`](https://pandoc.org/MANUAL.html#option--reference-doc)
- [Pandoc DOCX styling guide](https://pandoc.org/MANUAL.html#styling-the-docx-output)
