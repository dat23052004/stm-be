---
name: code-review
description: Review LabX backend changes for concrete defects, contract regressions, access-control mistakes, data consistency, and verification gaps. Use when a backend review is requested; implementation tasks do not require a separate review report by default.
---

# Code Review

## Phạm vi

Nhận diff/PR, feature hoặc file list và requirement liên quan. Đọc
[quy tắc dự án](../../../AGENTS.md), [kiến trúc](../../../docs/architecture.md) và test bị ảnh hưởng.
Nếu có Git repository, xem status/diff để xác định thay đổi của task; nếu không có, dùng file list/source được yêu cầu.
Không suy diễn rằng mọi file hiện có đều thuộc thay đổi cần review.

## Ưu tiên phát hiện

- Hành vi sai requirement hoặc regression trong public contract, validation và trường hợp lỗi.
- Business logic đặt sai layer, controller gọi thẳng persistence, DI lifetime không phù hợp.
- Tin input client cho ownership/user/tenant, overposting, thiếu permission/resource check hoặc lộ dữ liệu.
- Query không có giới hạn khi cần, N+1 có bằng chứng, SQL interpolation với input không kiểm soát.
- Transaction/concurrency/side effect không nhất quán, migration có thể mất dữ liệu.
- Cancellation bị bỏ qua, sync-over-async, fire-and-forget làm mất công việc hoặc dùng service đã hết scope.
- Test không kiểm tra đúng hành vi thay đổi, phụ thuộc thứ tự/environment hoặc báo Passed khi chưa chạy.

Chỉ áp dụng mục liên quan tới thay đổi thực tế; không báo thiếu auth/database như lỗi của scaffold
khi requirement chưa yêu cầu chúng. Kiểm tra package/tool behavior theo version hiện có nếu kết luận phụ thuộc phiên bản.
Không thay style/formatter findings cho vấn đề có tác động thực tế.

## Xác minh và trả kết quả

Đọc caller/callee và test để chứng minh trigger, tác động và vị trí lỗi.
Chạy kiểm tra tập trung nếu cần giải quyết nghi vấn; ghi rõ command và kết quả.
Không sửa source hoặc test trong review-only task, trừ khi người dùng cũng yêu cầu fixes.

Mỗi finding có severity theo tác động, `path:line`, tình huống tái hiện, expected/actual,
giải thích ngắn và đề xuất sửa/test. Đặt findings trước; nếu không phát hiện, nói rõ phạm vi
đã review và giới hạn, không chế thêm finding để đủ checklist.
Dùng [mẫu review](../../../docs/templates/review.md) khi cần lưu báo cáo; còn lại trả trực tiếp trong phản hồi.

Ví dụ: `Review thay đổi trong src/Api và tests liên quan theo contract đã cung cấp`.
