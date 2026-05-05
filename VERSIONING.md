# VERSIONING.md — Document Versioning Strategy

**AI West Africa (AIWA) — School Pilot Framework**
Version 1.0 | Effective Date: 1 May 2025

---

## 1. Purpose

This document defines how versions are assigned, tracked, and managed for all documents
in the AIWA School Pilot Framework, including contract templates, consent forms, and policies.

A consistent versioning strategy ensures that:

- Everyone is working from the current approved version of a document
- Changes are traceable and auditable
- Superseded versions are preserved rather than lost
- Partners and schools can be confidently informed when a document they hold has been updated

---

## 2. Version Number Format

All AIWA documents use a **Major.Minor** versioning scheme:

```
v[MAJOR].[MINOR]
```

Examples: `v1.0`, `v1.3`, `v2.0`

---

## 3. Versioning Rules by Change Type

### 3.1 Minor Version Increment (x.1, x.2, etc.)

Increment the minor version when changes are:

- Corrections to spelling, grammar, or typographical errors
- Clarification of existing wording without changing meaning
- Formatting improvements
- Updates to non-binding reference information (e.g., contact details)
- Addition of guidance notes that do not alter obligations

**No formal legal review required for minor version increments.**

### 3.2 Moderate Version Increment

Increment the minor version (with a note of significance) when changes include:

- Addition of new clauses or sections that do not alter existing obligations
- Updates to schedules or annexures
- Changes to timelines or procedural steps
- Updates required by regulatory or policy changes that do not alter fundamental terms

**Internal review required. Approval by Programme Coordinator or above.**

### 3.3 Major Version Increment (2.0, 3.0, etc.)

Increment the major version when changes include:

- Changes to fundamental legal terms or obligations
- Changes affecting contributor rights or safeguarding provisions
- Changes arising from a legal review or court/regulatory guidance
- Structural redesign of the document
- Any change to a safeguarding form or child protection policy

**Formal legal review strongly recommended. Approval by Programme Director required.**

---

## 4. Version Management by Document Category

### 4.1 Contract Templates

| Version Stage | Description |
|---|---|
| `v1.0` | First approved release |
| `v1.x` | Minor amendments, formatting, and non-legal updates |
| `v2.0+` | Legal terms changed, new programme structure, or regulatory update |

Active template is held in `/contracts/templates/`.
Superseded versions are archived in `/contracts/archive/`.

### 4.2 Consent Forms (Parent, Student, Media, Interview)

Consent forms require particular care because changes may affect the validity of consent
previously collected.

| Version Stage | Description |
|---|---|
| `v1.0` | First approved release |
| `v1.x` | Minor wording clarifications, formatting |
| `v2.0+` | Any change affecting the substance of what participants are consenting to |

**When a consent form reaches a new major version**, the Safeguarding Lead must determine
whether previously collected consent under the old version remains valid or whether
re-consent is required.

Active forms are held in the relevant `/forms/` subfolder.
Superseded forms are archived in `/archive/`.

### 4.3 Institutional Policies

| Version Stage | Description |
|---|---|
| `v1.0` | First approved policy release |
| `v1.x` | Minor updates: references, contact details, procedural clarifications |
| `v2.0+` | Substantive policy change, new regulatory requirement, structural reform |

Policies are subject to the mandatory annual review cycle.
Active policies are held in the relevant `/policies/` subfolder.
Superseded policies are archived in `/archive/`.

---

## 5. Version Control Process

### Step 1: Identify the change type
Determine whether the change warrants a minor or major version increment using Section 3.

### Step 2: Update the document header
Update the `Version` and `Last Reviewed` fields in the document header.

### Step 3: Update the Change Log
Add a row to the Change Log at the end of the document:

```
| v1.1 | 15 March 2025 | Programme Coordinator | Updated school contact details section |
```

### Step 4: Archive the previous version
Before committing the updated version, move the previous version to the appropriate
`/archive` folder with the archival naming convention:

```
[original-filename]-archived-[YYYY-MM-DD].[ext]
```

### Step 5: Commit the new version
Commit the new version to the main branch with a clear commit message:

```
Update contract-school-pilot-agreement to v1.1 — minor contact detail update
```

### Step 6: Notify relevant parties
If the update affects documents currently in use by schools or participants, notify the
relevant School Liaison Officer so that partners can be informed.

---

## 6. Draft and Pre-Release Versioning

Documents that are still in preparation use the following status markers:

| Status | Meaning |
|---|---|
| `Draft` | Working document, not yet reviewed |
| `Under Review` | Circulated for internal review, not yet approved |
| `Approved` | Formally approved and ready for use |
| `Archived` | Superseded, retained for record purposes |

Draft documents may carry a draft version indicator:

```
v1.0-draft
v1.0-draft2
```

Upon formal approval, the `-draft` suffix is removed.

---

## 7. Version Register

A version register for key documents is maintained in each folder's `README.md` or
as a standalone `VERSION-REGISTER.md` file at the root of major subfolders.

Example register format:

| Document | Current Version | Status | Last Reviewed | Approved By |
|---|---|---|---|---|
| `contract-school-pilot-agreement` | v1.2 | Approved | 1 March 2025 | Programme Director |
| `form-parent-consent` | v2.0 | Approved | 15 January 2025 | Safeguarding Lead |
| `policy-student-safeguarding` | v1.0 | Approved | 1 September 2024 | Programme Director |

---

*Maintained by: AI West Africa (AIWA) | Effective: 1 May 2025*
