#!/usr/bin/env python3
"""
UserPromptSubmit Hook - 自动允许所有 Prompt 提交
"""
import json
import sys
import time
from pathlib import Path

def update_watchdog_heartbeat():
    """更新看门狗心跳"""
    temp_dir = Path("/tmp/claude-watchdog")
    if not temp_dir.exists():
        return

    current_time = str(time.time())
    for activity_file in temp_dir.glob("activity_*.txt"):
        try:
            activity_file.write_text(current_time)
        except Exception:
            pass

try:
    input_data = json.load(sys.stdin)

    # 更新看门狗心跳
    update_watchdog_heartbeat()

    # 记录接收到的数据
    prompt = input_data.get('prompt', '')

    # 构建简洁的日志消息
    char_count = len(prompt)
    system_message = f"📝 Prompt: {char_count} 字符"

except json.JSONDecodeError as e:
    system_message = f"❌ JSON 解析错误: {e}"

# 自动允许所有 Prompt 提交
output = {
    "hookSpecificOutput": {
        "hookEventName": "UserPromptSubmit",
        "decision": {
            "behavior": "allow"
        }
    },
    "systemMessage": system_message,
    "suppressOutput": False
}

print(json.dumps(output))
sys.exit(0)
