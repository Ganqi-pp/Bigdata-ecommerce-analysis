# 电商用户行为分析平台（离线数仓 + 实时流处理尝试）
![Hive](https://img.shields.io/badge/Hive-4.0.0-FF7A00?logo=apachehive)
![Flink](https://img.shields.io/badge/Flink-1.18.1-E6526F?logo=apacheflink)
![Kafka](https://img.shields.io/badge/Kafka-2.8-231F20?logo=apachekafka)
![Docker](https://img.shields.io/badge/Docker-24.0-2496ED?logo=docker)
## 项目简介
模拟电商用户行为数据，构建 Hive 离线数仓（ODS → DWD → ADS），分析核心运营指标（PV/UV、转化率、留存率、热门商品等）。同时尝试使用 Kafka + Flink 进行实时统计（因环境配置问题未完全跑通，但已完成数据生产和 Flink SQL 作业设计）。

## 技术栈
- **容器化**：Docker Compose
- **数据存储**：Hive（Metastore: MySQL）、HDFS
- **消息队列**：Kafka（ZooKeeper）
- **实时计算**：Flink SQL
- **其他**：Redis、Python（数据生成/生产）
## 项目结构
bigdata-ecommerce-analysis/
├── docker-compose.yml # 容器编排文件
├── Dockerfile.flink # 自定义 Flink 镜像（含 Kafka 连接器）
├── .gitignore # Git 忽略文件配置
├── README.md # 项目说明
├── scripts/
│ ├── generate_data.py # 生成模拟用户行为 CSV 数据
│ └── producer.py # 将 CSV 数据发送到 Kafka
├── sql/
│ ├── 01_ods_table.sql # ODS 层建表及数据加载
│ ├── 02_dwd_table.sql # DWD 层分区表及 ETL
│ ├── 03_analysis_indicators.sql # 离线分析指标 SQL（PV/UV、转化率、留存率等）
│ └── flink_sql_statements.sql # Flink SQL 实时统计（未完全实现）
└── docs/
└── architecture.png # 架构图（可选）

## 快速开始

### 环境要求
- Docker Desktop (WSL2 backend)
- Docker Compose V2
- Python 3.8+（用于运行数据生成脚本）

### 部署步骤
1. **克隆项目**（替换为你的仓库地址）
   git clone https://github.com/你的用户名/bigdata-ecommerce-analysis.git
   cd bigdata-ecommerce-analysis
2. 启动所有服务
   docker compose up -d

3. 生成模拟数据
   python scripts/generate_data.py
4. 将数据加载到Hive
   docker cp UserBehavior.csv hive-server:/tmp/
   docker exec -it hive-server /opt/hive/bin/beeline -u jdbc:hive2://localhost:10000
   -- 在 Beeline 中执行 sql/01_ods_table.sql 和 sql/02_dwd_table.sql 中的语句
5. 运行离线分析
   连接 Hive Beeline，执行 sql/03_analysis_indicators.sql 中的查询。
实时处理（实验性）
发送数据到 Kafka：python scripts/producer.py

启动 Flink SQL 客户端并执行 sql/flink_sql_statements.sql（需先修复 Kafka 网络配置，详见项目问题记录）。
分析指标示例
每日 PV / UV

用户转化率（点击 → 购买）

各时段活跃度

次日留存率

热门商品 Top 10

详细 SQL 请查看 sql/03_analysis_indicators.sql。


遇到的问题及解决
Docker 存储空间不足 → 迁移 WSL 虚拟磁盘到 D 盘。

Hive 容器启动即退出 → 删除错误 command，使用镜像默认启动命令。

Flink 缺少 Kafka 连接器 → 下载 jar 并挂载或构建自定义镜像。

Kafka 容器间网络不通 → 需配置 advertised.listeners（详见 Issue）。

后续改进方向
修复 Kafka + Flink 实时统计链路，输出结果到 Redis/Grafana。

引入数据质量校验工具（Apache Griffin）。

使用 Airflow 调度 ETL 任务。
