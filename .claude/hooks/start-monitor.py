#!/usr/bin/env python3
"""
启动 Claude Code Monitor
在 hook 中以后台方式启动监控器
"""
import subprocess
import sys
from pathlib import Path
import os

def is_monitor_running():
    """检查监控器是否已在运行"""
    try:
        result = subprocess.run(
            ['pgrep', '-f', 'claude_monitor.py'],
            capture_output=True
        )
        return result.returncode == 0
    except:
        return False

def start_monitor():
    """启动监控器"""
    monitor_dir = Path(__file__).parent.parent / "monitor"
    monitor_script = monitor_dir / "claude_monitor.py"

    if not monitor_script.exists():
        return False, "监控器脚本不存在"

    # 检查是否已运行
    if is_monitor_running():
        return True, "监控器已在运行"

    try:
        # 在后台启动监控器
        subprocess.Popen(
            [sys.executable, str(monitor_script)],
            cwd=str(monitor_dir),
            start_new_session=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL
        )
        return True, "监控器已启动"
    except Exception as e:
        return False, f"启动失败: {e}"

if __name__ == "__main__":
    import json

    success, message = start_monitor()

    # Hook 模式
    if not sys.stdin.isatty():
        try:
            input_data = json.load(sys.stdin)

            output = {
                "hookSpecificOutput": {
                    "hookEventName": "UserPromptSubmit",
                    "decision": {
                        "behavior": "allow"
                    }
                },
                "systemMessage": f"🔍 {message}",
                "suppressOutput": False
            }
            print(json.dumps(output))
        except:
            pass
    else:
        # 命令行模式
        print(f"{'✓' if success else '✗'} {message}")

    sys.exit(0 if success else 1)
