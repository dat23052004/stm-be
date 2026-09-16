# Agent và skill Codex của LabX

## Cấu trúc

```text
.codex/
  agents/
    backend_development.toml
    software_design_specification.toml
    testing.toml
.agents/
  skills/
    backend-development/SKILL.md
    api-development/SKILL.md
    database-development/SKILL.md
    backend-debugging/SKILL.md
    code-review/SKILL.md
    software-design-specification/
      SKILL.md
      references/diagram-conventions.md
    unit-testing/SKILL.md
    integration-testing/SKILL.md
    system-testing/SKILL.md
```

`AGENTS.md` chứa quy tắc ổn định của repository. Custom subagent giữ vai trò chuyên môn;
skill chứa workflow cho một loại tác vụ. Chỉ dùng subagent hoặc skill có liên quan để tránh nạp context thừa.

## Các thành phần và thời điểm được nạp

Hệ thống agent của repository có bốn thành phần khác nhau:

1. **Main agent** nhận yêu cầu, giữ phạm vi và chịu trách nhiệm về kết quả cuối cùng.
2. **`AGENTS.md`** đặt quy tắc ổn định theo phạm vi thư mục; đây không phải một agent riêng.
3. **`.codex/agents/*.toml`** định nghĩa vai trò, mô tả và instruction của custom subagent.
4. **`.agents/skills/*/SKILL.md`** chứa workflow chuyên môn được main agent hoặc subagent nạp khi task phù hợp.

Codex đọc chuỗi `AGENTS.md` từ root đến phạm vi đang làm việc. Trong LabX:

```text
Sửa source:     AGENTS.md + src/AGENTS.md
Sửa test:       AGENTS.md + tests/AGENTS.md
Sửa tài liệu:   AGENTS.md + docs/AGENTS.md
```

Root `AGENTS.md` đặt quy tắc toàn repository. Các file scoped chỉ bổ sung quy tắc cho source, test hoặc tài liệu;
không cần lặp lại toàn bộ nội dung root. `README.md`, `docs/project-context.md` và các guide là context được đọc
khi instruction hoặc task yêu cầu, không phải file instruction tự động thay thế `AGENTS.md`.

Skill dùng cơ chế nạp theo nhu cầu: Codex nhận biết tên và mô tả trước, sau đó mới đọc toàn bộ `SKILL.md` khi
skill được gọi trực tiếp hoặc task khớp phạm vi. Custom subagent cũng chỉ được tạo khi có một nhiệm vụ chuyên môn
cụ thể; các file TOML không tự chạy khi mở solution hoặc khởi động API.

## Cách sử dụng trong Codex

Mở workspace tại thư mục chứa `LabX_Be.sln`. Codex tự đọc `AGENTS.md` ở root và file scoped gần source đang làm việc.
Skills trong `.agents/skills/` được phát hiện tự động; gọi trực tiếp bằng `$skill-name` hoặc mô tả task để Codex chọn.
Custom agents trong `.codex/agents/` có thể được giao một tác vụ độc lập bằng tên.

Ví dụ:

```text
Dùng backend_development subagent để implement requirement trong docs/requirements/<feature>.md.
$api-development thêm endpoint theo contract được cung cấp.
Dùng testing subagent để viết và chạy integration test cho API foundation.
$software-design-specification tạo class diagram cho module đã triển khai.
```

## Cách main agent chọn phương thức thực hiện

Main agent xử lý trực tiếp khi task nhỏ, chỉ cần một context và không có phần việc độc lập đáng kể. Có thể gọi
skill trực tiếp để áp dụng workflow mà không cần tạo subagent:

```text
$api-development thêm endpoint theo API contract đã duyệt.
$unit-testing viết regression test cho một application service.
```

Subagent phù hợp khi task có phạm vi chuyên môn rõ, cần tách context hoặc có thể giao thành một đầu việc độc lập:

```text
Dùng backend_development subagent để triển khai module theo requirement.
Dùng software_design_specification subagent để lập SDS từ source đã triển khai.
Dùng testing subagent để viết và chạy integration test cho endpoint.
```

Không tạo subagent chỉ để đọc một file hoặc thực hiện một thay đổi nhỏ. Với nhiều subagent, main agent phân chia
quyền sở hữu file và thứ tự phụ thuộc trước khi giao việc. Các agent dùng chung workspace, vì vậy không để hai
agent sửa cùng file song song. Kết quả của subagent được main agent kiểm tra và tổng hợp; subagent không tự thay
thế quyết định phạm vi của người dùng.

Luồng chọn thông thường:

```text
Yêu cầu người dùng
  -> main agent áp dụng AGENTS.md
  -> xác định phạm vi source / test / docs
  -> chọn làm trực tiếp hoặc giao subagent
  -> nạp đúng một skill chính và reference cần thiết
  -> thực hiện, kiểm tra và cập nhật tài liệu liên quan
  -> main agent báo file thay đổi, lệnh đã chạy, kết quả và giới hạn còn lại
```

## Software Design Specification

Subagent `software_design_specification` dùng
[skill SDS](../../.agents/skills/software-design-specification/SKILL.md).
Đầu ra nằm ở `docs/software-design/{module}/`. Thiết kế chưa triển khai phải ghi `Proposed`;
diagram phải tuân theo `references/diagram-conventions.md` của skill.

## Testing

Subagent `testing` chọn đúng cấp độ:

- [Unit Testing](../../.agents/skills/unit-testing/SKILL.md): xUnit cô lập ở `tests/UnitTests/`.
- [Integration Testing](../../.agents/skills/integration-testing/SKILL.md): HTTP hoặc infrastructure test ở `tests/IntegrationTests/`.
- [System Testing](../../.agents/skills/system-testing/SKILL.md): test plan/report workflow ở `docs/testing/system/`.

Có thể gọi trực tiếp `$unit-testing`, `$integration-testing` hoặc `$system-testing` khi không cần tách context sang subagent.
Chỉ ghi Passed khi có bằng chứng thực thi; project test trống không đồng nghĩa hành vi đã được kiểm chứng.

## Dev backend

Subagent `backend_development` định tuyến tới skill phù hợp:

- [Backend Development](../../.agents/skills/backend-development/SKILL.md): feature hoặc use case qua nhiều layer.
- [API Development](../../.agents/skills/api-development/SKILL.md): endpoint, DTO, validation, ProblemDetails và auth theo yêu cầu.
- [Database Development](../../.agents/skills/database-development/SKILL.md): persistence, query, transaction và migration sau khi chọn provider.
- [Backend Debugging](../../.agents/skills/backend-debugging/SKILL.md): tái hiện, chẩn đoán và sửa lỗi.
- [Code Review](../../.agents/skills/code-review/SKILL.md): review có bằng chứng về lỗi, contract và consistency.

Feature nhỏ có thể gọi skill trực tiếp. Database và authentication vẫn là quyết định mở của base;
agent không tự thêm chúng nếu requirement chưa yêu cầu.

## Quan hệ giữa subagent và skill

Subagent là một agent thực thi trong context riêng; skill là bộ hướng dẫn mà agent đọc và làm theo. Một subagent
có thể chọn một trong nhiều skill, và main agent cũng có thể dùng cùng skill mà không cần delegation:

```text
backend_development subagent
  -> backend-development       feature qua nhiều layer
  -> api-development           HTTP contract và endpoint
  -> database-development      persistence và migration
  -> backend-debugging         lỗi có thể tái hiện
  -> code-review               review được yêu cầu

testing subagent
  -> unit-testing
  -> integration-testing
  -> system-testing

software_design_specification subagent
  -> software-design-specification
```

Subagent không tự nạp toàn bộ skill set. Nó đọc skill phù hợp với task để giới hạn context và tránh áp dụng nhầm
quy trình database, testing hoặc documentation vào công việc không liên quan.

## Trạng thái định dạng agent trong repository

LabX dùng định dạng Codex hiện tại:

```text
.codex/agents/*.toml           Custom subagent
.agents/skills/*/SKILL.md      Repository skill
AGENTS.md                      Instruction theo phạm vi
```

Repository không dùng `.github/agents/*.agent.md`. Các file `.agent.md` từ bộ tham khảo trước đây không phải
custom subagent đang hoạt động của cấu hình Codex này và không cần tạo lại. `.github/` hiện chỉ chứa CI,
Dependabot và pull request template.

Các file trong `docs/templates/` là mẫu đầu ra, không phải instruction được tự động nạp. Chúng cố ý chỉ chứa
khung trường cần điền và chỉ được sao chép khi có requirement, SDS, ADR, test plan, report, review hoặc handoff
thực tế. Không điền dữ liệu giả vào template để làm chúng trông như tài liệu đã hoàn thành.

## Planning và bàn giao

Planning dùng agent mặc định cùng `AGENTS.md`. Tác vụ lớn có thể tách phần backend, SDS hoặc testing cho subagent;
tác vụ nhỏ không cần delegation. Dùng template trong `docs/templates/` khi đầu ra yêu cầu và chỉ tạo folder output khi có nội dung thật.

Với flow nhiều giai đoạn, thứ tự mặc định là:

```text
Requirement đã đủ thông tin
  -> backend implementation
  -> SDS dựa trên source thực tế
  -> test và verification
  -> handoff
```

Chỉ chạy song song các phần độc lập như khảo sát source, phân tích test gap hoặc kiểm tra tài liệu. Nếu test hoặc
SDS phụ thuộc implementation mới, chờ source ổn định rồi mới tạo đầu ra để tránh mô tả hoặc kiểm thử thiết kế đã
thay đổi.
