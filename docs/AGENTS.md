# Documentation rules

- Read root `AGENTS.md` and `docs/project-context.md`.
- Write explanations in Vietnamese; keep real code identifiers and file paths in English.
- Separate implemented behavior, proposed design and open questions explicitly.
- Describe implementation only after reading the corresponding source; link the relevant files.
- Start from `docs/templates/` for requirements, SDS, ADR, tests, reviews and handoffs.
- Use stable requirement IDs and acceptance criteria that a tester can verify.
- For diagrams follow `.agents/skills/software-design-specification/references/diagram-conventions.md`; do not invent classes, DBs or UI pages.
- Keep `.puml` as raw PlantUML, no Markdown fences. Record rendering status honestly.
- A spreadsheet/report template from another project is not available here unless actually supplied.
- Prefer relative links that work on Windows and Linux. Do not embed developer machine paths.
- Do not edit application code during a documentation-only task.
