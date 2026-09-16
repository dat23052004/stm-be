---
name: backend-debugging
description: Diagnose and fix a reproducible LabX backend failure using source, logs, configuration, and regression tests. Use for runtime errors, incorrect API behavior, DI failures, build failures, or a demonstrated query/performance regression.
---

# Backend Debugging

## Thiết lập bằng chứng

Nhận bước tái hiện, expected/actual, environment và log/trace ID nếu có.
Đọc [bối cảnh](../../../docs/project-context.md), source/test ở luồng lỗi và config key liên quan.
Kiểm tra SDK/package versions từ repo và command thực tế; không quy mọi lỗi cho source khi nguyên nhân là môi trường.
Nếu chưa tái hiện được, ghi giả thuyết rõ ràng và thu hẹp bằng kiểm tra có thể quan sát.
Không đưa credential, token, connection string hoặc dữ liệu người dùng vào báo cáo/log debug.

## Chọn đường điều tra

- **Build/restore**: tìm lỗi đầu tiên có ý nghĩa, kiểm tra project references, central package versions,
  global.json và access NuGet; không tắt warnings/analyzers hoặc bỏ tests để tạo kết quả xanh.
- **Startup/DI**: kiểm tra registration, constructor, scope và configuration cần có;
  đọc composition root tại `Program.cs` và `ApiServiceExtensions`.
- **HTTP sai response**: nối `X-Request-Id` với trace/log, theo route → binding/validation → use case → adapter.
  Tách lỗi CORS của browser khỏi lỗi authorization hoặc HTTP service.
- **Unhandled exception**: đọc server log quanh trace ID và chuỗi inner exception;
  giữ response lỗi an toàn, không bật trả stack trace cho client để điều tra.
- **DB/query chậm**: chỉ điều tra provider/query nếu đã có persistence; đo timing/query count,
  kiểm tra dữ liệu tái hiện, cancellation, N+1 và transaction trước khi đề xuất cache/index.

Đường dẫn mã hiện có: `src/Api/Middleware/` và các feature/adapter liên quan.
Không thêm endpoint lỗi thử vào API production; dùng test fixture nếu cần.

## Sửa và xác minh

Khi đã có bằng chứng, sửa nguyên nhân trong phạm vi nhỏ nhất và thêm regression test có ý nghĩa
bằng [Unit Testing](../unit-testing/SKILL.md) hoặc [Integration Testing](../integration-testing/SKILL.md).
Nếu yêu cầu chỉ chẩn đoán, báo nguyên nhân/bằng chứng/đề xuất, không tự sửa source.
Với fix, chạy lại bước tái hiện và `./scripts/verify.ps1`; gỡ logging thử không cần giữ.
Lỗi còn phụ thuộc môi trường phải được ghi riêng, không gọi là đã sửa chỉ vì test giả lập pass.

## Bàn giao

Báo nguyên nhân xác nhận hoặc giả thuyết còn lại, file/line liên quan, trigger,
thay đổi đã làm, commands/results và giới hạn kiểm tra. Với performance, kèm số đo trước/sau
cùng điều kiện khi có thể; không hứa cải thiện chỉ từ việc đổi code.

Ví dụ: `Tái hiện và sửa lỗi endpoint trả 500 với input không hợp lệ, kèm regression test`.
