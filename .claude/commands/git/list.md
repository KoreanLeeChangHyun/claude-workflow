---
description: 커밋 히스토리를 조회합니다.
argument-hint: "[옵션: 개수, 브랜치, 파일경로, --all, --detail 등]"
---

# Git List

커밋 히스토리를 보기 좋게 포맷팅하여 표시합니다.

## 입력: $ARGUMENTS

## 절차

### 1. Git 저장소 확인

```bash
git rev-parse --is-inside-work-tree
```

Git 저장소가 아닌 경우:
- "현재 디렉토리는 Git 저장소가 아닙니다." 출력 후 종료

### 2. 인자 파싱 및 git log 실행

`$ARGUMENTS`를 분석하여 적절한 git log 명령어를 구성합니다.

#### 인자 없음 (기본 출력)

```bash
git log --oneline --graph --decorate -20
```

#### 숫자만 전달 (예: `10`, `30`)

개수로 인식하여 해당 수만큼 표시:

```bash
git log --oneline --graph --decorate -N
```

#### `--all` 포함

모든 브랜치의 히스토리 표시:

```bash
git log --oneline --graph --decorate --all -20
```

숫자와 함께 사용 시 (예: `--all 30`):

```bash
git log --oneline --graph --decorate --all -30
```

#### `--detail` 포함

파일 변경 통계를 포함한 상세 모드:

```bash
git log --stat -10
```

숫자와 함께 사용 시 (예: `--detail 5`):

```bash
git log --stat -5
```

#### 파일 경로 전달 (예: `src/main.js`)

해당 파일의 변경 히스토리 추적:

```bash
git log --oneline --follow -- <path>
```

#### `--since` 또는 `--until` 전달

날짜 기반 필터링:

```bash
git log --oneline --graph --decorate --since="2026-02-01"
```

#### `--author` 전달

작성자 기반 필터링:

```bash
git log --oneline --graph --decorate --author="<name>"
```

#### 기타 인자

`$ARGUMENTS`를 그대로 git log에 전달:

```bash
git log $ARGUMENTS
```

### 3. 결과 출력

git log 결과를 그대로 사용자에게 표시합니다. AskUserQuestion은 사용하지 않습니다.

커밋이 없는 경우:
- "커밋 히스토리가 없습니다." 출력

## 에러 처리

| 상황 | 대응 |
|------|------|
| **Git 저장소 아님** | "현재 디렉토리는 Git 저장소가 아닙니다." 출력 후 종료 |
| **커밋 없음** | "커밋 히스토리가 없습니다." 출력 후 종료 |
| **잘못된 인자** | git log 에러 메시지를 그대로 출력 |

## 사용 예시

```bash
# 기본: 최근 20개 커밋 (그래프 포함)
git:list

# 최근 5개 커밋
git:list 5

# 모든 브랜치 히스토리
git:list --all

# 파일별 히스토리
git:list src/index.ts

# 상세 모드 (변경 파일 통계)
git:list --detail

# 날짜 필터
git:list --since="2026-02-01"

# 작성자 필터
git:list --author="deus"

# 복합 옵션
git:list --all --detail 10
```

## 주의사항

- 이 명령어는 읽기 전용 조회이므로 사용자 승인(AskUserQuestion)이 필요하지 않습니다
- 인자를 조합하여 사용할 수 있습니다 (예: `--all 30`, `--detail 5`)

### zsh read-only 변수 사용 금지

현재 셸이 **zsh**이므로, Bash 도구로 실행하는 스크립트에서 다음 변수명을 **절대 사용하지 않아야** 합니다. 이 변수들은 zsh의 read-only 내장 변수이며, 대입 시 `read-only variable` 에러가 발생합니다.

**금지 변수명**: `status`, `pipestatus`, `ERRNO`, `ZSH_SUBSHELL`, `HISTCMD`

```bash
# 잘못된 예시 (에러 발생)
status=$(git log --oneline -5)  # read-only variable: status

# 올바른 예시
log_result=$(git log --oneline -5)
```
