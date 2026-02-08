---
description: 에이전트, 스킬, 커맨드를 통합 관리. 생성, 수정, 삭제, 조회 작업을 수행합니다.
---

# Asset Manager

## 요청 유형 분석

사용자 요청에서 관리 대상을 파악합니다.

### 키워드 매핑

| 키워드 | 대상 | 실행할 스킬 |
|--------|------|-------------|
| 에이전트, agent | 에이전트 | command-agent-manager |
| 스킬, skill | 스킬 | command-skill-manager |
| 커맨드, command, 명령어 | 커맨드 | command-manager |

## Manager 스킬 실행

요청 유형에 따라 적절한 manager 스킬을 실행합니다.

- **command-agent-manager**: `.claude/skills/command-agent-manager/` 참조
- **command-skill-manager**: `.claude/skills/command-skill-manager/` 참조
- **command-manager**: `.claude/skills/command-manager/` 참조

## 지원 작업

각 manager 스킬은 다음 작업을 지원합니다:

| 작업 | 설명 |
|------|------|
| 생성 (create) | 새로운 에셋 생성 |
| 수정 (update) | 기존 에셋 수정 |
| 삭제 (delete) | 에셋 삭제 |
| 조회 (list/show) | 에셋 목록 또는 상세 조회 |

## 에셋 경로

| 에셋 | 경로 |
|------|------|
| 에이전트 | `.claude/agents/*.md` |
| 스킬 | `.claude/skills/<skill-name>/` |
| 커맨드 | `.claude/commands/cc/*.md` |
