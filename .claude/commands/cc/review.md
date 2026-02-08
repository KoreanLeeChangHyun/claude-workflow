---
description: 코드 리뷰 수행. 파일, 디렉토리, PR 등을 리뷰합니다.
---

# Review

**입력:**
- `command`: review

## 심각도 기준

| 심각도 | 기준 |
|--------|------|
| Critical | 즉시 수정 필요 (보안, 데이터 손실) |
| Warning | 수정 권장 (성능, 잠재적 버그) |
| Info | 개선 제안 (스타일, 리팩토링) |

## 관련 스킬

| 스킬 | 용도 | 경로 |
|------|------|------|
| command-requesting-code-review | 리뷰 체크리스트 및 사전 검증 | `.claude/skills/command-requesting-code-review/SKILL.md` |
| command-code-quality-checker | 린트/타입체크 자동 실행 | `.claude/skills/command-code-quality-checker/SKILL.md` |
