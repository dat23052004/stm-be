---
name: backend-development
description: Implement a LabX ASP.NET Core backend feature across Domain, Application, Infrastructure, and Api. Use for new backend functionality or a use case spanning layers; use focused skills for API-only, database-only, debugging, or review tasks.
---

# Backend Development

## Chốt phạm vi từ yêu cầu

Đọc [quy tắc code](../../../src/AGENTS.md), [bối cảnh](../../../docs/project-context.md),
[kiến trúc](../../../docs/architecture.md), requirement và source/test liên quan.
Lấy SDK/package versions từ project hiện tại; không tự nâng framework hoặc thêm kiến trúc mới.
Xác định actor, input/validation, business rules, kết quả và acceptance criteria.
Nếu thiếu quyết định làm thay đổi contract/nghiệp vụ, hỏi đúng điểm đó và tiếp tục phần độc lập.
Không hỏi lại quyết định đã được người dùng xác nhận.

## Triển khai theo layer cần dùng

1. Tìm đường đi hiện có từ endpoint đến use case/adapter. Chọn tập file nhỏ nhất cần sửa.
2. Đặt invariants trong `src/Domain/`; không để Domain biết HTTP hoặc database provider.
3. Đặt use case ở `src/Application/Services/`; DTO ở `DTOs/Requests/` và `DTOs/Responses/`;
   hợp đồng ở `Interfaces/Services/` hoặc `Interfaces/Repositories/`, validation ở `Validators/`, mapping ở `Mappings/`.
   Các đường dẫn rút gọn trong bước này tính từ `src/Application/`.
   Không thêm interface, command bus, mapper hoặc generic repository chỉ để đủ mẫu kiến trúc.
4. Implement truy cập dữ liệu trong `src/Infrastructure/Repositories/`, tích hợp bên ngoài trong `Services/`;
   context/configuration/migration/seed nằm trong `src/Infrastructure/Data/` khi đã chọn provider.
   Đăng ký hạ tầng trong `src/Infrastructure/DependencyInjection/` rồi gọi từ Api khi có implementation;
   kiểm tra lifetime và truyền CancellationToken xuyên các thao tác I/O.
5. Đặt endpoint/controller ở `src/Api/`; controller chuyển input và kết quả, không giữ business logic.
6. Gắn test vào hành vi và regression risk, rồi cập nhật contract/configuration docs bị ảnh hưởng.

Dùng cấu trúc thư mục nền đã tạo theo yêu cầu; chỉ thêm thư mục module khi có code thật.
Entity không được dùng làm request model để client ghi tùy ý field nội bộ.
Khi nhiều cập nhật cần nguyên tử, chỉ rõ transaction boundary và trạng thái khi một bước lỗi.
Không dùng `.Result`, `.Wait()` hoặc fire-and-forget cho công việc cần hoàn thành cùng request.

## Đọc skill bổ sung đúng lúc

- Đổi HTTP contract hoặc auth → [API Development](../api-development/SKILL.md).
- Thêm/query/update persistence → [Database Development](../database-development/SKILL.md).
- Cần regression tests cô lập hoặc HTTP → [Unit Testing](../unit-testing/SKILL.md) hoặc
  [Integration Testing](../integration-testing/SKILL.md), chỉ đọc cấp độ cần dùng.

Không phải feature nào cũng cần chạm bốn layer. DB/identity/external services chưa được chọn trong base;
chỉ triển khai theo yêu cầu thực tế, không tạo module ví dụ từ AuLac.

## Kiểm tra và bàn giao

Từ repository root, chạy `./scripts/verify.ps1` sau thay đổi source/dependencies.
Script thực hiện restore, build Release và tests; không dùng `--no-build` với output cũ.
Chỉ chạy smoke test khi thay đổi startup/pipeline cần kiểm tra tiến trình HTTP thật.
Ghi các acceptance criteria đã xác minh, file thay đổi, commands/results, config/migration cần áp dụng và giới hạn.
Task lớn có thể dùng [mẫu bàn giao](../../../docs/templates/handoff.md); thay đổi nhỏ báo ngay trong phản hồi.

Ví dụ: `Implement feature theo docs/requirements/<feature>.md và xác minh acceptance criteria`.
Nếu chưa có spec nhưng yêu cầu đã đủ rõ, thực hiện trực tiếp; không bắt buộc sinh tài liệu trước mọi chỉnh sửa.
