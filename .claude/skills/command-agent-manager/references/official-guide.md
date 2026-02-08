# Claude Code 에이전트 공식 가이드

> 출처: https://code.claude.com/docs/en/sub-agents

## 서브에이전트란?

서브에이전트는 특정 유형의 작업을 처리하는 전문화된 AI 어시스턴트입니다. 각 서브에이전트는:
- 자체 컨텍스트 윈도우에서 실행
- 커스텀 시스템 프롬프트 보유
- 특정 도구 접근 권한
- 독립적인 권한 설정

## 서브에이전트의 장점

1. **컨텍스트 보존**: 탐색과 구현을 메인 대화에서 분리
2. **제약 적용**: 사용 가능한 도구 제한
3. **재사용성**: 사용자 레벨 에이전트로 여러 프로젝트에서 사용
4. **전문화**: 특정 도메인을 위한 집중된 시스템 프롬프트
5. **비용 제어**: Haiku 같은 빠르고 저렴한 모델로 라우팅

## 내장 서브에이전트

### Explore
- **모델**: Haiku (빠른 속도)
- **도구**: 읽기 전용 (Write, Edit 제외)
- **용도**: 파일 검색, 코드 탐색

### Plan
- **모델**: 메인 대화 상속
- **도구**: 읽기 전용
- **용도**: 계획 모드에서 컨텍스트 수집

### General-purpose
- **모델**: 메인 대화 상속
- **도구**: 모든 도구
- **용도**: 복잡한 다단계 작업

## YAML Frontmatter 필드 상세

### 필수 필드

#### name (필수)
```yaml
name: code-reviewer
```
- 소문자와 하이픈만 허용
- 고유 식별자로 사용

#### description (필수)
```yaml
description: 코드 품질과 보안을 검토하는 전문가. 코드 변경 후 자동으로 사용됩니다.
```
- Claude가 언제 이 에이전트에 위임할지 결정하는 기준
- "proactively" 포함 시 자동 사용 권장

### 선택 필드

#### tools
```yaml
tools: Read, Glob, Grep, Bash
```
- 허용할 도구 목록
- 생략 시 메인 대화의 모든 도구 상속

#### disallowedTools
```yaml
disallowedTools: Write, Edit
```
- 제외할 도구 목록
- tools와 함께 사용 가능

#### model
```yaml
model: sonnet  # sonnet | opus | haiku | inherit
```
- `sonnet`: 균형잡힌 성능 (권장)
- `opus`: 복잡한 추론
- `haiku`: 빠른 속도
- `inherit`: 메인 대화 모델 사용 (기본값)

#### permissionMode
```yaml
permissionMode: default  # default | acceptEdits | dontAsk | bypassPermissions | plan
```
- `default`: 표준 권한 확인
- `acceptEdits`: 파일 편집 자동 승인
- `dontAsk`: 권한 요청 자동 거부
- `bypassPermissions`: 모든 권한 검사 건너뜀 (주의!)
- `plan`: 읽기 전용 탐색 모드

#### skills
```yaml
skills:
  - api-conventions
  - error-handling-patterns
```
- 시작 시 주입할 스킬 목록
- 스킬 전체 내용이 컨텍스트에 주입됨

#### hooks
```yaml
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/validate-command.sh"
  PostToolUse:
    - matcher: "Edit|Write"
      hooks:
        - type: command
          command: "./scripts/run-linter.sh"
```
- 도구 사용 전/후 실행할 명령

## 사용 가능한 도구 전체 목록

| 도구 | 설명 |
|------|------|
| Read | 파일 읽기 |
| Write | 새 파일 생성 |
| Edit | 기존 파일 수정 |
| Bash | 터미널 명령 실행 |
| Glob | 파일 패턴 검색 |
| Grep | 파일 내용 검색 (정규식) |
| WebSearch | 웹 검색 |
| WebFetch | 웹 페이지 가져오기 |
| Task | 서브에이전트 호출 |
| AskUserQuestion | 사용자에게 질문 |

## 에이전트 저장 위치

| 위치 | 범위 | 우선순위 |
|------|------|---------|
| `--agents` CLI 플래그 | 현재 세션 | 1 (최고) |
| `.claude/agents/` | 현재 프로젝트 | 2 |
| `~/.claude/agents/` | 모든 프로젝트 | 3 |
| 플러그인의 `agents/` | 플러그인 활성화 위치 | 4 (최저) |

## 에이전트 실행 모드

### Foreground (포그라운드)
- 메인 대화 차단
- 권한 요청과 질문이 사용자에게 전달됨

### Background (백그라운드)
- 메인 대화와 병렬 실행
- 사전에 필요한 권한 승인 필요
- `Ctrl+B`로 실행 중인 작업을 백그라운드로 전환 가능

## 훅 이벤트

### 에이전트 frontmatter 내 훅
| 이벤트 | 매처 입력 | 발생 시점 |
|--------|----------|----------|
| `PreToolUse` | 도구 이름 | 도구 사용 전 |
| `PostToolUse` | 도구 이름 | 도구 사용 후 |
| `Stop` | (없음) | 에이전트 종료 시 |

### 프로젝트 레벨 훅 (settings.json)
| 이벤트 | 매처 입력 | 발생 시점 |
|--------|----------|----------|
| `SubagentStart` | 에이전트 이름 | 서브에이전트 시작 |
| `SubagentStop` | (없음) | 서브에이전트 종료 |

## 특정 에이전트 비활성화

settings.json에서:
```json
{
  "permissions": {
    "deny": ["Task(Explore)", "Task(my-custom-agent)"]
  }
}
```

또는 CLI 플래그:
```bash
claude --disallowedTools "Task(Explore)"
```
