import csv
import json
import time
from kafka import KafkaProducer

# 配置 Kafka 生产者（请确保 bootstrap_servers 正确）
producer = KafkaProducer(
    bootstrap_servers='localhost:9092',
    value_serializer=lambda v: json.dumps(v).encode('utf-8')
)

csv_file = '../UserBehavior.csv'   # 相对于脚本路径，或使用绝对路径
topic = 'user_behavior'

# 发送数据
with open(csv_file, 'r') as f:
    reader = csv.reader(f)
    for i, row in enumerate(reader):
        message = {
            'user_id': int(row[0]),
            'item_id': int(row[1]),
            'category_id': int(row[2]),
            'behavior': row[3],
            'ts': int(row[4])
        }
        producer.send(topic, value=message)
        if (i + 1) % 10000 == 0:
            print(f"已发送 {i+1} 条消息")

producer.flush()
producer.close()
print("所有数据发送完成")
