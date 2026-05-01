# CONTRIBUTING.md — Contribution Guidelines

**AI West Africa (AIWA) — School Pilot Framework**
Version 1.0 | Effective Date: 1 May 2025

---

## 1. Who Should Contribute

This repository is maintained by AI West Africa (AIWA) staff, authorised partners, and
designated institutional collaborators. It is a professional operational repository, not
an open public project.

Contributions may be made by:

- AIWA programme staff creating or updating templates and programme materials
- Legal and policy advisors reviewing and improving governance documents
- Educational partners providing contextual input for school-specific materials
- Safeguarding advisors reviewing and updating child protection materials

If you are uncertain whether you are authorised to contribute, contact the Programme Director
before making any changes.

---

## 2. Institutional Tone and Professionalism

All documents contributed to this repository must maintain a professional, institutional tone
appropriate to legal, educational, and governance contexts in The Gambia and the West African
region.

### Required qualities:

- **Clear and plain language** — Documents must be readable by school principals, parents,
  and community members. Avoid unnecessary legal complexity where plain language serves as well.
- **Cultural sensitivity** — Language must reflect respect for Gambian educational and cultural
  contexts. Avoid assumptions based on non-Gambian frameworks.
- **Precision** — Obligations, rights, timelines, and parties must be stated clearly and
  without ambiguity.
- **Consistency** — Use consistent terminology across related documents. Refer to the
  [Document Standards](DOCUMENT-STANDARDS.md) for defined terms.

### What to avoid:

- Startup or technology company language
- Informal or casual phrasing in formal documents
- Excessive legalese that makes documents inaccessible
- Language that dismisses or undermines participants' rights

---

## 3. Gambian Legal and Educational Context

Contributors must be aware of the legal and regulatory context in which these materials operate:

- Documents involving children must comply with Gambian child protection law and the
  UN Convention on the Rights of the Child
- School partnership agreements should reference the Ministry of Basic and Secondary Education
  (MoBSE) policy frameworks where appropriate
- Data privacy provisions should reflect applicable Gambian legislation and international
  data protection principles
- Publishing agreements must consider both Gambian copyright law and international
  intellectual property frameworks

If you are uncertain about the legal implications of a document you are drafting, consult with
a qualified Gambian legal practitioner before committing the document.

---

## 4. Document Formatting Standards

All documents must follow the standards defined in [DOCUMENT-STANDARDS.md](DOCUMENT-STANDARDS.md).
Key requirements include:

### File Naming

The full naming convention from [DOCUMENT-STANDARDS.md](DOCUMENT-STANDARDS.md) Section 2.1 is:

```
[category]-[descriptor]-[modifier]-[version].[extension]
```

- All components are **lowercase** (except any `[SCHOOL_ID]` segment)
- Words separated by **hyphens**
- `[modifier]` is optional — omit it if not needed
- Version always uses the `v` prefix

Examples:
```
contract-school-pilot-agreement-v1.0.md
form-parent-consent-v2.1.md
policy-student-safeguarding-v1.0.md
```

### Document Header

Every document must begin with a standard header:

```
# [Document Title]

**Document Type:** [Template / Policy / Form / Agreement / Guidance]
**Version:** [e.g., v1.0]
**Status:** [Draft / Under Review / Approved / Archived]
**Last Reviewed:** [DD Month YYYY]
**Approved By:** [Role Title]
**Applies To:** [Schools / Participants / Partners / All]
```

### Placeholders

Use only standard placeholders as defined in [PLACEHOLDER-CONVENTION.md](PLACEHOLDER-CONVENTION.md).
Do not invent new placeholder formats. If a new placeholder is needed, propose it by raising an
issue for discussion before use.

---

## 5. Template Versioning

When modifying an existing template:

1. **Do not overwrite** the previous version without archiving it first
2. Increment the version number according to [VERSIONING.md](VERSIONING.md)
3. Update the `Last Reviewed` date in the document header
4. Record a brief summary of what changed and why in the document's change log section
5. If the change is significant (e.g., legal terms altered), obtain the appropriate approval
   level before committing

See [VERSIONING.md](VERSIONING.md) for full versioning guidance.

---

## 6. Approval Before Committing

The following document categories **must be reviewed and approved** before being committed
to the repository:

| Document Type | Required Approver |
|---|---|
| Safeguarding policies and forms | Safeguarding Lead |
| School partnership agreements | Programme Director |
| Participant consent forms | Safeguarding Lead + Programme Director |
| Publishing and attribution agreements | Publishing Coordinator |
| Governance documents | Programme Director |

Drafted documents should be clearly marked `Status: Draft` until approved. Only approved
documents should be marked `Status: Approved`.

---

## 7. Working with Executed Documents

Executed (signed) documents placed in `/contracts/executed/` must:

- Have all placeholder values fully completed — no blank fields
- Include reference to the relevant template version used
- Be named using the executed document naming convention:
  `[CATEGORY]-[SCHOOL_ID]-[YYYY-MM-DD]-executed.[ext]`
- Not contain sensitive personal data (beyond what is necessary and consented to)

---

## 8. Sensitive Information

Do not commit the following to any public branch of this repository:

- Full names and contact details of minors
- National identification numbers
- Private financial information
- Confidential school administration records

If in doubt, consult the Data Governance Policy in `/governance/data-governance/` before
committing any document containing personal information.

---

## 9. Raising Issues and Proposing Changes

To propose a new document, template, or policy:

1. Describe the need in writing, including the programme context and intended use
2. Draft the document using the closest existing template as a starting point
3. Submit the draft for internal review before committing to the main branch
4. Ensure the document header is complete and status is set to `Draft`

For amendments to governance documents (GOVERNANCE.md, CONTRIBUTING.md, DOCUMENT-STANDARDS.md),
follow the amendment process described in GOVERNANCE.md Section 9.

---

*Thank you for contributing to the AIWA School Pilot Framework. Your work helps build a
lasting, professional foundation for educational development in The Gambia.*

*Maintained by: AI West Africa (AIWA) | Effective: 1 May 2025*
