# CIMB SME Document Intelligence — Demo

## 系统架构

```
cimb_demo/
├── backend/
│   ├── main.py           # FastAPI 后端（OCR、分类、矛盾检测）
│   └── requirements.txt  # Python 依赖
├── frontend/
│   └── index.html        # 前端单页应用（直接用浏览器打开）
├── uploads/              # 上传文件存储（自动创建）
├── rules/
│   └── custom_rules.json # 自定义矛盾检测规则
├── start.sh              # 一键启动脚本（Mac/Linux）
└── README.md
```

## 快速启动

### 1. 配置 API Key

在 `cimb_demo/` 目录下创建 `.env` 文件：

```bash
ANTHROPIC_API_KEY=sk-ant-xxxxxxxxxxxxxxxxxxxxxxxx
```

### 2. 启动系统

```bash
# 进入项目目录
cd cimb_demo

# 给启动脚本添加权限
chmod +x start.sh

# 运行
./start.sh
```

脚本会自动：
- 安装 Python 依赖
- 启动后端服务（端口 8000）
- 在浏览器打开前端页面

### 3. 手动启动（可选）

```bash
# 终端 1 — 后端
cd cimb_demo/backend
pip install -r requirements.txt
ANTHROPIC_API_KEY=sk-ant-xxx uvicorn main:app --reload --port 8000

# 终端 2 — 前端
open cimb_demo/frontend/index.html  # Mac
# 或直接在浏览器中打开 frontend/index.html
```

## 使用流程

### 阶段一：材料上传
1. 在下拉框选择贷款产品（如 CIMB BizProp）
2. 右侧自动显示该产品所需的 Checklist
3. 拖拽或点击上传文件（支持 PDF、JPG/PNG、XLSX、DOCX）
4. 点击「开始处理」

### 阶段二：OCR 解析
- 系统自动提取每份文件的文字内容
- 可点击「对比查看」进入左右分屏，手动校正 OCR 错误
- 修正后的文字用于后续分类和矛盾检测

### 阶段三：分类比对
- AI 将上传文件与 Checklist 槽位进行匹配
- 缺失文件标红（阻断性）或橙色（建议性）
- 未匹配文件可手动指定槽位
- 阻断性缺失全部处理后才能进入矛盾检测

### 阶段四：矛盾检测
- AI 跨文档比对关键字段，执行预设规则
- 结果按高风险/中风险分级展示
- 可导出完整审核报告（.txt）

### 规则管理
- 查看 10 条内置规则（只读）
- 编辑自定义规则 JSON，保存后下次检测生效

## 支持的文件格式

| 格式 | 处理方式 |
|------|---------|
| PDF（原生文字层） | pdfplumber 直接提取 |
| PDF（扫描件） | Claude Vision OCR |
| JPG / PNG / GIF | Claude Vision OCR |
| XLSX / XLS | openpyxl 提取为文本 |
| DOCX | python-docx 提取 |
| TXT / CSV | 直接读取 |

## 自定义规则格式

编辑 `rules/custom_rules.json` 或通过「规则管理」页面在线编辑：

```json
[
  {
    "id": "CUSTOM_01",
    "name": "规则名称",
    "description": "详细的检测逻辑说明，AI 会读取此内容进行判断",
    "fields": ["field_name_1", "field_name_2"],
    "applies_to": ["BizProp", "BizPropPlus"],
    "severity": "high"
  }
]
```

`applies_to` 可用的产品 key：
`FlexiPay` / `BizGrow` / `BizAssist` / `BizProp` / `BizPropPlus` / `BizAssure` / `SLL` / `EFSGreen`

## API 文档

后端启动后访问：http://localhost:8000/docs

主要接口：
- `POST /api/upload` — 上传文件
- `POST /api/ocr/{session_id}` — 运行 OCR
- `POST /api/classify/{session_id}` — 运行分类
- `POST /api/detect/{session_id}` — 运行矛盾检测
- `GET/POST /api/rules/custom` — 管理自定义规则

## 常见问题

**Q: 分类时间较长？**
A: 正常，Claude API 分析 8-12 份文件通常需要 15-30 秒。

**Q: 扫描版 PDF 识别效果差？**
A: 确保 PDF 清晰度 ≥ 150 DPI。如识别率低于 80%，建议手动校正。

**Q: 如何测试矛盾检测？**
A: 上传同一公司的多份文件，故意在不同文件中填写不一致的公司名称或金额，即可触发检测。
