# Test rules

- Read root `AGENTS.md` and `docs/testing/strategy.md`.
- Unit tests isolate logic without network, real DB or host startup; xUnit, AAA, deterministic inputs.
- Integration tests use WebApplicationFactory for the HTTP pipeline; isolate any future DB per run.
- Architecture tests guard project-reference direction. They do not prove business correctness.
- Test public behavior, regression risks, boundary/error cases; avoid trivial getters and mirrored implementation.
- Test method naming: `Method_WhenCondition_ExpectedBehavior`.
- For unit tests add `Trait("Type", "Normal|Boundary|Abnormal")` where applicable.
- Prefer small fakes; add mocking libraries only when useful for the task.
- Never use fixed sleeps, external services, production secrets, or shared mutable state in unit tests.
- Test-only routes belong in the test assembly, never in production controllers.
- Store generated TRX/coverage under `artifacts/test-results/`, which is ignored by Git.
- Report actual run counts and failures. Manual cases start `NotRun`, never `Passed` by assumption.
