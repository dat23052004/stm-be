# Source code rules

- Read root `AGENTS.md` and `docs/architecture.md`.
- Domain: entities, value objects and business invariants; no ASP.NET Core or EF Core dependency.
- Application: feature use cases, DTOs and ports; reference Domain only.
- Infrastructure: persistence and external services implementing Application ports.
- Api: controllers, HTTP contracts, middleware, configuration and dependency injection composition root.
- Add folders by actual need. Empty layer scaffolds do not imply implemented features.
- Prefer constructor injection, explicit lifetimes, async I/O and cancellation propagation.
- Use standard ASP.NET Core validation for HTTP input; enforce business invariants separately.
- Inject TimeProvider when business logic requires time. Do not introduce an abstraction for every class.
- Keep configuration out of business code and secrets out of committed settings.
- Add dependencies centrally in `Directory.Packages.props` with a reason in the change description.
- For persistence, decide provider, transaction boundary and test isolation before adding migrations.
- Never auto-run migrations/seed against production as part of application startup.
