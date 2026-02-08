#!/usr/bin/env python3
"""SessionStart Hook: workflow-orchestration SKILL.md를 additionalContext로 주입"""
import json
import sys
from pathlib import Path


def main() -> int:
    project_dir = Path(__file__).resolve().parent.parent.parent
    skill_path = project_dir / ".claude" / "skills" / "workflow-orchestration" / "SKILL.md"

    if not skill_path.exists():
        return 0

    content = skill_path.read_text(encoding="utf-8")

    output = {
        "hookSpecificOutput": {
            "hookEventName": "SessionStart",
            "additionalContext": content,
        }
    }
    print(json.dumps(output))
    return 0


if __name__ == "__main__":
    sys.exit(main())
