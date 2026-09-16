# Bối cảnh LabX

## Mục tiêu

Tạo nền dự án có cấu trúc rõ ràng, dễ bàn giao giữa agent làm yêu cầu, tài liệu, code, test và review.
Yêu cầu hiện tại là setup base; chưa có đặc tả nghiệp vụ LabX.
Các flow minh họa và test case đã được gỡ để repository trở về nền ban đầu.

## Dữ kiện và quyết định hiện tại

- Project gốc là ASP.NET Core Web `net9.0`, một endpoint Hello World.
- Giữ target .NET 9 theo yêu cầu; SDK local tối thiểu 9.0.300, runtime và ASP.NET Core 9.0.20.
  Docker builder tiếp tục dùng SDK 9.0.318 đã ghim; workspace dùng SDK cài toàn máy.
- Solution `LabX_Be.sln`; application source ở `src/`, tests ở `tests/`.
- Source được chia thư mục theo trách nhiệm như [cấu trúc đã chọn](architecture.md#cấu-trúc-thư-mục-nền):
  Application có DTOs/Interfaces/Services/Validators/Mappings; Infrastructure có Data/Repositories/Services/DependencyInjection.
- Các thư mục test là `tests/UnitTests/`, `tests/IntegrationTests/` và `tests/ArchitectureTests/`.
- Api -> Application/Infrastructure; Application -> Domain; Infrastructure -> Application/Domain.
- Controllers cho feature HTTP; root và health là endpoint kỹ thuật.
- Tên solution giữ nhận diện sản phẩm là `LabX_Be.sln`; project, namespace và class dùng tên không có tiền tố tên sản phẩm.
- Git repository dùng branch `main` và remote GitHub
  [`dat23052004/stm-be`](https://github.com/dat23052004/stm-be). Workflow `build-test` và Dependabot đang hoạt động.
- Dependabot không đề xuất nâng major các Docker image .NET để giữ target .NET 9; các cập nhật khác vẫn phải được
  review và chạy CI trước khi merge.
- Image đã qua CI được publish lên GitHub Container Registry theo commit SHA. CD Linux dùng một VPS, Docker
  Compose, Caddy và hai slot staging/production; tự động deploy vẫn tắt cho tới khi điền server, domain và secrets.
- Có lockfiles, locked restore, NuGet audit toàn bộ dependency, format check và script Trivy.
- ProblemDetails cho lỗi; trace ID ở response/header; CORS lấy từ config; OpenAPI chỉ Development.
- Ba project xUnit đã được cấu hình cho unit, integration và architecture test nhưng hiện chưa có test case/fixture.
- Chưa có database check: `/health/ready` hiện chỉ xác nhận host, chưa xác nhận phụ thuộc bên ngoài.
- Ba Codex custom subagents nằm ở `.codex/agents/`; quy trình chi tiết được Codex phát hiện từ `.agents/skills/`.
- Backend Development chọn các skill backend-development, api-development,
  database-development, backend-debugging và code-review; skill không ngụ ý DB/auth đã được triển khai.

## Quyết định còn mở

- Domain, actors, chức năng và acceptance criteria.
- Database provider, schema, migration và dữ liệu seed.
- Identity provider, JWT/cookie, roles/permissions và các route cần bảo vệ.
- External services, storage, email, cache, background jobs theo nhu cầu thực tế.
- Giá trị thật cho Linux host, domain/DNS, frontend origins, SSH credentials và GitHub Environment protections.
- Đánh giá phiên bản .NET/package và chính sách hỗ trợ trước giai đoạn triển khai.

Các mục trên chưa được triển khai; không coi folder hoặc template là tính năng đã hoàn thành.

## Cách dùng dữ liệu tham khảo

Đã tham khảo bốn file người dùng cung cấp: `DotNetCoreProjectStructure.md`,
`AuLac Software Design Specification agent.agent.md`, `AuLac Testing Agent.agent.md`,
và `au-lac-be-dev.agent.md`.

Áp dụng ý tưởng tách layer, docs/test riêng và agent theo vai trò. Điều chỉnh đường dẫn về LabX,
chuẩn bị project test và quy định phân biệt test plan với kết quả thực thi.
Không kế thừa domain nhà hàng, Excel templates, tool IDs riêng, hoặc quy định chỉ xuất `.puml` cho mọi tài liệu.
File dev mẫu chủ yếu là placeholder; quy tắc development được giữ trong hướng dẫn chung của dự án.
