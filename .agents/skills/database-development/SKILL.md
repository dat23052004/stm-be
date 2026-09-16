---
name: database-development
description: Implement LabX persistence, queries, transactions, and reviewed migrations using the selected database provider. Use for database or EF Core work; do not assume a provider or run production migrations from a generic coding request.
---

# Database Development

## Xác định điều kiện trước khi sửa

Đọc [bối cảnh](../../../docs/project-context.md), [kiến trúc](../../../docs/architecture.md),
requirement, entity/use case và persistence code đã có.
Base hiện chưa có provider, DbContext hoặc migration. Nếu chưa chọn DB/ORM, hỏi quyết định đó;
vẫn có thể hoàn thiện contract/domain rule độc lập. Không mặc định chọn SQL Server hay EF Core.
Lấy package/tool versions tương thích từ SDK/provider đang dùng; không cài EF tool global hoặc nâng package ngoài phạm vi.

## Code và dữ liệu

- Hợp đồng repository ở `src/Application/Interfaces/Repositories/`; implementation ở
  `src/Infrastructure/Repositories/`. Hợp đồng service ở `src/Application/Interfaces/Services/`.
  Không lộ DbContext/IQueryable ra API hoặc đặt EF attributes vào Domain để thuận tiện mapping.
- Nếu chọn EF Core, đặt context tại `src/Infrastructure/Data/`, mapping tại `Data/Configurations/`,
  migration tại `Data/Migrations/`, seed tại `Data/Seed/`; các đường dẫn `Data/` tính từ `src/Infrastructure/`.
  Thư mục đã có sẵn; chỉ thêm implementation sau khi chọn provider.
- Đăng ký hạ tầng trong `src/Infrastructure/DependencyInjection/` và gọi từ composition root của Api khi có service.
- Xác định keys, nullability, độ dài/precision, unique/FK constraints và delete behavior theo requirement.
  Validation phía ứng dụng không thay thế DB constraint cần giữ invariant khi có concurrent requests.
- Query chỉ lấy dữ liệu cần dùng; filter/sort/page trước khi materialize, có thứ tự ổn định.
  Dùng no-tracking cho read-only khi phù hợp; kiểm tra N+1/query count khi source cho thấy rủi ro.
- Giữ DbContext theo scope công việc; await xong thao tác trước khi dùng lại cùng context,
  không chạy song song nhiều query trên một instance. Tham khảo [DbContext lifetime](https://learn.microsoft.com/en-us/ef/core/dbcontext-configuration/).
- Truyền CancellationToken vào I/O. Dùng query parameters thay vì nối input vào SQL.
- Xác định transaction/concurrency handling theo use case; không tự retry mọi exception hoặc
  gọi external service trong transaction dài mà chưa xử lý consistency khi một phía thất bại.

## Migration và seed khi dùng EF Core

Tạo migration từ thay đổi model, đọc lại Up/Down, snapshot và SQL sẽ chạy.
Kiểm tra nguy cơ drop/recreate khi rename, dữ liệu cũ với cột bắt buộc mới, unique/index conflicts
và ảnh hưởng rollback. Không sửa/xóa migration đã được áp dụng ở môi trường dùng chung để làm sạch lịch sử.
Xác minh bằng DB test riêng có đúng provider; ghi rõ data migration/seed cần thiết.
Tham khảo [áp dụng migration](https://learn.microsoft.com/en-us/ef/core/managing-schemas/migrations/applying) theo provider và môi trường.

Trước khi áp dụng migration/seed, xác định server/database/environment và quyền đã được giao.
Yêu cầu tạo migration không tự bao gồm áp dụng lên DB dùng chung hoặc production.
Không tự chạy migration ở startup hay in connection string có credentials ra log.
Seed dùng cho development/test phải có phạm vi rõ, chạy lại không tạo bản ghi trùng ngoài ý muốn.

## Kiểm tra và đầu ra

Test mapping/query/constraints/transaction với đúng provider theo
[Integration Testing](../integration-testing/SKILL.md). Fake hoặc EF InMemory không chứng minh quan hệ SQL đúng.
Chạy `./scripts/verify.ps1`; ghi riêng phần DB chưa kiểm tra nếu môi trường không khả dụng.
Bàn giao source/migration, lý do constraint/index, môi trường đã test, lệnh áp dụng chưa chạy
và ảnh hưởng dữ liệu. Ghi quyết định provider vào ADR nếu là lựa chọn kiến trúc mới.

Ví dụ: `Sau khi đã chọn provider, thêm persistence và migration theo model được cung cấp`.
