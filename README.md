# 2025—2026赛季英超赛事信息管理系统

这是数据库表结构改进后的完整版本。当前附带的是 **20支球队、400余名球员、2轮比赛的课程演示数据**。



## 一、安装依赖

```powershell
cd "项目目录"
python -m pip install -r requirements.txt
```

## 二、初始化数据库

请设置本机 MySQL 管理员密码：

```powershell
$env:DB_ADMIN_USER="root"
$env:DB_ADMIN_PASSWORD="你的MySQL root密码"
$env:DB_NAME="football_manager"

# 应用账号，可自行修改
$env:DB_APP_USER="football_app"
$env:DB_APP_PASSWORD="请设置一个应用数据库密码"

python init_db.py
```

`init_db.py` 会：

1. 创建或重建项目表；
2. 导入演示数据；
3. 创建最小权限应用账户；
4. 自动计算积分榜和球员统计。

> 警告：`schema.sql` 会删除并重建同名表，运行前请备份已有数据。

## 三、启动系统

```powershell
$env:DB_USER="football_app"
$env:DB_PASSWORD="上一步设置的应用数据库密码"
$env:DB_NAME="football_manager"
$env:ADMIN_KEY="请设置一个管理员密钥"

python app.py
```

浏览器打开：

```text
http://127.0.0.1:5000/
```

后台管理：

```text
http://127.0.0.1:5000/admin.html
```

后台页面使用你设置的 `ADMIN_KEY`。项目不在代码中保存默认管理员密码。


## 四、可选检查

后端启动前，可检查数据库内容：

```powershell
$env:DB_USER="football_app"
$env:DB_PASSWORD="上一步设置的应用数据库密码"
$env:DB_NAME="football_manager"

python smoke_test.py
```

## 五、比分与统计规则

### 比分

比分来自 MatchEvent：

- `goal`：进球球员所属球队加1；
- `penalty_goal`：进球球员所属球队加1；
- `own_goal`：对方球队加1；
- 其他事件不影响比分。

管理员不能直接改比分。新增、修改或删除事件后，比分会即时变化。

### 积分榜

只统计 `finished` 比赛：

- 胜3分；
- 平1分；
- 负0分；
- 依次按积分、净胜球、进球数、球队名称排序。

### 球员统计

- 出场次数来自 MatchAppearance；
- 进球来自 `goal` 和 `penalty_goal`；
- 助攻来自进球事件的 `related_player_id`；
- 红黄牌来自对应事件；
- 乌龙球不计入正常进球数。

## 六、项目结构

```text
app.py                 Flask页面与API
stat_service.py        积分榜、球员统计全量重算
init_db.py             数据库初始化
schema.sql             数据库结构与视图
sample_data.sql        课程演示数据
frontend/              前端页面、CSS、JavaScript
docs/                  设计、接口和操作文档
```

## 七、重要说明

- 项目聚焦单赛季、单赛事；
- 当前数据为课程演示子集；
- `Standing` 与 `PlayerStat` 是物化统计结果，不是原始事实；
- 直接在数据库中绕过后端修改原始数据后，应在后台点击“全量重算统计”；
- 本地开发服务器仅用于课程演示，不用于公网部署。

## 八、系统测试

### 初始化测试

通过 `init_db.py` 初始化数据库。在初始化完成后，系统输出球队数、球员数、比赛数、事件数、积分榜行数和球员统计行数，用于验证数据库导入和统计模块是否正常。

### 前台查询测试

测试内容包括：

- 球队列表是否正常显示；
- 球员列表是否正常显示；
- 赛程赛果是否正常显示；
- 积分榜是否按规则排序；
- 射手榜是否只展示有进球的球员；
- 球员统计是否包含出场、进球、助攻、黄牌和红牌。

### 后台管理测试

测试内容包括：

- 管理员是否能够登录后台；
- 是否能够新增、修改和删除基础数据；
- 是否能够新增、修改和删除比赛事件；
- 是否能够新增、修改和删除出场记录；
- 点击全量重算统计后，积分榜和球员统计是否正确刷新。

### 数据一致性测试

测试内容包括：

- 新增进球事件后，比赛比分是否变化；
- 新增进球事件后，射手榜是否变化；
- 新增黄牌或红牌事件后，球员统计是否变化；
- 修改比赛状态后，积分榜是否重新计算；
- 删除事件后，统计结果是否同步更新。


## 九、主要改进

- 保留 Season、Tournament、Team、Player、Match、MatchEvent、Standing、PlayerStat 核心结构；
- 新增 MatchAppearance，用真实出场记录计算 `appearances`；
- 删除 MatchEvent 中冗余的 `team_id`，事件所属球队通过 Player 推导；
- 比分不再手工录入，由进球、点球和乌龙球事件自动计算；
- 助攻直接关联到对应进球，换人用一条事件关联换下与换上球员；
- 增加主客队不同、队内号码唯一、关键字段非空等约束；
- 补齐球队、球员、比赛、事件的增删改查；
- 增加球队主页、完整比赛详情、比赛筛选、球员筛选；
- 后台使用下拉框，不再要求管理员记忆各种ID；
- Standing 和 PlayerStat 明确作为物化统计表，由事务内全量重算；
- 使用最小权限应用账户，写接口要求管理员密钥；
- Flask直接提供前端，启动一个服务即可。
