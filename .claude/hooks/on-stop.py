#!/usr/bin/env python3
"""
Stop Hook - 当 Claude Code 会话结束时运行
在这里添加你想要执行的任何自定义逻辑
"""

import sys
import json
from datetime import datetime

def main():
    """
    在这里编写你的自定义逻辑
    """
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

    # 返回 JSON 格式的输出，使其在 transcript 中可见
    output = {
        "continue": True,  # 允许正常停止
        "systemMessage": f"🎉 任务完成时间: {timestamp}",
        "suppressOutput": False  # 在 transcript 中显示
    }
    print(json.dumps(output))

    return 0

if __name__ == "__main__":
    try:
        exit_code = main()
        sys.exit(exit_code)
    except Exception as e:
        print(f"❌ Stop hook 执行出错: {e}", file=sys.stderr)
        sys.exit(1)
