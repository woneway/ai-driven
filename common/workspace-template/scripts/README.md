# 能力集成脚本

## 安装所有能力

```bash
cd scripts
./install-all.sh
```

## 单独安装

- `./install-openspec.sh` - OpenSpec
- `./install-ecc.sh` - ECC 验证
- `./install-memory.sh` - 记忆系统（可选）

## 记忆系统

如果需要 Python 记忆系统：
```bash
./install-memory.sh
```

使用：
```python
from scripts.memory.memory_client import AiDrivenMemory
memory = AiDrivenMemory("workspace_name")
memory.add("记住这个")
```