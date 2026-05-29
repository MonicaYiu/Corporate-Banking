#!/bin/bash
set -e

echo "================================================"
echo "  CIMB SME Document Intelligence — 启动脚本"
echo "================================================"

# Check Python
if ! command -v python3 &>/dev/null; then echo "❌ Python3 未安装"; exit 1; fi

# Check API key
if [ -z "$OPENAI_API_KEY" ]; then
  if [ -f ".env" ]; then
    export $(grep -v '^#' .env | xargs)
  fi
fi
if [ -z "$OPENAI_API_KEY" ]; then
  echo ""
  echo "⚠️  未找到 OPENAI_API_KEY"
  echo "   请在当前目录创建 .env 文件并填写："
  echo "   OPENAI_API_KEY=sk-proj-..."
  echo ""
  read -p "或直接在此输入 API Key（回车跳过）: " key
  if [ -n "$key" ]; then export OPENAI_API_KEY="$key"; fi
fi

# Install dependencies
echo ""
echo "📦 安装 Python 依赖..."
cd backend
pip install -r requirements.txt -q --break-system-packages 2>/dev/null || pip install -r requirements.txt -q
cd ..

# Start backend
echo ""
echo "🚀 启动后端服务 (http://localhost:8000)..."
cd backend
uvicorn main:app --host 0.0.0.0 --port 8000 --reload &
BACKEND_PID=$!
cd ..
sleep 2

# Open frontend
echo ""
echo "🌐 打开前端界面..."
FRONTEND_PATH="$(pwd)/frontend/index.html"

if command -v open &>/dev/null; then
  open "$FRONTEND_PATH"
elif command -v xdg-open &>/dev/null; then
  xdg-open "$FRONTEND_PATH"
else
  echo "请手动在浏览器中打开: file://$FRONTEND_PATH"
fi

echo ""
echo "================================================"
echo "  ✅ 系统已启动"
echo "  📄 前端: file://$FRONTEND_PATH"
echo "  🔌 后端: http://localhost:8000"
echo "  📚 API文档: http://localhost:8000/docs"
echo "  按 Ctrl+C 停止后端服务"
echo "================================================"

wait $BACKEND_PID
