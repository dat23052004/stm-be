# Quy ước diagram

- As-built: chỉ vẽ type, method, dependency và flow đã đọc từ source.
- Proposed: ghi nhãn rõ và dẫn requirement/ADR; không trộn với as-built.
- Lưu `docs/software-design/{module}/class-diagram.puml` và `sequence-diagrams/{flow}.puml`.
- `.puml` chứa raw PlantUML với `@startuml`/`@enduml`; không bọc Markdown.
- Class diagram nhóm theo đúng project sở hữu; Application interfaces vẫn ở Application dù implementation ở Infrastructure.
- Ghi tên lớp, kiểu dữ liệu, public operation quan trọng, stereotype và visibility khi có ích.
- Dùng `..>` cho sử dụng tạm, `-->` cho reference được giữ, `..|>` cho implements, `--|>` cho inheritance.
- Chỉ dùng composition khi vòng đời sở hữu được chứng minh; không coi DI là composition.
- Tách theo layer/flow khi diagram quá lớn; tổng quan có thể lược DTO, chi tiết giữ contract liên quan.
- Khi tách view, dùng tên `class-diagram-{layer}.puml` và `class-diagram-overview.puml` nếu cần tổng quan.
- Interface ở layer sở hữu contract, implementation ở layer sở hữu implementation; không chuyển layer chỉ để đặt cạnh nhau.
- Sequence: một use case, `autonumber`, tên method/DTO thực tế, return và nhánh lỗi phù hợp.
- Chỉ có client/DB/UI participant khi có bằng chứng; backend-only có thể dùng actor Client chung.
- Kiểm tra đối chiếu source trước; render và xem kết quả nếu có PlantUML/Java khả dụng.
- Nếu không render được, ghi `Source checked; render not run`; không giả lập kết quả validator.
