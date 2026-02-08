---
description: 간단한 질의응답. 워크플로우 없이 즉시 답변을 제공합니다.
---

# Query

## 입력 처리

사용자 요청 전처리는 INIT 단계(init 에이전트)에서 자동 수행됩니다.

```
Task(subagent_type="init", prompt="
command: query
")
```

init이 반환한 `request`에 대해 즉시 답변합니다.

## 특징

- **워크플로우 없음**: PLAN, WORK 등의 단계를 거치지 않음
- **즉시 응답**: 질문에 바로 답변
- **경량화**: cc:research보다 간단한 질의에 적합

## 사용 시점

- 간단한 개념 설명이 필요할 때
- 코드 조각에 대한 설명이 필요할 때
- 빠른 의사결정을 위한 정보가 필요할 때
- 기술적 질문에 대한 답변이 필요할 때

## vs cc:research

| 항목 | cc:query | cc:research |
|------|----------|-------------|
| 워크플로우 | 없음 | INIT → ... → REPORT |
| 응답 시간 | 즉시 | 계획 수립 후 |
| 문서화 | 없음 | `.workflow/<작업디렉토리>/` |
| 적합한 용도 | 간단한 질의 | 심층 조사/비교 분석 |

## 수행 방식

1. 사용자 질문 파악
2. 필요시 도구 사용 (Read, Grep, Glob, WebSearch 등)
3. 즉시 답변 제공

**사용 가능한 도구:**
- `Read`: 파일 읽기
- `Grep`: 코드 검색
- `Glob`: 파일 패턴 검색
- `WebSearch`: 웹 검색
- `WebFetch`: 웹 페이지 내용 가져오기

## 사용 예시

```
cc:query "TypeScript에서 interface와 type의 차이점"
cc:query "이 프로젝트에서 사용하는 인증 방식"
cc:query "async/await 사용법"
cc:query "React useState와 useReducer 비교"
```

## 주의사항

1. **복잡한 조사는 cc:research 사용**: 비교 분석, 심층 연구는 cc:research 권장
2. **문서화 필요시 cc:research 사용**: 결과를 문서로 남겨야 하면 cc:research 사용
3. **코드 수정 요청은 cc:implement 사용**: 코드 변경이 필요하면 cc:implement 사용
