# API说明

所有接口以 `/api` 开头。

## 公共查询

| 方法 | 路径 | 说明 |
|---|---|---|
| GET | `/api/health` | 服务状态 |
| GET | `/api/seasons` | 赛季列表 |
| GET | `/api/tournaments` | 赛事列表 |
| GET | `/api/teams?q=` | 球队查询 |
| GET | `/api/teams/<id>` | 球队详情与积分 |
| GET | `/api/teams/<id>/players` | 球队球员 |
| GET | `/api/teams/<id>/matches` | 球队比赛 |
| GET | `/api/players` | 球员条件查询 |
| GET | `/api/matches` | 按轮次、球队、状态查询比赛 |
| GET | `/api/matches/<id>` | 单场比赛详情 |
| GET | `/api/matches/<id>/events` | 比赛事件 |
| GET | `/api/matches/<id>/appearances` | 出场记录 |
| GET | `/api/standings` | 积分榜 |
| GET | `/api/scorers` | 射手榜 |
| GET | `/api/player-stats` | 完整球员统计 |

## 管理接口

写接口必须带请求头：

```text
X-Admin-Key: 管理员密钥
```

| 资源 | 新增 | 修改 | 删除 |
|---|---|---|---|
| 赛季 | POST `/api/seasons` | PUT `/api/seasons/<id>` | DELETE `/api/seasons/<id>` |
| 赛事 | POST `/api/tournaments` | PUT `/api/tournaments/<id>` | DELETE `/api/tournaments/<id>` |
| 球队 | POST `/api/teams` | PUT `/api/teams/<id>` | DELETE `/api/teams/<id>` |
| 球员 | POST `/api/players` | PUT `/api/players/<id>` | DELETE `/api/players/<id>` |
| 比赛 | POST `/api/matches` | PUT `/api/matches/<id>` | DELETE `/api/matches/<id>` |
| 事件 | POST `/api/matches/<id>/events` | PUT `/api/events/<id>` | DELETE `/api/events/<id>` |
| 出场 | POST `/api/matches/<id>/appearances` | PUT `/api/appearances/<id>` | DELETE `/api/appearances/<id>` |

手动全量重算：

```text
POST /api/admin/recalculate
```

## 事件请求示例

普通进球并带助攻：

```json
{
  "player_id": 9,
  "related_player_id": 6,
  "minute": 23,
  "stoppage_minute": 0,
  "event_type": "goal"
}
```

换人：

```json
{
  "player_id": 9,
  "related_player_id": 11,
  "minute": 70,
  "stoppage_minute": 0,
  "event_type": "substitution"
}
```
