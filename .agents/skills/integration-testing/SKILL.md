---
name: integration-testing
description: Write and run LabX HTTP or infrastructure integration tests. Use for integration test requests involving API routes, middleware, dependency wiring, or persistence with a selected database provider.
---

# Integration Testing

## Đầu vào

Nhận endpoint/feature, acceptance criteria và dependency liên quan. Đọc contract, source pipeline/use case,
fixture liên quan nếu đã có và [chiến lược test](../../../docs/testing/strategy.md).
Phân biệt yêu cầu viết test chạy được với yêu cầu chỉ lập test plan.

## Thực hiện

1. Với HTTP, dùng `WebApplicationFactory<Program>`; tạo fixture trong
   `tests/IntegrationTests/Fixtures/` và test trong `tests/IntegrationTests/Api/` khi bắt đầu feature.
2. Kiểm tra status, response schema/data, validation, headers và middleware/DI liên quan.
   Chỉ thêm auth/permission/concurrency cases khi feature có contract tương ứng.
3. Dùng test-only controllers qua application part khi cần probe pipeline;
   không thêm route phục vụ test vào API được publish.
4. Khi kiểm tra persistence, dùng DB riêng với đúng provider và reset dữ liệu deterministic.
   Base hiện chưa có provider; không tự thêm DB hoặc gọi fake là DB integration test.
   Fake external service có thể dùng để cô lập HTTP suite, nhưng ghi rõ phạm vi chưa được xác minh.
5. Tách configuration/environment để cases không chia sẻ mutable state; kiểm tra cleanup sau chạy.
6. Chạy test mục tiêu rồi suite integration; báo dependency/môi trường bị thiếu nếu không chạy được.

## Lệnh từ repository root

```powershell
dotnet test tests/IntegrationTests/IntegrationTests.csproj -c Release --logger trx --results-directory artifacts/test-results
```

Khi đã có test, có thể thêm filter theo feature; lệnh tự restore/build. Khi chỉ lập plan, dùng
[mẫu test plan](../../../docs/templates/test-plan.md), IDs `IT-{FEATURE}-{nn}`,
lưu `docs/testing/integration/{feature}-plan.md`, trạng thái `NotRun`.

## Đầu ra

Executable tests là mặc định cho yêu cầu viết integration test. Nếu yêu cầu report, dùng
[mẫu report](../../../docs/templates/test-report.md) tại `docs/testing/integration/{feature}-report.md`.
Ghi commands, số Passed/Failed/Skipped, requirement coverage, fixture dependencies và các phần NotRun.

Ví dụ: `integration test API foundation` xác minh health, ProblemDetails, trace ID,
OpenAPI exposure và CORS trong các môi trường đã cấu hình.
