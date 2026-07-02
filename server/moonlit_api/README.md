# Moonlit Idle API

把本目录下的 PHP 文件上传到 NAS 网站目录：

```text
/www/wwwroot/www.random.com/moonlit/api/
```

或你当前 18980 端口对应站点的：

```text
moonlit/api/
```

## 部署步骤

1. 上传这些文件：

```text
bootstrap.php
idle_state.php
start_idle.php
claim_idle.php
upgrade_idle.php
config.example.php
```

2. 在 NAS 上复制配置文件：

```text
config.example.php -> config.php
```

3. 修改 `config.php` 里的数据库密码：

```php
'db_password' => '你的数据库密码',
```

## 测试接口

查看状态：

```text
GET http://192.168.1.108:18980/moonlit/api/idle_state.php
```

开始探索：

```text
POST http://192.168.1.108:18980/moonlit/api/start_idle.php
route_key=twilight_investigation
```

可用路线：

```text
twilight_investigation
forest_edge_patrol
old_road_ruin_search
```

领取奖励：

```text
POST http://192.168.1.108:18980/moonlit/api/claim_idle.php
```

升级养成：

```text
POST http://192.168.1.108:18980/moonlit/api/upgrade_idle.php
upgrade_key=twilight_guild
```

可用养成：

```text
twilight_guild
maclay_archive
shia_combat
blood_contract_control
magie_echo
```
