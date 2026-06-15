-- 创建 DWD 数据库
CREATE DATABASE IF NOT EXISTS dwd;
USE dwd;

-- DWD 层表（ORC 格式，按日期分区）
CREATE TABLE dwd_user_behavior (
    user_id BIGINT,
    item_id BIGINT,
    category_id BIGINT,
    behavior STRING,
    hour INT
)
PARTITIONED BY (dt STRING)
STORED AS ORC;

-- 从 ODS 表插入数据，转换时间戳为日期和小时
INSERT OVERWRITE TABLE dwd_user_behavior PARTITION(dt)
SELECT
    user_id,
    item_id,
    category_id,
    behavior,
    HOUR(FROM_UNIXTIME(ts)) AS hour,
    FROM_UNIXTIME(ts, 'yyyy-MM-dd') AS dt
FROM ods.ods_user_behavior;

-- 验证分区
SHOW PARTITIONS dwd_user_behavior;
