---
name: unit-testing
description: Write and run isolated C# xUnit tests for a LabX method or class. Use for unit test requests and focused regression tests without starting the HTTP host or connecting to a database.
---

# Unit Testing

## Đầu vào

Nhận method/class, hành vi mong đợi hoặc bug cần tái hiện. Đọc source, caller, test hiện có và
[quy tắc test](../../../tests/AGENTS.md). Nếu chưa có code mục tiêu, báo thiếu source thay vì tạo test giả.

## Thực hiện

1. Xác định hành vi công khai và các nhánh cần bảo vệ: normal, boundary, abnormal phù hợp với requirement.
2. Đặt test trong `tests/UnitTests/{layer}/{Target}Tests.cs`; dùng xUnit và AAA.
   Tên method theo `Method_WhenCondition_ExpectedBehavior`, thêm `Trait("Type", "Normal|Boundary|Abnormal")` phù hợp.
3. Dùng fake nhỏ cho dependency; kiểm soát thời gian bằng TimeProvider nếu source hỗ trợ.
   Không khởi động WebApplicationFactory, dùng DB thật hoặc gọi mạng trong unit test.
4. Assert kết quả, invariant hoặc side effect có ý nghĩa; tránh test getter và sao chép logic implementation.
   Bổ sung ProjectReference đúng layer khi test mới cần; không thêm package mock mặc định.
5. Chạy test mục tiêu khi lặp, sau đó chạy suite unit khi source/test đã ổn định.

## Lệnh từ repository root

```powershell
dotnet test tests/UnitTests/UnitTests.csproj -c Release --logger trx --results-directory artifacts/test-results
```

Khi đã có test, có thể thêm `--filter FullyQualifiedName~TargetName` theo target thực tế.
Lệnh trên tự restore/build, dùng được sau khi đã clean `bin/obj`.
Nếu chạy với `--no-build`, bảo đảm đã build đúng cấu hình sau thay đổi.

## Đầu ra

Test code, exact commands và Passed/Failed/Skipped thực tế. Nếu yêu cầu report, dùng
[mẫu report](../../../docs/templates/test-report.md), lưu `docs/testing/unit/{target}-report.md`.
Nối requirement ID với test method nếu requirement có ID; không tự đặt requirement nghiệp vụ.
Test thất bại cần báo reproduction/expected/actual; không đổi expectation chỉ để pass.

Project base hiện chưa có unit test case. Ví dụ task tương lai: `unit test GlobalExceptionHandler.TryHandleAsync`.
