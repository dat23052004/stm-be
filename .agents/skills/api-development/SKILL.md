---
name: api-development
description: Design or implement LabX ASP.NET Core HTTP endpoints, DTOs, validation, ProblemDetails, and requested access controls. Use for API contracts, controllers, authentication or authorization integration, and HTTP pipeline changes.
---

# API Development

## Đầu vào và source cần đọc

Nhận route/use case, request/response, validation, quyền truy cập và hành vi lỗi mong đợi.
Đọc [quy tắc code](../../../src/AGENTS.md), endpoint/use case/test liên quan,
`src/Api/Program.cs`, `Extensions/ApiServiceExtensions.cs` và `Middleware/` khi đổi pipeline.
Dùng [mẫu API contract](../../../docs/templates/api-contract.md) nếu cần lưu contract.

## HTTP contract

- Giữ route, verb, status và response đang được client dùng, trừ khi task yêu cầu thay đổi contract.
- Dùng DTO rõ ràng cho input/output; chỉ nhận các field client được phép thay đổi.
- Đặt request/response trong `src/Application/DTOs/Requests/` và `Responses/` theo cấu trúc đã chọn;
  giữ việc chuyển kết quả sang HTTP status/ProblemDetails ở Api.
- Model binding/DataAnnotations xử lý cấu trúc input qua `[ApiController]`; business validation thuộc use case/domain.
- Phân biệt trường bắt buộc, giá trị null, giá trị mặc định và cập nhật một phần theo contract.
  Chuẩn hóa chuỗi/ngày/số theo ý nghĩa field; không tự trim password/token hoặc đổi múi giờ ngầm.
- List endpoint có phân trang/sort/filter khi được yêu cầu: giới hạn input, sort ổn định và cho phép field sort cụ thể.
- Trả success DTO và HTTP status theo contract. Giữ `ProblemDetails`/`ValidationProblemDetails` cho lỗi;
  không đổi tất cả lỗi thành HTTP 200 hay đưa exception/stack trace vào response.
- Nếu thêm mapping lỗi nghiệp vụ, giữ trace ID và bảo đảm cùng một lỗi có cách biểu diễn nhất quán.

Base đã có ProblemDetails, request ID, CORS và OpenAPI Development; mở rộng điểm đăng ký hiện có,
không tạo pipeline xử lý lỗi thứ hai. Tham khảo [error handling của ASP.NET Core](https://learn.microsoft.com/en-us/aspnet/core/fundamentals/error-handling?view=aspnetcore-9.0).

## Khi yêu cầu có authentication/authorization

Base chưa chọn identity provider hoặc JWT/cookie. Dùng quyết định đã có; hỏi cơ chế/claims/permissions
nếu thiếu thông tin làm thay đổi cách tích hợp, không tự tạo login/refresh-token system cho một endpoint đơn lẻ.
Đặt authentication và authorization đúng vị trí trước endpoint, với scheme/policy rõ ràng.
Kiểm tra quyền trên tài nguyên/ownership khi task yêu cầu, không chỉ kiểm tra đã đăng nhập.
Dữ liệu người dùng/tenant lấy từ identity đã xác thực thay vì tin field client gửi.
Áp dụng [resource-based authorization](https://learn.microsoft.com/en-us/aspnet/core/security/authorization/resourcebased?view=aspnetcore-9.0) khi quyền phụ thuộc tài nguyên.

Với bearer token, xác thực issuer/audience/lifetime/signature theo provider đã chọn;
với cookie, xử lý CSRF và cookie options theo môi trường thực tế.
Giữ secret ngoài source. CORS không thay thế quyền truy cập và không mở wildcard credentials để sửa lỗi browser.

## Xác minh

Thêm HTTP tests theo [Integration Testing](../integration-testing/SKILL.md): success, invalid input,
not-found/conflict và các status đã khai báo. Với auth, kiểm tra chưa đăng nhập, thiếu quyền,
quyền trên tài nguyên của người khác và trường hợp hợp lệ theo contract.
Kiểm tra response không lộ field nội bộ, trace ID còn đúng, OpenAPI phản ánh DTO/status thực tế.
Chạy `./scripts/verify.ps1`, cập nhật `docs/api/` khi public contract thay đổi và báo kết quả thật.

Ví dụ: `Thêm endpoint theo contract được cung cấp, giữ ProblemDetails và bổ sung HTTP tests`.
