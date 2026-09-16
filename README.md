# LabX Backend

Base ASP.NET Core Web API `net9.0`, tổ chức theo Clean Architecture nhẹ và có quy trình phát triển với agent.
Mở `LabX_Be.sln` từ thư mục này trong Visual Studio, hoặc mở cả thư mục bằng Codex.

## Chạy nhanh

Cần .NET SDK theo `global.json` (9.0.300 hoặc bản vá mới hơn cùng feature band)
và truy cập NuGet để restore/audit.

```powershell
./scripts/verify.ps1
./scripts/smoke-test.ps1
dotnet run --project src/Api --launch-profile http
```

- API: `http://localhost:5033/`.
- OpenAPI JSON: `http://localhost:5033/openapi/v1.json` (Development; chưa có Swagger UI).
- Health: `/health`, `/health/live`, `/health/ready`.
- Dừng API: `Ctrl+C`.
- Một lệnh locked restore/NuGet audit/format/build/test/coverage: `./scripts/verify.ps1`.
- Kiểm tra tiến trình HTTP thật sau khi build Release: `./scripts/smoke-test.ps1`.
- Quét dependency/secret/image: [hướng dẫn kiểm tra](docs/guides/verification.md).

## Cấu trúc

```text
LabX_Be.sln
src/
  Api/                     HTTP, middleware, config, DI
  Application/             DTOs, interfaces, services, validators, mappings
  Domain/                  Entities, value objects, business rules
  Infrastructure/          Persistence và external adapters
tests/
  UnitTests/               Project test unit, chưa có test case
  IntegrationTests/        Project test integration, chưa có test case
  ArchitectureTests/       Project test kiến trúc, chưa có test case
docs/                     Context, hướng dẫn, ADR, API, test strategy, templates
scripts/                  Verify, HTTP smoke test và security scan
.codex/agents/            Custom subagents cho backend, SDS và testing
.agents/skills/           Skills cho backend, API, database, debugging, review, SDS và testing
.github/workflows/        Build/test trên GitHub Actions
AGENTS.md                 Hướng dẫn dùng chung cho agent
```

Đã tạo sẵn các thư mục nền trong bốn layer; xem [cấu trúc chi tiết](docs/architecture.md#cấu-trúc-thư-mục-nền).
Các thư mục code đã được tạo theo mẫu phân loại trách nhiệm; SDS, system test và handoff được tạo khi có nội dung thực tế.
`bin/`, `obj/` và `artifacts/` là output tự sinh khi build/test, có thể xóa và tạo lại.

## Làm việc với agent

Đọc [quy trình và prompt mẫu](docs/guides/agent-workflow.md), bắt đầu từ [bối cảnh dự án](docs/project-context.md).

- Codex tự đọc `AGENTS.md` ở root và file scoped trong `src/`, `tests/` hoặc `docs/`.
- Custom subagents `backend_development`, `software_design_specification` và `testing`
  được đăng ký ở `.codex/agents/`.
- Skills trong `.agents/skills/` được Codex phát hiện tự động; có thể gọi bằng `$skill-name`.
- Ví dụ: `Dùng testing subagent để viết integration test cho API foundation` hoặc
  `$backend-development implement requirement tôi cung cấp`.
- Không cần tài khoản API, plugin riêng hay package AI để sử dụng bộ hướng dẫn này.
- Agent **Backend Development** dùng `backend-development`, `api-development`, `database-development`,
  `backend-debugging` hoặc `code-review`; xem prompt mẫu trong hướng dẫn trên.

## Cấu hình

Đọc [hướng dẫn cấu hình](docs/guides/configuration.md). CORS mặc định đóng; Development cho phép
`http://localhost:3000` và `http://localhost:5173`. Production/Staging đặt origin qua biến môi trường.
Chỉ tạo thêm `appsettings.{Environment}.json` khi cần override; `dotnet run` không tự đọc `.env`.

```powershell
docker compose up --build
```

Docker dùng cổng `8080` và môi trường Production mặc định; xem `/health`. Đây là container API,
chưa kèm database. Hạ container bằng `docker compose down` khi dùng xong.

## Phạm vi hiện tại

Đã có solution, HTTP pipeline nền, cấu hình môi trường, ba project test trống, CI, Docker và bộ agent/tài liệu.
Chưa có use case nghiệp vụ hoặc test case; source đang ở trạng thái base để bắt đầu phát triển tính năng thật.
Chưa chọn database, authentication/authorization, storage/email, frontend hoặc mô hình nghiệp vụ LabX.
Giữ .NET 9 theo yêu cầu; chưa khởi tạo Git hoặc kết nối source hosting.
Workflow CI và Dependabot là cấu hình chuẩn bị sẵn, chưa phải bằng chứng đã chạy trên GitHub.
Các quyết định này được theo dõi trong [project context](docs/project-context.md); không sao chép nghiệp vụ AuLac.

Xem [kiến trúc](docs/architecture.md), [chiến lược test](docs/testing/strategy.md) và
[quyết định base](docs/adr/0001-backend-foundation.md).
