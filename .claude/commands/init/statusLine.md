---
description: "[DEPRECATED] /init:claude로 통합되었습니다."
---
# Initialize StatusLine (DEPRECATED)

> **이 명령어는 더 이상 사용되지 않습니다.**

## 변경 안내

`/init:statusLine` 명령어는 `/init:claude`에 통합되었습니다.

StatusLine 설정을 포함한 사용자 환경 초기화는 `/init:claude`를 사용하세요.

## 대체 명령어

| 기존 | 대체 | 설명 |
|------|------|------|
| `/init:statusLine` | `/init:claude` | 사용자 환경 초기화 (Shell alias, StatusLine, Slack, Git 포함) |

## 사용 방법

```
/init:claude
```

위 명령어를 실행하면 다음 항목이 모두 초기화됩니다:
- Shell alias (cc, ccc) 등록
- StatusLine 설정 (settings.json, statusline.sh)
- Slack 환경 변수 설정
- Git global 설정

## 관련 명령어

| 명령어 | 설명 |
|--------|------|
| `/init:claude` | 사용자 환경 초기화 (1회 실행) |
| `/init:project` | 프로젝트 초기화 (프로젝트당 1회) |
| `/init:workflow` | 워크플로우 초기화 (세션 시작 시) |
