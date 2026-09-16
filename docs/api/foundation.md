# API foundation — Implemented

Source: `src/Api/Program.cs`, `Extensions/ApiServiceExtensions.cs` và `Middleware/`.
Các đường dẫn source tính từ repository root. Endpoints nền hiện public.

- `GET /`: HTTP 200 JSON `{ "name": "LabX", "status": "running" }`.
- `GET /health`: HTTP 200 text `Healthy` khi các checks đã đăng ký thành công.
- `GET /health/live`: kiểm tra host, bỏ qua dependency checks.
- `GET /health/ready`: chạy các checks đã đăng ký; base chưa có dependency check.
- `GET /openapi/v1.json`: OpenAPI JSON tại Development; Staging/Production trả 404.
- Route không tồn tại: 404 `application/problem+json`.
- Unhandled exception: 500 `application/problem+json`, title chung, không lộ exception details.
- Controller `[ApiController]` với request không hợp lệ: 400 ValidationProblemDetails.

Header `X-Request-Id` được trả ở các response đi qua pipeline; lỗi có `traceId` để đối chiếu log.
CORS Development cho localhost:3000/5173; environment khác mặc định không cho cross-origin.
CORS không phải cơ chế kiểm soát truy cập cho client ngoài browser.

Smoke script kiểm tra các endpoint nền bằng tiến trình HTTP thật. Các project test hiện chưa có test case.
