---
name: software-design-specification
description: Create LabX SDS documents and PlantUML class or sequence diagrams. Use for software design specification, SDS, class diagram, sequence diagram, or documenting an implemented backend module.
---

# Software Design Specification

## Đầu vào và phạm vi

Nhận module/feature, artifact cần tạo và requirement nếu có. Mặc định mô tả source đã triển khai.
Nếu người dùng yêu cầu thiết kế mới, ghi Proposed và phân biệt yêu cầu đã biết với giả định.
Đọc [quy tắc tài liệu](../../../docs/AGENTS.md) và [kiến trúc](../../../docs/architecture.md).

## Đọc source theo module

- `src/Api/`: endpoint/controller, HTTP contracts, middleware liên quan.
- `src/Application/`: use case/service, DTOs và interfaces.
- `src/Domain/`: entities, value objects và business invariants.
- `src/Infrastructure/`: implementation của ports và persistence nếu đã có.
- `tests/`: bằng chứng cho success/error flow khi cần xác nhận hành vi.

Tìm bằng tên module, route hoặc symbol, rồi đọc các dependency trực tiếp; không nạp toàn bộ repo.
Ghi lại source paths, tên type/method, parameter/return type và chiều phụ thuộc thực tế.
Module chưa có source thì nêu rõ; chỉ thiết kế proposal nếu người dùng yêu cầu và có đủ requirement.

## Sinh artifact theo yêu cầu

- **SDS**: dùng [mẫu SDS](../../../docs/templates/software-design.md), lưu
  `docs/software-design/{module}/sds.md`; mô tả trách nhiệm, contracts, luồng, dữ liệu và điểm còn mở.
- **Class diagram**: lưu `docs/software-design/{module}/class-diagram.puml`.
  Nhóm type theo đúng layer; giữ members quan trọng và DTOs của boundary liên quan.
  Tách thành các view theo layer nếu quá lớn; bỏ view không có thành phần thực tế.
- **Sequence diagram**: một use case/file tại
  `docs/software-design/{module}/sequence-diagrams/{flow}.puml`.
  Ghi method/DTO thật, response và các nhánh lỗi được source hoặc requirement chứng minh.
- Khi tạo diagram, đọc [quy ước diagram](references/diagram-conventions.md).
  Nếu yêu cầu chỉ diagram, tạo `.puml` và báo kết quả trong phản hồi; không tự thêm SDS Markdown.

Các thư mục output chỉ được tạo khi có artifact. `.puml` chứa raw PlantUML, không bọc Markdown.
Không tự thêm DB, repository, UnitOfWork, UI page hoặc ownership không có bằng chứng.
Không sửa `src/` hoặc `tests/` trong tác vụ tài liệu.

## Kiểm tra và bàn giao

Đối chiếu names/signatures/relationships/status codes với source, kiểm tra đường dẫn tương đối.
Nếu có renderer PlantUML, render và xem kết quả; nếu thiếu, ghi `Source checked; render not run`.
Báo artifact paths, module/phạm vi, Proposed hay Implemented, bằng chứng và điểm chưa xác minh.

Ví dụ: `Tạo class diagram và sequence diagram xử lý lỗi API từ GlobalExceptionHandler`.
Chỉ vẽ pipeline có thật trong source, không thêm service/database để lấp đầy sơ đồ.
