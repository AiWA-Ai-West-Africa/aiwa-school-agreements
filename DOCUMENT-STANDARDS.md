# DOCUMENT-STANDARDS.md — Document Naming, Versioning, and Formatting Standards

**AI West Africa (AIWA) — School Pilot Framework**
Version 1.0 | Effective Date: 1 May 2025

---

## 1. Purpose

This document defines the naming conventions, version numbering system, date formatting
standards, school identifiers, and archival standards used across all materials in the
AIWA School Pilot Framework repository.

Consistent application of these standards ensures that documents are easy to locate,
understand, and maintain across multiple schools, programmes, and years of operation.

---

## 2. File Naming Conventions

### 2.1 General Format

All files must follow this naming convention:

```
[category]-[descriptor]-[modifier]-[version].[extension]
```

- All components are **lowercase**, except any `[SCHOOL_ID]` segment, which must follow the official school identifier standard (for example, `BJL-PRI-001`)
- Words are separated by **hyphens** (not underscores or spaces)
- Version numbers always use the `v` prefix
- Do not include dates in template file names (use the document header instead)

### 2.2 Category Codes

| Code | Document Category |
|---|---|
| `contract` | Formal agreements and partnership contracts |
| `policy` | Institutional policies |
| `form` | Contributor-facing forms |
| `program` | Programme plans and documentation |
| `template` | General reusable templates |
| `letter` | Official correspondence |
| `certificate` | Certificates of participation or achievement |
| `schedule` | Pilot or programme timetables |
| `guidance` | Guidance notes and reference materials |
| `mou` | Memoranda of Understanding |

### 2.3 Naming Examples

| Document | File Name |
|---|---|
| School pilot agreement template | `contract-school-pilot-agreement-v1.0.md` |
| Parent consent form | `form-parent-consent-v2.1.md` |
| Student safeguarding policy | `policy-student-safeguarding-v1.0.md` |
| Media release form | `form-media-release-v1.2.md` |
| Programme overview letter | `letter-programme-overview-v1.0.md` |
| Workshop facilitator guide | `guidance-workshop-facilitator-v1.0.md` |
| Junior Publishing Fellowship MOU | `mou-junior-publishing-fellowship-v1.0.md` |

### 2.4 Executed Document Naming

Executed (signed) documents are named with a school identifier and execution date:

```
[category]-[SCHOOL_ID]-[YYYY-MM-DD]-executed.[extension]
```

Example:
```
contract-BJL-PRI-001-2025-03-15-executed.pdf
form-parent-consent-BJL-PRI-001-2025-03-15-executed.pdf
```

---

## 3. School Identifiers

Each partner school is assigned a unique identifier using the following format:

```
[REGION_CODE]-[SCHOOL_TYPE]-[SEQUENCE_NUMBER]
```

### Region Codes

| Code | Region |
|---|---|
| `BJL` | Banjul (City) |
| `WCR` | West Coast Region |
| `NBR` | North Bank Region |
| `LRR` | Lower River Region |
| `CRR` | Central River Region |
| `URR` | Upper River Region |

### School Type Codes

| Code | School Type |
|---|---|
| `PRI` | Primary School |
| `SEC` | Secondary School (including Senior Secondary) |
| `JUN` | Junior Secondary School |
| `MAD` | Madrassa |
| `COM` | Community Learning Centre |

### Examples

| Identifier | Meaning |
|---|---|
| `BJL-PRI-001` | First primary school partner in Banjul |
| `WCR-SEC-003` | Third secondary school partner in West Coast Region |
| `NBR-JUN-002` | Second junior secondary school partner in North Bank Region |

---

## 4. Version Numbering

All documents follow a **Major.Minor** versioning scheme.

### 4.1 Version Types

| Change Type | Effect | Example |
|---|---|---|
| **Minor change** — formatting, wording clarity, non-legal corrections | Increment minor number | v1.0 → v1.1 |
| **Moderate change** — new clauses, structural additions, updated references | Increment minor number | v1.2 → v1.3 |
| **Major change** — fundamental terms altered, legal review required | Increment major number, reset minor | v1.3 → v2.0 |

### 4.2 Version Rules

- All documents begin at `v1.0`
- Minor version numbers range from `.0` to `.9` before incrementing the major version
  (though a new major version may be issued earlier if the changes warrant it)
- Each version must be documented in the document's **Change Log** section
- Superseded versions must be moved to the relevant `/archive` folder before the new version
  is committed in its place

---

## 5. Date Formatting

All dates in documents must use the following format:

```
DD Month YYYY
```

Examples:
- `15 March 2025`
- `1 September 2026`

In file names and metadata fields, use ISO 8601 format:

```
YYYY-MM-DD
```

Example: `2025-03-15`

**Do not use** ambiguous date formats such as `03/15/25` or `15/03/25`.

---

## 6. Document Header Standard

Every document must include a header block immediately following the document title:

```markdown
**Document Type:** [Template / Policy / Form / Agreement / Guidance / Letter / Certificate]
**Version:** [e.g., v1.0]
**Status:** [Draft / Under Review / Approved / Archived]
**Last Reviewed:** [DD Month YYYY]
**Approved By:** [Role title — do not use personal names in templates]
**Applies To:** [e.g., All Pilot Schools / Parent and Guardian Participants / Partner Organisations]
**Jurisdiction:** The Republic of The Gambia
```

> **Guidance on "Approved By" by status:**
> - **Draft / Under Review:** Set `Approved By` to `Pending — [Intended Approver Role]` (e.g., `Pending — Programme Director`). This makes clear that approval has not yet been granted and avoids misrepresenting a draft as an approved document.
> - **Approved:** Replace with the approver's role title (e.g., `Programme Director`). Do not use personal names.
> - **Archived:** Retain the role title of the approver from when the document was last approved.

---

## 7. Change Log Standard

Every document must include a Change Log section at the end:

```markdown
## Change Log

| Version | Date | Changed By | Summary of Changes |
|---|---|---|---|
| v1.0 | [DD Month YYYY] | [Role] | Initial version |
| v1.1 | [DD Month YYYY] | [Role] | [Brief description] |
```

---

## 8. Archival Standards

### 8.1 When to Archive

A document must be moved to the appropriate `/archive` folder when:

- It has been superseded by a new approved version
- It has expired (contract term ended, consent period lapsed)
- The programme it relates to has concluded
- It has been formally withdrawn or invalidated

### 8.2 Archival File Naming

Archived files retain their original name and add an `-archived-[YYYY-MM-DD]` suffix:

```
contract-school-pilot-agreement-v1.0-archived-2026-08-31.md
```

### 8.3 Retention

Archived documents must not be deleted from the repository. They serve as the institutional
record. Executed documents involving children must be retained for a minimum period in
accordance with applicable Gambian law and AIWA's Data Governance Policy.

---

## 9. File Formats

| Use Case | Preferred Format |
|---|---|
| Templates and working documents | Markdown (`.md`) |
| Executed agreements (signed) | PDF (`.pdf`) |
| Reference materials | PDF or Markdown |
| Certificates (issued) | PDF (`.pdf`) |
| Correspondence (sent) | PDF (`.pdf`) |

Templates in Markdown format should be converted to PDF for execution/signing unless a
digital signature workflow is in place.

---

*Maintained by: AI West Africa (AIWA) | Effective: 1 May 2025*
