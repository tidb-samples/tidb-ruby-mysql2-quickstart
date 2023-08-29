# 使用 mysql2 gem 连接 TiDB 集群

[![语言](https://img.shields.io/badge/语言-Ruby-c11b17.svg)](https://www.ruby-lang.org/zh_cn/)
[![驱动](https://img.shields.io/badge/驱动-mysql2-blue.svg)](https://github.com/brianmario/mysql2)

以下指南将向你展示如何使用 Ruby 驱动器 [mysql2](https://github.com/brianmario/mysql2) 连接到 TiDB 集群，并执行基本的 SQL 操作，如创建、读取、更新和删除。

> **注意：**
>
> TiDB 是一个兼容 MySQL 的数据库，这意味着你可以在应用程序中使用来自 MySQL 生态系统的熟悉的驱动/ORM 框架连接到 TiDB 集群。
>
> 唯一的区别是，如果你使用公共端点连接到 TiDB Serverless 集群，你**必须** [在 mysql2 驱动上启用 TLS 连接](#连接到tidb集群)。

## 前提条件

要完成本指南，你需要：

- 机器上安装了 [Ruby](https://www.ruby-lang.org/zh_cn/) 版本 >= 3.0
- 机器上安装了 [Bundler](https://bundler.io/)
- 机器上安装了 [Git](https://git-scm.com/downloads)
- 运行中的 TiDB 集群

**如果你还没有 TiDB 集群，请使用以下其中一种方式创建一个：**

1. （**推荐**）立即在 TiDB Cloud 上[启动一个 TiDB Serverless 集群](https://tidbcloud.com/free-trial?utm_source=github&utm_medium=quickstart)。
2. 在你的本地机器上使用 TiUP CLI [启动一个 TiDB Playground 集群](https://docs.pingcap.com/zh/tidb/stable/quick-start-with-tidb#部署本地测试集群)。

## 入门

本节将演示如何运行示例应用程序代码并使用 `mysql2` 驱动连接到 TiDB。

### 1. 克隆仓库

运行以下命令将样本代码本地化：

```shell
git clone https://github.com/tidb-samples/tidb-ruby-mysql2-quickstart.git
cd tidb-ruby-mysql2-quickstart
```

### 2. 安装依赖项

运行以下命令安装样本代码所需的依赖项（包括 `mysql2` 包）：

```shell
bundle install
```

<details>
<summary><b>安装依赖项到现有项目</b></summary>

对于你的现有项目，运行以下命令安装以下包：

- `mysql2`：Ruby 的 MySQL 驱动，用于数据库连接和 SQL 操作。
- `dotenv`：加载 `.env` 文件中环境变量的实用程序包。

```shell
bundle add mysql2 dotenv
```
</details>


### 3. 获取连接参数

<details open>
<summary><b>(选项 1) TiDB Serverless</b></summary>

您可以通过以下步骤在[TiDB Cloud的Web控制台](https://tidbcloud.com/free-trial?utm_source=github&utm_medium=quickstart)获取数据库连接参数：

1. 导航至[集群](https://tidbcloud.com/console/clusters)页面，然后点击目标集群的名称，进入其概述页面。
2. 在右上角点击**连接**。
3. 在连接对话框中，从**连接方式**下拉列表中选择`通用`，并保持**终端类型**的默认设置为`公开`。
4. 如果您还没有设置密码，请点击**创建密码**生成一个随机密码。
5. 复制代码块上显示的连接参数。

    <div align="center">
        <picture>
            <source media="(prefers-color-scheme: dark)" srcset="./static/images/tidb-cloud-connect-dialog-dark-theme.png" width="600">
            <img alt="The connection dialog of TiDB Serverless" src="./static/images/tidb-cloud-connect-dialog-light-theme.png" width="600">
        </picture>
        <div><i>TiDB Serverless的连接对话框</i></div>
    </div>

</details>

<details>
<summary><b>(选项 2) TiDB独立版</b></summary>

您可以通过以下步骤在[TiDB Cloud的Web控制台](https://tidbcloud.com/console)获取数据库连接参数：

1. 导航至[集群](https://tidbcloud.com/console/clusters)页面，然后点击目标集群的名称，进入其概述页面。
2. 点击右上角的**连接**。将显示连接对话框。
3. 为集群创建流量过滤器。

   1. 点击**允许任何地方的访问**，添加一个新的CIDR地址规则，允许来自任何IP地址的客户端访问。
   2. 点击**创建过滤器**确认变更。

4. 在对话框的**步骤2：下载TiDB集群CA**下，点击**下载TiDB集群CA**，以便于TLS连接到TiDB集群。
5. 在对话框的**步骤3：用SQL客户端连接**下，从**连接方式**下拉列表中选择`通用`，并从**终端类型**下拉列表中选择`公开`。
6. 复制代码块上显示的连接参数。

</details>

<details>
<summary><b>(选项 3) TiDB 自托管</b></summary>

   为你的集群准备以下连接参数：

  - **主机**：运行TiDB集群的IP地址或域名（例如：`127.0.0.1`）。
  - **端口**：数据库服务器运行的端口（默认：`4000`）。
  - **用户**：数据库用户名（默认：`root`）。
  - **密码**：数据库用户密码（TiDB Playground 默认无密码）。

</details>

### 4. 设置环境变量

<details open>
   <summary><b>(选项 1) TiDB Serverless</b></summary>

   1. 复制 `.env.example` 文件到 `.env` 文件。
   2. 编辑 `.env` 文件，并替换 `<host>`, `<user>`, 和 `<password>` 的占位符为复制的连接参数。
   3. 将 `DATABASE_ENABLE_SSL` 修改为 `true` 以启用 TLS 连接。（公共端点需要）

   ```dotenv
   DATABASE_HOST=<host>
   DATABASE_PORT=4000
   DATABASE_USER=<user>
   DATABASE_PASSWORD=<password>
   DATABASE_NAME=test
   DATABASE_ENABLE_SSL=true
   ```

</details>

<details>
   <summary><b>(选项 2) TiDB Dedicated</b></summary>

   1. 复制 `.env.example` 文件到 `.env` 文件。
   2. 编辑 `.env` 文件，并替换 `<host>`, `<user>`, 和 `<password>` 的占位符为复制的连接参数。
   3. 将 `DATABASE_ENABLE_SSL` 修改为 `true` 以启用 TLS 连接。（公共端点需要）
   4. 将 `DATABASE_SSL_CA` 修改为 TiDB Cloud 提供的 CA 证书的文件路径。（公共端点需要）

   ```dotenv
   DATABASE_HOST=<host>
   DATABASE_PORT=4000
   DATABASE_USER=<user>
   DATABASE_PASSWORD=<password>
   DATABASE_NAME=test
   DATABASE_ENABLE_SSL=true
   DATABASE_SSL_CA=/path/to/ca.pem
   ```

</details>

<details>
   <summary><b>(选项 3) TiDB 自托管</b></summary>

   1. 复制 `.env.example` 文件到 `.env` 文件。
   2. 编辑 `.env` 文件，并替换 `<host>`, `<user>`, 和 `<password>` 的占位符为复制的连接参数。

   > 默认情况下，TiDB 自托管集群使用非加密连接在 TiDB 服务器和客户端之间，如果你的集群没有[启用 TLS 连接](https://docs.pingcap.com/tidb/stable/enable-tls-between-clients-and-servers#configure-tidb-server-to-use-secure-connections)则跳过下面的步骤。
   
   3. （可选）将 `DATABASE_ENABLE_SSL` 修改为 `true` 以启用 TLS 连接。
   4. （可选）将 `DATABASE_SSL_CA` 修改为定义 [`ssl-ca`](https://docs.pingcap.com/tidb/stable/tidb-configuration-file#ssl-ca) 选项的受信任 CA 证书的文件路径。

   ```dotenv
   DATABASE_HOST=<host>
   DATABASE_PORT=4000
   DATABASE_USER=<user>
   DATABASE_PASSWORD=<password>
   DATABASE_NAME=test
   # DATABASE_ENABLE_SSL=true
   # DATABASE_SSL_CA=/path/to/ca.pem
   ```

</details>

### 5. 运行示例代码

执行以下命令以运行示例代码：

```shell
ruby app.rb
```

如果连接成功，控制台将输出 TiDB 集群的版本。

**期望的执行输出：**

```
🔌 成功连接到 TiDB 集群！（TiDB 版本：5.7.25-TiDB-v7.1.0）
⏳ 正在加载示例游戏数据...
✅ 已加载示例游戏数据。

🆕 创建了一个新的玩家，ID 为 12。
ℹ️ 获取了玩家 12：Player { id: 12, coins: 100, goods: 100 }
🔢 给玩家 12 增加了 50 金币和 50 商品，更新了 1 行。
🚮 删除了 1 个玩家数据。
```

## 示例代码

### 连接至 TiDB 集群

以下代码采用环境变量（存储在 `.env` 文件中）作为连接选项，与 TiDB 集群建立数据库连接：

```ruby
require 'dotenv/load'
require 'mysql2'
Dotenv.load # 从 .env 文件加载环境变量

options = {
  host: ENV['DATABASE_HOST'] || '127.0.0.1',
  port: ENV['DATABASE_PORT'] || 4000,
  username: ENV['DATABASE_USER'] || 'root',
  password: ENV['DATABASE_PASSWORD'] || '',
  database: ENV['DATABASE_NAME'] || 'test'
}
options.merge(ssl_mode: :verify_identity) unless ENV['DATABASE_ENABLE_SSL'] == 'false'
options.merge(sslca: ENV['DATABASE_SSL_CA']) if ENV['DATABASE_SSL_CA']
client = Mysql2::Client.new(options)
```

<details open>
   <summary><b>对于 TiDB Serverless</b></summary>

要通过公共端点与 **TiDB Serverless** 连接，请将环境变量 `DATABASE_ENABLE_SSL` 设置为 `true` 以开启 TLS 连接。

默认情况下，mysql2 gem 将按一定的顺序搜索现有的 CA 证书，直到找到一个文件为止。

1. /etc/ssl/certs/ca-certificates.crt # Debian / Ubuntu / Gentoo / Arch / Slackware
2. /etc/pki/tls/certs/ca-bundle.crt # RedHat / Fedora / CentOS / Mageia / Vercel / Netlify
3. /etc/ssl/ca-bundle.pem # OpenSUSE
4. /etc/ssl/cert.pem # MacOS / Alpine (docker container)

虽然可以手动指定 CA 证书路径，但这种方式可能会导致在多环境部署场景中产生显著的不便，因为不同的机器和环境可能会将 CA 证书存储在不同的位置。因此，建议将 `sslca` 设置为 `nil`，以提高部署在不同环境中的灵活性和便利性。

</details>

<details>
   <summary><b>对于 TiDB Dedicated</b></summary>

要通过公共端点与 **TiDB Dedicated** 连接，请将环境变量 `DATABASE_ENABLE_SSL` 设置为 `true` 以开启 TLS 连接，并使用 `DATABASE_SSL_CA` 指定从[TiDB Cloud Web 控制台](#3-obtain-connection-parameters)下载的 CA 证书的文件路径。

</details>

### 插入数据

以下查询创建一个带有两个字段的单个玩家，并返回 last_insert_id：

```ruby
def create_player(client, coins, goods)
  result = client.query(
    "INSERT INTO players (coins, goods) VALUES (#{coins}, #{goods});"
  )
  client.last_id
end
```

更多信息请参考[插入数据](https://docs.pingcap.com/tidbcloud/dev-guide-insert-data)。

### 查询数据

以下查询通过 ID 返回单个 `Player` 记录：

```ruby
def get_player_by_id(client, id)
  result = client.query(
    "SELECT id, coins, goods FROM players WHERE id = #{id};"
  )
  result.first
end
```

有关更多信息，请参阅[查询数据](https://docs.pingcap.com/tidbcloud/dev-guide-get-data-from-single-table)。

### 更新数据

以下查询通过 ID 更新了单个 `Player` 记录：

```ruby
def update_player(client, player_id, inc_coins, inc_goods)
  result = client.query(
    "UPDATE players SET coins = coins + #{inc_coins}, goods = goods + #{inc_goods} WHERE id = #{player_id};"
  )
  client.affected_rows
end
```

有关更多信息，请参阅[更新数据](https://docs.pingcap.com/tidbcloud/dev-guide-update-data)。

### 删除数据

以下查询删除了一个 `Player` 记录：

```ruby
def delete_player_by_id(client, id)
  result = client.query(
    "DELETE FROM players WHERE id = #{id};"
  )
  client.affected_rows
end
```

有关更多信息，请参阅[删除数据](https://docs.pingcap.com/tidbcloud/dev-guide-delete-data)。

## 下一步

- [使用 Rails 和 ActiveRecord ORM 连接到 TiDB 集群](https://github.com/tidb-samples/tidb-ruby-rails-quickstart)
- 在 [TiDB Cloud Playground](https://play.tidbcloud.com/real-time-analytics)上探索实时分析功能。
- 阅读 [TiDB 开发指南](https://docs.pingcap.com/tidbcloud/dev-guide-overview)以获取有关使用 TiDB 进行应用开发的更多详细信息。
  - [HTAP 查询](https://docs.pingcap.com/tidbcloud/dev-guide-hybrid-oltp-and-olap-queries)
  - [事务](https://docs.pingcap.com/tidbcloud/dev-guide-transaction-overview)
  - [优化 SQL 性能](https://docs.pingcap.com/tidbcloud/dev-guide-optimize-sql-overview)

