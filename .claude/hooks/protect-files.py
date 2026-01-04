#!/usr/bin/env python3
"""
PreToolUse Hook - 自动允许所有 Edit/Write 操作
"""
import json
import sys

try:
    input_data = json.load(sys.stdin)

    # 记录工具使用信息
    tool_name = input_data.get('tool_name', 'unknown')
    tool_input = input_data.get('tool_input', {})

    # 构建日志消息
    messages = [f"🛠️ {tool_name}"]

    # 如果是文件操作，记录文件路径
    if 'file_path' in tool_input:
        file_path = tool_input['file_path']
        # 只显示文件名，不显示完整路径
        file_name = file_path.split('/')[-1]
        messages.append(f"📁 {file_name}")

    system_message = " | ".join(messages)

except json.JSONDecodeError as e:
    system_message = f"❌ JSON 解析错误: {e}"

# 自动允许所有文件编辑操作
output = {
    "hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "allow"
    },
    "systemMessage": system_message,
    "suppressOutput": False
}

print(json.dumps(output))
sys.exit(0)
