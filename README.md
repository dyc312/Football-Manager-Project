# 2025—2026 赛季英超赛事信息管理系统

这是一个基于 Flask + MySQL 的英超赛事信息管理系统，面向数据库课程项目设计与实现。

系统当前附带的是 **2025—2026 赛季英超课程演示数据集**，包含：

- 20 支球队
- 400 余名球员
- 2 轮比赛
- 比赛事件数据
- 出场记录数据
- 自动生成的积分榜与球员统计

系统支持前台信息展示与后台数据管理。前台用于查看球队、球员、赛程赛果、积分榜、射手榜和球员统计；后台用于维护赛季、赛事、球队、球员、比赛、比赛事件和出场记录。

---

## 一、主要功能

### 1. 前台展示

- 球队信息展示
- 球队详情页
- 球员列表与筛选
- 赛程赛果展示
- 比赛详情展示
- 积分榜展示
- 射手榜展示
- 球员统计展示

### 2. 后台管理

- 后台登录
- 赛季管理
- 赛事管理
- 球队管理
- 球员管理
- 比赛管理
- 比赛事件管理
- 出场记录管理
- 全量重算统计

### 3. 统计模块

系统不是手工维护比分、积分榜和球员统计，而是根据原始比赛数据自动计算：

- 比分由比赛事件自动计算；
- 积分榜由已结束比赛和自动比分生成；
- 射手榜由球员统计表生成；
- 球员统计由比赛事件和出场记录生成；
- 后台支持一键全量重算统计。

---

## 二、主要改进

本版本相比基础版本做了如下改进：

- 保留 `Season`、`Tournament`、`Team`、`Player`、`Match`、`MatchEvent`、`Standing`、`PlayerStat` 等核心结构；
- 新增 `MatchAppearance` 表，用出场记录计算球员出场次数；
- 删除 `MatchEvent` 中冗余的 `team_id`，事件所属球队通过 `Player` 推导；
- 比分不再手工录入，由进球、点球和乌龙球事件自动计算；
- 助攻直接关联到对应进球事件；
- 换人事件通过一条事件记录换下球员和换上球员；
- 增加主客队不同、队内号码唯一、关键字段非空等约束；
- 补齐球队、球员、比赛、事件、出场记录的增删改查；
- 增加球队详情页、比赛详情页、比赛筛选和球员筛选；
- 后台使用下拉框，不再要求管理员记忆各种 ID；
- 后台数据列表支持搜索、筛选、折叠展开；
- 大列表限制初始渲染数量，避免后台页面卡顿；
- `Standing` 和 `PlayerStat` 明确作为物化统计表，由统计模块全量重算；
- 后台管理需要登录，普通用户无法直接进入后台；
- Flask 直接提供前端页面，启动一个服务即可访问系统。

---

## 三、项目结构

```text
football_manager_project/
├─ app.py                  Flask 页面路由与 API 接口
├─ stat_service.py         积分榜、球员统计全量重算模块
├─ init_db.py              数据库初始化脚本
├─ schema.sql              数据库表结构、约束与视图
├─ sample_data.sql         课程演示数据
├─ requirements.txt        Python 依赖
├─ smoke_test.py           可选数据库检查脚本
├─ frontend/               前端页面、样式与公共脚本
│  ├─ index.html           首页 / 球队展示
│  ├─ team_detail.html     球队详情页
│  ├─ players.html         球员列表
│  ├─ matches.html         赛程赛果
│  ├─ match_detail.html    比赛详情页
│  ├─ standings.html       积分榜
│  ├─ scorers.html         射手榜
│  ├─ player_stats.html    球员统计
│  ├─ admin-login.html     后台登录页
│  ├─ admin.html           后台管理页
│  ├─ styles.css           页面样式
│  └─ common.js            公共请求与工具函数
└─ docs/                   设计、接口和操作文档
```

---

## 四、运行环境

建议环境：

- Python 3.10 或以上
- MySQL 8.0 或以上
- Windows PowerShell / macOS Terminal / Linux Shell
- 浏览器：Chrome、Edge 或 Firefox

Python 依赖主要包括：

- Flask
- PyMySQL

---

## 五、安装依赖

进入项目目录：

```powershell
cd "项目目录"
```

安装依赖：

```powershell
python -m pip install -r requirements.txt
```

如果网络较慢或 SSL 报错，可以多执行几次，或更换 pip 镜像源。

---

## 六、初始化数据库

初始化数据库前，需要先确保本机已经安装并启动 MySQL。

### 1. 设置数据库管理员账号

请根据本机 MySQL 情况设置管理员账号和密码。

```powershell
$env:DB_ADMIN_USER="root"
$env:DB_ADMIN_PASSWORD="你的MySQL-root密码"
$env:DB_NAME="football_manager"
```

### 2. 设置应用数据库账号

应用账号用于系统运行时连接数据库。可以自行修改用户名和密码。

```powershell
$env:DB_APP_USER="football_app"
$env:DB_APP_PASSWORD="请设置一个应用数据库密码"
```

### 3. 执行初始化

```powershell
python init_db.py
```

初始化脚本会完成以下工作：

1. 创建或重建项目数据库；
2. 创建数据库表、外键、约束和视图；
3. 导入课程演示数据；
4. 创建应用数据库账号；
5. 授权应用账号访问项目数据库；
6. 自动计算积分榜和球员统计。

初始化成功后，会看到类似输出：

```text
数据库初始化完成
数据库：football_manager
应用账号：football_app
球队：20
球员：438
比赛：20
事件：94
积分榜行数：20
球员统计行数：438
```

> 注意：`schema.sql` 会删除并重建同名表，运行前请备份已有数据。

---

## 七、启动系统

初始化数据库成功后，设置运行环境变量。

```powershell
$env:DB_USER="football_app"
$env:DB_PASSWORD="上一步设置的应用数据库密码"
$env:DB_NAME="football_manager"
$env:ADMIN_KEY="请设置一个管理员密钥"
$env:SECRET_KEY="请设置一个本地会话密钥"
```

然后启动系统：

```powershell
python app.py
```

成功后会看到：

```text
Running on http://127.0.0.1:5000
```

浏览器打开：

```text
http://127.0.0.1:5000/
```

---

## 八、后台登录

后台登录页面：

```text
http://127.0.0.1:5000/admin-login.html
```

输入启动系统时设置的管理员密钥：

```text
ADMIN_KEY
```

登录成功后会进入后台管理页面：

```text
http://127.0.0.1:5000/admin.html
```

后台页面用于管理：

- 赛季
- 赛事
- 球队
- 球员
- 比赛
- 比赛事件
- 出场记录
- 全量重算统计

项目不在代码中保存默认管理员密码。管理员密钥由环境变量 `ADMIN_KEY` 设置。

---

## 九、常用访问地址

```text
首页 / 球队展示：
http://127.0.0.1:5000/

球员列表：
http://127.0.0.1:5000/players.html

赛程赛果：
http://127.0.0.1:5000/matches.html

积分榜：
http://127.0.0.1:5000/standings.html

射手榜：
http://127.0.0.1:5000/scorers.html

球员统计：
http://127.0.0.1:5000/player_stats.html

后台登录：
http://127.0.0.1:5000/admin-login.html

后台管理：
http://127.0.0.1:5000/admin.html
```

---

## 十、可选检查

后端启动前，可以运行测试脚本检查数据库内容。

```powershell
$env:DB_USER="football_app"
$env:DB_PASSWORD="上一步设置的应用数据库密码"
$env:DB_NAME="football_manager"

python smoke_test.py
```

如果数据库连接、表结构和基础数据正常，测试脚本会输出对应检查结果。

---

## 十一、比分与统计规则

### 1. 比分计算规则

比分来自 `MatchEvent` 表：

| 事件类型 | 对比分的影响 |
|---|---|
| `goal` | 进球球员所属球队加 1 |
| `penalty_goal` | 进球球员所属球队加 1 |
| `own_goal` | 对方球队加 1 |
| `yellow_card` | 不影响比分 |
| `red_card` | 不影响比分 |
| `substitution` | 不影响比分 |

管理员不能直接手工录入比分。新增、修改或删除比赛事件后，比分会随事件自动变化。

---

### 2. 积分榜计算规则

积分榜只统计状态为：

```text
finished
```

的比赛。

积分规则：

| 比赛结果 | 积分 |
|---|---|
| 胜 | 3 分 |
| 平 | 1 分 |
| 负 | 0 分 |

排名规则依次为：

1. 积分高者排名靠前；
2. 积分相同看净胜球；
3. 净胜球相同看进球数；
4. 仍相同则按球队名称排序。

---

### 3. 球员统计规则

球员统计来自 `PlayerStat` 表，由统计模块自动生成。

| 字段 | 来源 |
|---|---|
| `appearances` | 来自 `MatchAppearance` 出场记录 |
| `goals` | 来自 `goal` 和 `penalty_goal` 事件 |
| `assists` | 来自进球事件中的 `related_player_id` |
| `yellow_cards` | 来自 `yellow_card` 事件 |
| `red_cards` | 来自 `red_card` 事件 |

乌龙球只影响比分，不计入球员正常进球数。

---

### 4. 射手榜规则

射手榜基于 `PlayerStat` 表生成，只展示进球数大于 0 的球员。

排序规则：

1. 进球数降序；
2. 助攻数降序；
3. 出场次数升序；
4. 球员姓名升序。

---

## 十二、统计模块说明

统计模块位于：

```text
stat_service.py
```

核心函数包括：

```text
get_match_scope()
get_match_score()
recalculate_standings()
recalculate_player_stats()
recalculate_all()
```

### 1. get_match_scope()

根据比赛编号查询该比赛所属的赛季和赛事，用于确定统计重算范围。

### 2. get_match_score()

从 `MatchScoreView` 中读取某场比赛自动计算出的比分。

### 3. recalculate_standings()

全量重算积分榜。

主要流程：

1. 获取所有参赛球队；
2. 初始化每支球队的场次、胜平负、进失球和积分为 0；
3. 查询所有已结束比赛；
4. 从 `MatchScoreView` 获取比分；
5. 根据比分计算胜平负和积分；
6. 删除旧的 `Standing` 记录；
7. 插入新的积分榜统计结果。

### 4. recalculate_player_stats()

全量重算球员统计。

主要流程：

1. 获取所有参赛球员；
2. 根据 `MatchAppearance` 统计出场次数；
3. 根据 `MatchEvent` 统计进球、黄牌和红牌；
4. 根据进球事件中的 `related_player_id` 统计助攻；
5. 删除旧的 `PlayerStat` 记录；
6. 插入新的球员统计结果。

### 5. recalculate_all()

统一重算入口，依次调用：

```text
recalculate_standings()
recalculate_player_stats()
```

后台点击“全量重算统计”时，会调用该函数重新生成积分榜和球员统计。

---

## 十三、主要 API 接口

### 1. 基础查询接口

```text
GET /api/teams
GET /api/players
GET /api/matches
GET /api/standings
GET /api/scorers
GET /api/player-stats
```

### 2. 后台写操作接口

后台写操作需要管理员登录或管理员密钥。

```text
POST   /api/seasons
PUT    /api/seasons/<season_id>
DELETE /api/seasons/<season_id>

POST   /api/tournaments
PUT    /api/tournaments/<tournament_id>
DELETE /api/tournaments/<tournament_id>

POST   /api/teams
PUT    /api/teams/<team_id>
DELETE /api/teams/<team_id>

POST   /api/players
PUT    /api/players/<player_id>
DELETE /api/players/<player_id>

POST   /api/matches
PUT    /api/matches/<match_id>
DELETE /api/matches/<match_id>

POST   /api/matches/<match_id>/events
PUT    /api/events/<event_id>
DELETE /api/events/<event_id>

POST   /api/matches/<match_id>/appearances
PUT    /api/appearances/<appearance_id>
DELETE /api/appearances/<appearance_id>
```

### 3. 统计重算接口

```text
POST /api/admin/recalculate
```

作用：重新计算积分榜和球员统计。

---

## 十四、管理员权限说明

系统使用后台登录机制保护管理页面。

- 普通用户可以访问前台页面；
- 普通用户不能直接进入后台管理页面；
- 访问 `/admin.html` 时，如果未登录，会跳转到 `/admin-login.html`；
- 登录成功后，后端通过 session 保存管理员状态；
- 后台写操作仍然由后端权限校验保护；
- 管理员密钥由环境变量 `ADMIN_KEY` 设置；
- 本地会话密钥由环境变量 `SECRET_KEY` 设置。

---

## 十五、删除数据说明

由于系统使用外键约束保证数据完整性，部分数据不能直接删除。

例如：

- 如果球队已经参与比赛，则不能直接删除；
- 如果球员已经有比赛事件或出场记录，则不能直接删除；
- 如果赛季或赛事已经关联比赛，则不能直接删除。

这样设计是为了防止出现子表记录引用不存在的父表记录，保证数据库参照完整性。

如果只是新增了一个测试球队，且没有比赛、球员事件或出场记录，系统会先清理其积分榜等派生统计记录，再删除球队。

---

## 十六、课程演示数据说明

当前 `sample_data.sql` 为课程演示数据集。

说明：

- 数据用于课程项目展示；
- 项目聚焦单赛季、单赛事；
- 赛程、球队、球员和事件数据用于演示系统功能；
- `Standing` 和 `PlayerStat` 是派生统计结果，不是原始事实；
- 直接绕过后端修改数据库后，应在后台点击“全量重算统计”。

---

## 十七、常见问题

### 1. 访问页面显示 Not Found

请确认：

1. 是否在正确项目目录运行 `python app.py`；
2. 项目中是否存在 `frontend/` 文件夹；
3. `frontend/` 下是否有对应 HTML 文件；
4. Flask 是否正常启动在 `127.0.0.1:5000`。

---

### 2. 页面能打开，但数据加载失败

通常是数据库连接失败。请检查：

```powershell
$env:DB_USER
$env:DB_PASSWORD
$env:DB_NAME
```

是否和初始化时创建的应用账号一致。

---

### 3. 后台登录失败

请检查启动系统时设置的：

```powershell
$env:ADMIN_KEY
```

登录时输入的密钥必须与 `ADMIN_KEY` 一致。

---

### 4. 删除球队失败

这是外键约束保护导致的。若球队已经有关联比赛、球员、积分榜或统计数据，系统会拒绝直接删除，以避免破坏数据完整性。

---

### 5. 修改事件后积分榜没有变化

可以进入后台点击：

```text
全量重算统计
```

系统会重新生成积分榜和球员统计。

---

## 十八、GitHub 上传建议

上传 GitHub 前，建议确认 `.gitignore` 已经排除以下内容：

```text
__pycache__/
*.pyc
venv/
.venv/
.env
*.zip
*.rar
*.7z
*.log
sample_data_before_*.sql
fix_*.py
patch_*.py
raw_*.json
fotmob_match_cache/
```

不要把本机 MySQL root 密码、`.env` 文件或临时调试脚本上传到公开仓库。

---

## 十九、项目分工说明

本项目可以按如下方式分工：

1. 数据库设计与数据初始化  
   负责表结构设计、约束设计、视图设计和初始数据导入。

2. 后端接口与业务逻辑实现  
   负责 Flask 后端接口、数据库连接、增删改查和权限控制。

3. 前端页面与交互展示  
   负责前台页面、后台页面、搜索筛选、折叠展开和页面样式。

4. 统计模块与项目文档整理  
   负责积分榜、射手榜、球员统计、比赛事件统计、出场统计、全量重算机制和项目报告整理。

统计模块核心文件：

```text
stat_service.py
```

主要负责：

```text
从 Match、MatchEvent、MatchAppearance 原始数据
自动生成 MatchScoreView、Standing、PlayerStat 派生结果
```

---

## 二十、项目总结

本系统围绕英超赛事信息管理场景，实现了从数据库设计、后端接口、前端展示到统计模块的完整流程。系统不仅支持球队、球员和比赛等基础数据管理，还支持比赛事件、出场记录、自动比分、积分榜、射手榜和球员统计等功能。

系统的核心特点是将比赛事件和出场记录作为原始事实数据，通过 `MatchScoreView` 自动计算比分，通过 `Standing` 和 `PlayerStat` 保存物化统计结果，并通过全量重算机制保证统计结果与原始数据一致。

整体而言，本系统结构清晰、功能完整，能够较好地满足数据库课程项目展示和足球赛事信息管理的基本需求。# Football-Manager-Project
