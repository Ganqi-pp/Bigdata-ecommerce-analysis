import random
import time
import csv

# 配置参数
num_rows = 100000            # 生成 10 万条数据
output_file = "UserBehavior.csv"
behaviors = ['pv', 'buy', 'cart', 'fav']

# ID 范围
user_range = (1, 20000)      # 2 万用户
item_range = (1, 50000)      # 5 万商品
category_range = (1, 3000)   # 3 千类目

# 时间范围：2017-11-25 00:00:00 到 2017-12-03 23:59:59
start_ts = int(time.mktime((2017, 11, 25, 0, 0, 0, 0, 0, 0)))
end_ts   = int(time.mktime((2017, 12,  3, 23, 59, 59, 0, 0, 0)))

with open(output_file, 'w', newline='') as csvfile:
    writer = csv.writer(csvfile)
    for _ in range(num_rows):
        user_id = random.randint(*user_range)
        item_id = random.randint(*item_range)
        cat_id  = random.randint(*category_range)
        behavior = random.choice(behaviors)
        ts = random.randint(start_ts, end_ts)
        writer.writerow([user_id, item_id, cat_id, behavior, ts])

print(f"✅ 已生成 {num_rows} 条数据到 {output_file}")
