#!/bin/bash
# 위험한 명령어 차단 Hook 스크립트
# PreToolUse(Bash) 이벤트에서 위험 명령어 패턴 매칭 후 차단
#
# 입력: stdin으로 JSON (tool_name, tool_input)
# 출력: 차단 시 hookSpecificOutput JSON, 통과 시 빈 출력

# stdin에서 JSON 읽기
INPUT=$(cat)

# tool_name 확인 (Bash가 아니면 통과)
TOOL_NAME=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(data.get('tool_name', ''))
except:
    print('')
" 2>/dev/null)

if [ "$TOOL_NAME" != "Bash" ]; then
    exit 0
fi

# command 필드 추출
COMMAND=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    tool_input = data.get('tool_input', {})
    print(tool_input.get('command', ''))
except:
    print('')
" 2>/dev/null)

if [ -z "$COMMAND" ]; then
    exit 0
fi

# 화이트리스트 검사 (안전한 패턴은 통과)
# /tmp/ 하위 rm -rf
if echo "$COMMAND" | grep -qP 'rm\s+-r[f]?\s+/tmp/' 2>/dev/null; then
    exit 0
fi

# .workflow/ 하위 rm -rf
if echo "$COMMAND" | grep -qP 'rm\s+-r[f]?\s+.*\.workflow/' 2>/dev/null; then
    exit 0
fi

# git push --force-with-lease (안전한 force push)
if echo "$COMMAND" | grep -qP 'git\s+push\s+--force-with-lease' 2>/dev/null; then
    exit 0
fi

# 위험 패턴 검사
BLOCKED=""
ALTERNATIVE=""

# 1. rm -rf / (루트 삭제)
if echo "$COMMAND" | grep -qP 'rm\s+-r[f]*\s+/\s*$' 2>/dev/null; then
    BLOCKED="rm -rf / (루트 디렉토리 삭제)"
    ALTERNATIVE="특정 경로를 지정하거나 rm -ri로 대화형 삭제를 사용하세요."
fi

# 2. rm -rf ~ (홈 디렉토리 삭제)
if [ -z "$BLOCKED" ] && echo "$COMMAND" | grep -qP 'rm\s+-r[f]*\s+~' 2>/dev/null; then
    BLOCKED="rm -rf ~ (홈 디렉토리 삭제)"
    ALTERNATIVE="특정 파일/디렉토리를 지정하세요."
fi

# 3. rm -rf . (현재 디렉토리 전체 삭제)
if [ -z "$BLOCKED" ] && echo "$COMMAND" | grep -qP 'rm\s+-r[f]*\s+\.\s*$' 2>/dev/null; then
    BLOCKED="rm -rf . (현재 디렉토리 전체 삭제)"
    ALTERNATIVE="특정 파일/디렉토리를 지정하세요."
fi

# 4. rm -rf * (와일드카드 전체 삭제 - 위험 경로에서)
if [ -z "$BLOCKED" ] && echo "$COMMAND" | grep -qP 'rm\s+-r[f]*\s+\*' 2>/dev/null; then
    BLOCKED="rm -rf * (와일드카드 전체 삭제)"
    ALTERNATIVE="특정 파일/디렉토리를 지정하거나 ls로 목록을 먼저 확인하세요."
fi

# 5. git reset --hard
if [ -z "$BLOCKED" ] && echo "$COMMAND" | grep -qP 'git\s+reset\s+--hard' 2>/dev/null; then
    BLOCKED="git reset --hard (커밋되지 않은 변경사항 전체 삭제)"
    ALTERNATIVE="git stash로 변경사항을 임시 저장하세요."
fi

# 6. git push --force / git push -f (--force-with-lease 제외 - 위에서 이미 통과)
if [ -z "$BLOCKED" ] && echo "$COMMAND" | grep -qP 'git\s+push\s+(--force|-f)' 2>/dev/null; then
    BLOCKED="git push --force (원격 히스토리 덮어쓰기)"
    ALTERNATIVE="git push --force-with-lease를 사용하세요."
fi

# 7. git clean -f / git clean -fd
if [ -z "$BLOCKED" ] && echo "$COMMAND" | grep -qP 'git\s+clean\s+-[fd]*f' 2>/dev/null; then
    BLOCKED="git clean -f (추적되지 않는 파일 전체 삭제)"
    ALTERNATIVE="git clean -n으로 드라이런하여 삭제 대상을 먼저 확인하세요."
fi

# 8. git branch -D main/master
if [ -z "$BLOCKED" ] && echo "$COMMAND" | grep -qP 'git\s+branch\s+-D\s+(main|master)' 2>/dev/null; then
    BLOCKED="git branch -D main/master (주요 브랜치 강제 삭제)"
    ALTERNATIVE="주요 브랜치 삭제는 매우 위험합니다. 정말 필요한지 재확인하세요."
fi

# 9. git checkout . / git restore .
if [ -z "$BLOCKED" ] && echo "$COMMAND" | grep -qP 'git\s+(checkout|restore)\s+\.\s*$' 2>/dev/null; then
    BLOCKED="git checkout/restore . (모든 변경사항 되돌리기)"
    ALTERNATIVE="git stash로 변경사항을 임시 저장하세요."
fi

# 10. DROP TABLE / DROP DATABASE (대소문자 무시)
if [ -z "$BLOCKED" ] && echo "$COMMAND" | grep -qiP 'DROP\s+(TABLE|DATABASE)' 2>/dev/null; then
    BLOCKED="DROP TABLE/DATABASE (데이터베이스/테이블 삭제)"
    ALTERNATIVE="백업을 먼저 수행하고, 트랜잭션 내에서 실행하세요."
fi

# 11. chmod 777
if [ -z "$BLOCKED" ] && echo "$COMMAND" | grep -qP 'chmod\s+777' 2>/dev/null; then
    BLOCKED="chmod 777 (과도한 권한 부여)"
    ALTERNATIVE="chmod 755 또는 필요한 최소 권한만 부여하세요."
fi

# 12. mkfs (디스크 포맷)
if [ -z "$BLOCKED" ] && echo "$COMMAND" | grep -qP 'mkfs' 2>/dev/null; then
    BLOCKED="mkfs (디스크 포맷)"
    ALTERNATIVE="디스크 포맷은 매우 위험합니다. 대상 디바이스를 재확인하세요."
fi

# 13. dd if= (디스크 덮어쓰기)
if [ -z "$BLOCKED" ] && echo "$COMMAND" | grep -qP 'dd\s+if=' 2>/dev/null; then
    BLOCKED="dd if= (디스크 덮어쓰기)"
    ALTERNATIVE="dd 명령어는 되돌릴 수 없습니다. 대상 디바이스를 재확인하세요."
fi

# 차단 판정
if [ -n "$BLOCKED" ]; then
    # 환경변수를 통해 Python에 값 전달 (코드 인젝션 방지)
    GUARD_BLOCKED="${BLOCKED}" GUARD_ALTERNATIVE="${ALTERNATIVE}" python3 -c "
import json, os
blocked = os.environ['GUARD_BLOCKED']
alternative = os.environ['GUARD_ALTERNATIVE']
reason = f'위험한 명령어가 감지되었습니다: {blocked}. 안전한 대안: {alternative}'
result = {
    'hookSpecificOutput': {
        'hookEventName': 'PreToolUse',
        'permissionDecision': 'deny',
        'permissionDecisionReason': reason
    }
}
print(json.dumps(result, ensure_ascii=False))
" 2>/dev/null
    exit 0
fi

# 위험 패턴 미매칭 시 빈 출력 (통과)
exit 0
