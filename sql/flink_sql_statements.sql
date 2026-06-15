-- Flink SQL 实时统计（需先加载 Kafka 连接器 jar）
-- 创建 Kafka 源表（消费 topic user_behavior）
CREATE TABLE user_behavior_source (
    user_id BIGINT,
    item_id BIGINT,
    category_id BIGINT,
    behavior STRING,
    `ts` BIGINT,
    proc_time AS PROCTIME()
) WITH (
    'connector' = 'kafka',
    'topic' = 'user_behavior',
    'properties.bootstrap.servers' = 'kafka:9092',
    'properties.group.id' = 'flink-group',
    'scan.startup.mode' = 'earliest-offset',
    'format' = 'json'
);

-- 打印结果表（输出到 TaskManager 日志）
CREATE TABLE print_sink (
    item_id BIGINT,
    cnt BIGINT,
    window_end TIMESTAMP(3)
) WITH (
    'connector' = 'print'
);

-- 每10秒统计购买行为的商品 Top 3
INSERT INTO print_sink
SELECT item_id, cnt, window_end
FROM (
    SELECT
        item_id,
        COUNT(*) AS cnt,
        TUMBLE_END(proc_time, INTERVAL '10' SECOND) AS window_end,
        ROW_NUMBER() OVER (PARTITION BY TUMBLE_END(proc_time, INTERVAL '10' SECOND) ORDER BY COUNT(*) DESC) AS rn
    FROM user_behavior_source
    WHERE behavior = 'buy'
    GROUP BY TUMBLE(proc_time, INTERVAL '10' SECOND), item_id
) t
WHERE rn <= 3;
