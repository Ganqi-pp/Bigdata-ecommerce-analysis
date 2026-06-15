-- 创建 ODS 数据库
CREATE DATABASE IF NOT EXISTS ods;
USE ods;

-- ODS 层外部表（文本格式）
CREATE EXTERNAL TABLE ods_user_behavior (
    user_id BIGINT,
    item_id BIGINT,
    category_id BIGINT,
    behavior STRING,
    ts BIGINT
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

-- 加载数据（请确保 CSV 文件已通过 docker cp 放入容器内 /tmp/UserBehavior.csv）
LOAD DATA LOCAL INPATH '/tmp/UserBehavior.csv' OVERWRITE INTO TABLE ods_user_behavior;

-- 验证
SELECT COUNT(*) FROM ods_user_behavior;
