-- 使用 DWD 层表进行各项指标分析
USE dwd;

-- 1. 每日 PV / UV
SELECT
    dt,
    SUM(CASE WHEN behavior='pv' THEN 1 ELSE 0 END) AS pv,
    COUNT(DISTINCT CASE WHEN behavior='pv' THEN user_id END) AS uv
FROM dwd_user_behavior
GROUP BY dt
ORDER BY dt;

-- 2. 用户转化率（点击 → 购买）
SELECT
    COUNT(DISTINCT CASE WHEN behavior='pv' THEN user_id END) AS pv_users,
    COUNT(DISTINCT CASE WHEN behavior='buy' THEN user_id END) AS buy_users,
    ROUND(COUNT(DISTINCT CASE WHEN behavior='buy' THEN user_id END) * 100.0 /
          COUNT(DISTINCT CASE WHEN behavior='pv' THEN user_id END), 2) AS conversion_rate
FROM dwd_user_behavior;

-- 3. 各时段（小时）活跃度
SELECT
    hour,
    COUNT(DISTINCT user_id) AS uv,
    SUM(CASE WHEN behavior='pv' THEN 1 ELSE 0 END) AS pv
FROM dwd_user_behavior
GROUP BY hour
ORDER BY hour;

-- 4. 次日留存率（以 2017-11-25 为例）
WITH first_visit AS (
    SELECT user_id, MIN(dt) AS first_dt
    FROM dwd_user_behavior
    GROUP BY user_id
)
SELECT
    COUNT(DISTINCT a.user_id) AS new_users,
    COUNT(DISTINCT b.user_id) AS retained_users,
    ROUND(COUNT(DISTINCT b.user_id) * 100.0 / COUNT(DISTINCT a.user_id), 2) AS retention_rate
FROM first_visit a
LEFT JOIN dwd_user_behavior b ON a.user_id = b.user_id AND b.dt = DATE_ADD(a.first_dt, 1)
WHERE a.first_dt = '2017-11-25';

-- 5. 热门商品 Top 10（按购买次数）
SELECT
    item_id,
    COUNT(*) AS buy_cnt
FROM dwd_user_behavior
WHERE behavior = 'buy'
GROUP BY item_id
ORDER BY buy_cnt DESC
LIMIT 10;
