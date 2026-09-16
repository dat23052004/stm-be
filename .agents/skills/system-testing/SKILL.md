---
name: system-testing
description: Prepare or execute LabX system test cases across complete user workflows and produce evidence-based reports. Use for system test, end-to-end workflow, or UAT test-plan requests.
---

# System Testing

## Đầu vào

Nhận workflow, actors, requirements, build/environment và phạm vi lập plan hay thực thi.
Đọc [chiến lược test](../../../docs/testing/strategy.md) và các module/contract liên quan.
Base chỉ có các endpoint kỹ thuật; chưa có workflow nghiệp vụ sản phẩm, frontend hoặc môi trường system test.
Báo rõ dữ kiện còn thiếu, không dựng workflow nhà hàng từ tài liệu tham khảo thành nghiệp vụ sản phẩm.

## Lập test plan

Dùng [mẫu test plan](../../../docs/templates/test-plan.md), lưu
`docs/testing/system/{workflow}-plan.md`. Mỗi case có:

- ID `ST-{WORKFLOW}-{nn}` và requirement ID nếu đã có.
- Mục tiêu, actor/permission, preconditions và dữ liệu test.
- Các bước theo hành vi người dùng, expected result và trạng thái dữ liệu sau flow.
- Error/recovery/boundary cases có cơ sở trong requirement; cleanup khi có thay đổi dữ liệu.
- Actual result/evidence trống có nghĩa và status `NotRun` trước khi được thực thi.

Không coi HTTP test host là bằng chứng cho workflow trên môi trường triển khai thực tế.
Nếu chỉ có backend, dùng API steps theo contract và ghi rõ phạm vi backend; không giả định UI page.

## Khi được yêu cầu thực thi

Xác định đúng test environment, build và dữ liệu cô lập trước thao tác.
Nếu chưa có môi trường hoặc quyền thực hiện, hoàn thiện plan và báo phần execution bị thiếu điều kiện.
Chạy các bước trong phạm vi được phép, ghi expected/actual và evidence cho từng case;
không dùng dữ liệu production hoặc tự gửi thông báo tới người thật.
Không đánh dấu Passed chỉ dựa vào việc đọc source hoặc viết được test plan.

## Đầu ra

Plan là đầu ra mặc định; chỉ có execution report khi đã thực thi hoặc được yêu cầu ghi trạng thái chưa chạy.
Dùng [mẫu report](../../../docs/templates/test-report.md) tại
`docs/testing/system/{workflow}-report.md`; ghi Passed/Failed/NotRun, defects và giới hạn môi trường.
Template Excel chỉ được dùng khi người dùng cung cấp file thật; không giả định có report mẫu AuLac.

Ví dụ: với yêu cầu `system test workflow theo docs/requirements/<feature>.md`,
đọc requirement và các module được nêu, tạo cases có traceability; chỉ chạy khi môi trường đã xác định.
