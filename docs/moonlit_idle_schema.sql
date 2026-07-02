-- 月下远征：纯放置探索第一版数据库
-- 使用方式：在 flutter_text 数据库中执行。
-- 设计重点：
-- 1. 大世界架构：区域 -> 关卡 -> 路线。
-- 2. 第一阶段只开放“南境裂谷与暮色镇 / 暮色镇周边探索”。
-- 3. 线索分为当前持有 amount 与历史累计 total_earned。
-- 4. “玛克莱遗址深入”解锁后常驻显示，但每次进入需要门票。

SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS idle_regions (
  id INT PRIMARY KEY AUTO_INCREMENT,
  region_key VARCHAR(100) NOT NULL UNIQUE,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  sort_order INT NOT NULL DEFAULT 0,
  unlocked TINYINT NOT NULL DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS idle_stages (
  id INT PRIMARY KEY AUTO_INCREMENT,
  region_id INT NOT NULL,
  stage_key VARCHAR(100) NOT NULL UNIQUE,
  name VARCHAR(100) NOT NULL,
  stage_type VARCHAR(50) NOT NULL DEFAULT 'idle_collect',
  description TEXT,
  unlock_mode VARCHAR(50) NOT NULL DEFAULT 'manual',
  sort_order INT NOT NULL DEFAULT 0,
  unlocked TINYINT NOT NULL DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (region_id) REFERENCES idle_regions(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS idle_routes (
  id INT PRIMARY KEY AUTO_INCREMENT,
  stage_id INT NOT NULL,
  route_key VARCHAR(100) NOT NULL UNIQUE,
  name VARCHAR(100) NOT NULL,
  duration_seconds INT NOT NULL,
  description TEXT,
  result_title VARCHAR(100),
  result_content TEXT,
  sort_order INT NOT NULL DEFAULT 0,
  unlocked TINYINT NOT NULL DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (stage_id) REFERENCES idle_stages(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS idle_resources (
  resource_key VARCHAR(100) PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  resource_type VARCHAR(50) NOT NULL DEFAULT 'currency',
  amount INT NOT NULL DEFAULT 0,
  total_earned INT NOT NULL DEFAULT 0,
  description TEXT,
  sort_order INT NOT NULL DEFAULT 0,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS idle_upgrades (
  upgrade_key VARCHAR(100) PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  level INT NOT NULL DEFAULT 0,
  max_level INT NOT NULL DEFAULT 5,
  description TEXT,
  effect_desc TEXT,
  sort_order INT NOT NULL DEFAULT 0,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS idle_route_rewards (
  id INT PRIMARY KEY AUTO_INCREMENT,
  route_id INT NOT NULL,
  resource_key VARCHAR(100) NOT NULL,
  min_amount INT NOT NULL DEFAULT 0,
  max_amount INT NOT NULL DEFAULT 0,
  chance_percent INT NOT NULL DEFAULT 100,
  FOREIGN KEY (route_id) REFERENCES idle_routes(id) ON DELETE CASCADE,
  FOREIGN KEY (resource_key) REFERENCES idle_resources(resource_key),
  UNIQUE KEY uniq_route_reward (route_id, resource_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS idle_stage_unlock_requirements (
  id INT PRIMARY KEY AUTO_INCREMENT,
  stage_id INT NOT NULL,
  resource_key VARCHAR(100) NOT NULL,
  required_total INT NOT NULL,
  FOREIGN KEY (stage_id) REFERENCES idle_stages(id) ON DELETE CASCADE,
  FOREIGN KEY (resource_key) REFERENCES idle_resources(resource_key),
  UNIQUE KEY uniq_stage_unlock_resource (stage_id, resource_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS idle_stage_tickets (
  id INT PRIMARY KEY AUTO_INCREMENT,
  stage_id INT NOT NULL,
  resource_key VARCHAR(100) NOT NULL,
  amount INT NOT NULL,
  FOREIGN KEY (stage_id) REFERENCES idle_stages(id) ON DELETE CASCADE,
  FOREIGN KEY (resource_key) REFERENCES idle_resources(resource_key),
  UNIQUE KEY uniq_stage_ticket_resource (stage_id, resource_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS idle_upgrade_costs (
  id INT PRIMARY KEY AUTO_INCREMENT,
  upgrade_key VARCHAR(100) NOT NULL,
  target_level INT NOT NULL,
  resource_key VARCHAR(100) NOT NULL,
  amount INT NOT NULL,
  FOREIGN KEY (upgrade_key) REFERENCES idle_upgrades(upgrade_key) ON DELETE CASCADE,
  FOREIGN KEY (resource_key) REFERENCES idle_resources(resource_key),
  UNIQUE KEY uniq_upgrade_cost (upgrade_key, target_level, resource_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS idle_expeditions (
  id INT PRIMARY KEY AUTO_INCREMENT,
  route_id INT NOT NULL,
  stage_id INT NOT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'running',
  started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  finish_at TIMESTAMP NOT NULL,
  claimed_at TIMESTAMP NULL,
  result_title VARCHAR(100),
  result_content TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (route_id) REFERENCES idle_routes(id),
  FOREIGN KEY (stage_id) REFERENCES idle_stages(id),
  INDEX idx_idle_expeditions_status (status),
  INDEX idx_idle_expeditions_finish_at (finish_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS idle_expedition_rewards (
  id INT PRIMARY KEY AUTO_INCREMENT,
  expedition_id INT NOT NULL,
  resource_key VARCHAR(100) NOT NULL,
  amount INT NOT NULL,
  FOREIGN KEY (expedition_id) REFERENCES idle_expeditions(id) ON DELETE CASCADE,
  FOREIGN KEY (resource_key) REFERENCES idle_resources(resource_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS idle_discoveries (
  discovery_key VARCHAR(100) PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  discovered TINYINT NOT NULL DEFAULT 0,
  discovered_at TIMESTAMP NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 初始区域
INSERT INTO idle_regions (region_key, name, description, sort_order, unlocked)
VALUES
('twilight_rift', '南境裂谷与暮色镇', '围绕暮色镇、诺希尔森林外缘与玛克莱遗址展开的第一块开放区域。', 1, 1)
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  description = VALUES(description),
  sort_order = VALUES(sort_order),
  unlocked = VALUES(unlocked);

-- 初始关卡
INSERT INTO idle_stages
(region_id, stage_key, name, stage_type, description, unlock_mode, sort_order, unlocked)
SELECT id, 'twilight_outskirts', '暮色镇周边探索', 'idle_collect',
       '从暮色镇协会和镇外区域收集玛克莱相关线索。', 'default', 1, 1
FROM idle_regions
WHERE region_key = 'twilight_rift'
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  stage_type = VALUES(stage_type),
  description = VALUES(description),
  unlock_mode = VALUES(unlock_mode),
  sort_order = VALUES(sort_order),
  unlocked = VALUES(unlocked);

INSERT INTO idle_stages
(region_id, stage_key, name, stage_type, description, unlock_mode, sort_order, unlocked)
SELECT id, 'maclay_ruins_deep', '玛克莱遗址深入', 'idle_ticket_stage',
       '线索集齐后常驻显示的深入关卡。每次进入都需要消耗线索门票。', 'requirements', 2, 0
FROM idle_regions
WHERE region_key = 'twilight_rift'
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  stage_type = VALUES(stage_type),
  description = VALUES(description),
  unlock_mode = VALUES(unlock_mode),
  sort_order = VALUES(sort_order);

-- 初始资源
INSERT INTO idle_resources
(resource_key, name, resource_type, amount, total_earned, description, sort_order)
VALUES
('gold', '金币', 'currency', 0, 0, '通用升级资源。', 1),
('twilight_reputation', '暮色镇声望', 'currency', 0, 0, '用于提升暮色镇协会等级。', 2),
('twilight_intel', '暮色镇情报', 'clue', 0, 0, '协会记录、酒馆传闻和镇外失踪报告。', 10),
('dead_apostle_trace', '死徒残痕', 'clue', 0, 0, '低阶死徒活动、异常血迹和拖行痕迹。', 11),
('maclay_mark', '玛克莱旧印', 'clue', 0, 0, '黑红纹章、旧帝国石片、祭祀符文拓片。', 12),
('blood_mist_sample', '血雾样本', 'clue', 0, 0, '夜间血雾、腐败血液凝块和异常魔力雾。', 13),
('atlas_echo', '阿特拉斯残响', 'clue', 0, 0, '血雾里的王冠幻影、梦中低语和旧王座方向的呼唤。', 14),
('blood_trace_shard', '血痕残片', 'material', 0, 0, '用于血契掌控与希娅战斗熟练度。', 20),
('old_empire_fragment', '旧帝国碎片', 'material', 0, 0, '用于玛克莱档案与玛姬残响。', 21)
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  resource_type = VALUES(resource_type),
  description = VALUES(description),
  sort_order = VALUES(sort_order);

-- 初始养成
INSERT INTO idle_upgrades
(upgrade_key, name, level, max_level, description, effect_desc, sort_order)
VALUES
('twilight_guild', '暮色镇协会等级', 0, 5, '暮色镇区域基础设施。', '提高金币和声望收益，缩短暮色镇调查耗时。', 1),
('maclay_archive', '玛克莱档案等级', 0, 5, '玛克莱历史与遗址信息整理。', '提高玛克莱旧印收益，解锁更多旧帝国文本。', 2),
('shia_combat', '希娅战斗熟练度', 0, 5, '希娅在镇外巡查与死徒痕迹追踪中的熟练度。', '减少探索耗时，提高死徒残痕收益。', 3),
('blood_contract_control', '血契掌控', 0, 5, '对血雾和血契异常的稳定控制。', '提高血雾样本收益，降低后续污染压力。', 4),
('magie_echo', '玛姬残响', 0, 5, '玛姬对玛克莱、鲜血日冕和阿特拉斯残留的感知。', '提高阿特拉斯残响发现率，削弱后续 Boss 压力。', 5)
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  max_level = VALUES(max_level),
  description = VALUES(description),
  effect_desc = VALUES(effect_desc),
  sort_order = VALUES(sort_order);

-- 第一关探索路线。测试阶段可以把 duration_seconds 改短。
INSERT INTO idle_routes
(stage_id, route_key, name, duration_seconds, description, result_title, result_content, sort_order, unlocked)
SELECT id, 'twilight_investigation', '暮色镇调查', 180,
       '在暮色镇协会、酒馆和镇外记录中收集基础情报。',
       '暮色镇调查完成',
       '你在冒险者协会旧柜台里找到了几份失踪记录。记录上的路线都指向镇外同一片森林。',
       1, 1
FROM idle_stages
WHERE stage_key = 'twilight_outskirts'
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  duration_seconds = VALUES(duration_seconds),
  description = VALUES(description),
  result_title = VALUES(result_title),
  result_content = VALUES(result_content),
  sort_order = VALUES(sort_order),
  unlocked = VALUES(unlocked);

INSERT INTO idle_routes
(stage_id, route_key, name, duration_seconds, description, result_title, result_content, sort_order, unlocked)
SELECT id, 'forest_edge_patrol', '森林外缘巡查', 300,
       '巡查诺希尔森林外缘，寻找死徒残痕和血雾样本。',
       '森林外缘巡查完成',
       '队伍在腐叶下发现了拖行痕迹。那不是普通野兽留下的痕迹，血味太冷，也太旧。',
       2, 1
FROM idle_stages
WHERE stage_key = 'twilight_outskirts'
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  duration_seconds = VALUES(duration_seconds),
  description = VALUES(description),
  result_title = VALUES(result_title),
  result_content = VALUES(result_content),
  sort_order = VALUES(sort_order),
  unlocked = VALUES(unlocked);

INSERT INTO idle_routes
(stage_id, route_key, name, duration_seconds, description, result_title, result_content, sort_order, unlocked)
SELECT id, 'old_road_ruin_search', '旧路遗迹搜寻', 480,
       '沿镇外旧路搜寻玛克莱旧印，并尝试捕捉阿特拉斯残响。',
       '旧路遗迹搜寻完成',
       '一块黑红色石片从泥土里露出来，边缘仍残留着玛克莱旧纹章的刻痕。',
       3, 1
FROM idle_stages
WHERE stage_key = 'twilight_outskirts'
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  duration_seconds = VALUES(duration_seconds),
  description = VALUES(description),
  result_title = VALUES(result_title),
  result_content = VALUES(result_content),
  sort_order = VALUES(sort_order),
  unlocked = VALUES(unlocked);

-- 路线基础奖励
INSERT INTO idle_route_rewards (route_id, resource_key, min_amount, max_amount, chance_percent)
SELECT r.id, 'gold', 10, 10, 100 FROM idle_routes r WHERE r.route_key = 'twilight_investigation'
ON DUPLICATE KEY UPDATE min_amount = VALUES(min_amount), max_amount = VALUES(max_amount), chance_percent = VALUES(chance_percent);
INSERT INTO idle_route_rewards (route_id, resource_key, min_amount, max_amount, chance_percent)
SELECT r.id, 'twilight_intel', 1, 2, 100 FROM idle_routes r WHERE r.route_key = 'twilight_investigation'
ON DUPLICATE KEY UPDATE min_amount = VALUES(min_amount), max_amount = VALUES(max_amount), chance_percent = VALUES(chance_percent);
INSERT INTO idle_route_rewards (route_id, resource_key, min_amount, max_amount, chance_percent)
SELECT r.id, 'twilight_reputation', 1, 1, 100 FROM idle_routes r WHERE r.route_key = 'twilight_investigation'
ON DUPLICATE KEY UPDATE min_amount = VALUES(min_amount), max_amount = VALUES(max_amount), chance_percent = VALUES(chance_percent);

INSERT INTO idle_route_rewards (route_id, resource_key, min_amount, max_amount, chance_percent)
SELECT r.id, 'gold', 8, 8, 100 FROM idle_routes r WHERE r.route_key = 'forest_edge_patrol'
ON DUPLICATE KEY UPDATE min_amount = VALUES(min_amount), max_amount = VALUES(max_amount), chance_percent = VALUES(chance_percent);
INSERT INTO idle_route_rewards (route_id, resource_key, min_amount, max_amount, chance_percent)
SELECT r.id, 'dead_apostle_trace', 1, 3, 100 FROM idle_routes r WHERE r.route_key = 'forest_edge_patrol'
ON DUPLICATE KEY UPDATE min_amount = VALUES(min_amount), max_amount = VALUES(max_amount), chance_percent = VALUES(chance_percent);
INSERT INTO idle_route_rewards (route_id, resource_key, min_amount, max_amount, chance_percent)
SELECT r.id, 'blood_mist_sample', 1, 1, 35 FROM idle_routes r WHERE r.route_key = 'forest_edge_patrol'
ON DUPLICATE KEY UPDATE min_amount = VALUES(min_amount), max_amount = VALUES(max_amount), chance_percent = VALUES(chance_percent);
INSERT INTO idle_route_rewards (route_id, resource_key, min_amount, max_amount, chance_percent)
SELECT r.id, 'blood_trace_shard', 1, 1, 25 FROM idle_routes r WHERE r.route_key = 'forest_edge_patrol'
ON DUPLICATE KEY UPDATE min_amount = VALUES(min_amount), max_amount = VALUES(max_amount), chance_percent = VALUES(chance_percent);

INSERT INTO idle_route_rewards (route_id, resource_key, min_amount, max_amount, chance_percent)
SELECT r.id, 'gold', 6, 6, 100 FROM idle_routes r WHERE r.route_key = 'old_road_ruin_search'
ON DUPLICATE KEY UPDATE min_amount = VALUES(min_amount), max_amount = VALUES(max_amount), chance_percent = VALUES(chance_percent);
INSERT INTO idle_route_rewards (route_id, resource_key, min_amount, max_amount, chance_percent)
SELECT r.id, 'maclay_mark', 1, 2, 100 FROM idle_routes r WHERE r.route_key = 'old_road_ruin_search'
ON DUPLICATE KEY UPDATE min_amount = VALUES(min_amount), max_amount = VALUES(max_amount), chance_percent = VALUES(chance_percent);
INSERT INTO idle_route_rewards (route_id, resource_key, min_amount, max_amount, chance_percent)
SELECT r.id, 'old_empire_fragment', 1, 1, 30 FROM idle_routes r WHERE r.route_key = 'old_road_ruin_search'
ON DUPLICATE KEY UPDATE min_amount = VALUES(min_amount), max_amount = VALUES(max_amount), chance_percent = VALUES(chance_percent);
INSERT INTO idle_route_rewards (route_id, resource_key, min_amount, max_amount, chance_percent)
SELECT r.id, 'atlas_echo', 1, 1, 5 FROM idle_routes r WHERE r.route_key = 'old_road_ruin_search'
ON DUPLICATE KEY UPDATE min_amount = VALUES(min_amount), max_amount = VALUES(max_amount), chance_percent = VALUES(chance_percent);

-- “玛克莱遗址深入”的首次解锁条件：看 total_earned，不看当前 amount。
INSERT INTO idle_stage_unlock_requirements (stage_id, resource_key, required_total)
SELECT s.id, 'twilight_intel', 5 FROM idle_stages s WHERE s.stage_key = 'maclay_ruins_deep'
ON DUPLICATE KEY UPDATE required_total = VALUES(required_total);
INSERT INTO idle_stage_unlock_requirements (stage_id, resource_key, required_total)
SELECT s.id, 'dead_apostle_trace', 8 FROM idle_stages s WHERE s.stage_key = 'maclay_ruins_deep'
ON DUPLICATE KEY UPDATE required_total = VALUES(required_total);
INSERT INTO idle_stage_unlock_requirements (stage_id, resource_key, required_total)
SELECT s.id, 'maclay_mark', 4 FROM idle_stages s WHERE s.stage_key = 'maclay_ruins_deep'
ON DUPLICATE KEY UPDATE required_total = VALUES(required_total);
INSERT INTO idle_stage_unlock_requirements (stage_id, resource_key, required_total)
SELECT s.id, 'blood_mist_sample', 6 FROM idle_stages s WHERE s.stage_key = 'maclay_ruins_deep'
ON DUPLICATE KEY UPDATE required_total = VALUES(required_total);
INSERT INTO idle_stage_unlock_requirements (stage_id, resource_key, required_total)
SELECT s.id, 'atlas_echo', 3 FROM idle_stages s WHERE s.stage_key = 'maclay_ruins_deep'
ON DUPLICATE KEY UPDATE required_total = VALUES(required_total);

-- “玛克莱遗址深入”的每次进入门票：看当前 amount，会消耗。
INSERT INTO idle_stage_tickets (stage_id, resource_key, amount)
SELECT s.id, 'twilight_intel', 1 FROM idle_stages s WHERE s.stage_key = 'maclay_ruins_deep'
ON DUPLICATE KEY UPDATE amount = VALUES(amount);
INSERT INTO idle_stage_tickets (stage_id, resource_key, amount)
SELECT s.id, 'dead_apostle_trace', 2 FROM idle_stages s WHERE s.stage_key = 'maclay_ruins_deep'
ON DUPLICATE KEY UPDATE amount = VALUES(amount);
INSERT INTO idle_stage_tickets (stage_id, resource_key, amount)
SELECT s.id, 'maclay_mark', 1 FROM idle_stages s WHERE s.stage_key = 'maclay_ruins_deep'
ON DUPLICATE KEY UPDATE amount = VALUES(amount);
INSERT INTO idle_stage_tickets (stage_id, resource_key, amount)
SELECT s.id, 'blood_mist_sample', 1 FROM idle_stages s WHERE s.stage_key = 'maclay_ruins_deep'
ON DUPLICATE KEY UPDATE amount = VALUES(amount);

-- 第一版升级消耗。每项最高 5 级。
INSERT INTO idle_upgrade_costs (upgrade_key, target_level, resource_key, amount) VALUES
('twilight_guild', 1, 'gold', 20),
('twilight_guild', 1, 'twilight_reputation', 2),
('twilight_guild', 2, 'gold', 40),
('twilight_guild', 2, 'twilight_reputation', 4),
('twilight_guild', 3, 'gold', 70),
('twilight_guild', 3, 'twilight_reputation', 7),
('twilight_guild', 4, 'gold', 110),
('twilight_guild', 4, 'twilight_reputation', 11),
('twilight_guild', 5, 'gold', 160),
('twilight_guild', 5, 'twilight_reputation', 16),

('maclay_archive', 1, 'maclay_mark', 2),
('maclay_archive', 2, 'maclay_mark', 4),
('maclay_archive', 2, 'old_empire_fragment', 1),
('maclay_archive', 3, 'maclay_mark', 7),
('maclay_archive', 3, 'old_empire_fragment', 2),
('maclay_archive', 4, 'maclay_mark', 11),
('maclay_archive', 4, 'old_empire_fragment', 4),
('maclay_archive', 5, 'maclay_mark', 16),
('maclay_archive', 5, 'old_empire_fragment', 6),

('shia_combat', 1, 'gold', 20),
('shia_combat', 1, 'blood_trace_shard', 1),
('shia_combat', 2, 'gold', 40),
('shia_combat', 2, 'blood_trace_shard', 2),
('shia_combat', 3, 'gold', 70),
('shia_combat', 3, 'blood_trace_shard', 4),
('shia_combat', 4, 'gold', 110),
('shia_combat', 4, 'blood_trace_shard', 7),
('shia_combat', 5, 'gold', 160),
('shia_combat', 5, 'blood_trace_shard', 11),

('blood_contract_control', 1, 'blood_trace_shard', 1),
('blood_contract_control', 1, 'blood_mist_sample', 2),
('blood_contract_control', 2, 'blood_trace_shard', 2),
('blood_contract_control', 2, 'blood_mist_sample', 4),
('blood_contract_control', 3, 'blood_trace_shard', 4),
('blood_contract_control', 3, 'blood_mist_sample', 7),
('blood_contract_control', 4, 'blood_trace_shard', 7),
('blood_contract_control', 4, 'blood_mist_sample', 11),
('blood_contract_control', 5, 'blood_trace_shard', 11),
('blood_contract_control', 5, 'blood_mist_sample', 16),

('magie_echo', 1, 'old_empire_fragment', 1),
('magie_echo', 1, 'atlas_echo', 1),
('magie_echo', 2, 'old_empire_fragment', 2),
('magie_echo', 2, 'atlas_echo', 1),
('magie_echo', 3, 'old_empire_fragment', 4),
('magie_echo', 3, 'atlas_echo', 2),
('magie_echo', 4, 'old_empire_fragment', 7),
('magie_echo', 4, 'atlas_echo', 2),
('magie_echo', 5, 'old_empire_fragment', 11),
('magie_echo', 5, 'atlas_echo', 3)
ON DUPLICATE KEY UPDATE amount = VALUES(amount);
