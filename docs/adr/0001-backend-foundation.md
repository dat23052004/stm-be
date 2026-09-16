# ADR 0001 — Cấu trúc nền backend

- Status: Implemented baseline; các lựa chọn nghiệp vụ còn mở được ghi tại project-context.
- Date: 2026-09-14.
- Update 2026-09-15: giữ .NET 9, nâng SDK lên 9.0.318 và ASP.NET Core/runtime lên 9.0.20;
  thêm lockfiles và kiểm tra dependency/secret/image; sau đó đưa source và test về base trống theo yêu cầu.
- Update 2026-09-16: dùng SDK 9.0.300 cài toàn máy cho local/CI và bỏ các bản SDK, Trivy cục bộ khỏi workspace.
- Context: workspace có ASP.NET Core `net9.0` tối giản; người dùng yêu cầu base phục vụ docs/code/test với agent.

## Decision

Giữ .NET 9 hiện có; pin SDK tối thiểu 9.0.300 với roll-forward bản vá. Tách bốn project Api, Application,
Domain, Infrastructure và ba project UnitTests, IntegrationTests, ArchitectureTests.
Dùng framework ASP.NET Core cho DI, logging, validation, ProblemDetails và health checks.
Package versions quản lý tập trung; các phiên bản được cố định cho scaffold, không ngụ ý là mới nhất.

Ba Codex custom subagents Backend Development, Software Design Specification và Testing nằm ở `.codex/agents/`;
quy trình chi tiết nằm trong `.agents/skills/`. `AGENTS.md` giữ quy tắc chung và định tuyến;
template đầu ra nằm trong `docs/templates/`.

## Consequences

Cấu trúc rõ ràng; các layer nghiệp vụ và project test đang trống, chờ use case thật.
Chưa thêm Shared, repository framework, mapper, mediator, DB, JWT hay external adapter khi chưa có yêu cầu.
Trước deployment cần quyết định phiên bản runtime được hỗ trợ, provider, identity, TLS, host và readiness dependencies.

## Verification

Build Release với warnings-as-errors, các project xUnit trống và HTTP smoke script cho endpoint nền.
Chạy `scripts/verify.ps1` và `scripts/smoke-test.ps1` để xác minh source hiện tại.
TRX/coverage ở `artifacts/test-results/` là output có thể tạo lại, không commit báo cáo setup tĩnh.
