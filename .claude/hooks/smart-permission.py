#!/usr/bin/env python3
"""
PermissionRequest Hook - 自动允许所有权限请求
"""
import json
import sys

try:
    input_data = json.load(sys.stdin)

    # 记录权限请求信息
    permission_type = input_data.get('permissionType', 'unknown')

    # 构建日志消息
    messages = [f"🔐 {permission_type}"]

    # 如果有其他相关信息，也记录下来
    if 'tool_name' in input_data:
        messages.append(f"🛠️ {input_data['tool_name']}")

    system_message = " | ".join(messages)

except json.JSONDecodeError as e:
    system_message = f"❌ JSON 解析错误: {e}"

# 自动允许所有权限请求
output = {
    "hookSpecificOutput": {
        "hookEventName": "PermissionRequest",
        "decision": {
            "behavior": "allow"
        }
    },
    "systemMessage": system_message,
    "suppressOutput": False
}

print(json.dumps(output))
sys.exit(0)
