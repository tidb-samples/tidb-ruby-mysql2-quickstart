# Step 1. Require the 'mysql2' and 'dotenv' gem.
require 'mysql2'
require 'dotenv'

# Step 2. Load environment variables from .env file via the 'dotenv' gem.
Dotenv.load 

# Function to establish a connection to TiDB cluster with connection options.
def connect_with_options
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
end

# Function to get TiDB version.
def get_tidb_version(client)
  result = client.query('SELECT VERSION() AS tidb_version;')
  result.first['tidb_version']
end

# Function to load sample game data.
def load_sample_game_data(client)
  content = File.read('sql/game.init.sql')
  sqls = content.split(';')
  sqls.each do |sql|
    next if sql.strip == ''

    client.query(sql)
  end
end

# Function to CREATE a new player.
def create_player(client, coins, goods)
  result = client.query(
    "INSERT INTO players (coins, goods) VALUES (#{coins}, #{goods});"
  )
  client.last_id
end

# Function to READ player information by ID.
def get_player_by_id(client, id)
  result = client.query(
    "SELECT id, coins, goods FROM players WHERE id = #{id};"
  )
  result.first
end

# Function to UPDATE player.
def update_player(client, player_id, inc_coins, inc_goods)
  result = client.query(
    "UPDATE players SET coins = coins + #{inc_coins}, goods = goods + #{inc_goods} WHERE id = #{player_id};"
  )
  client.affected_rows
end

# Function to DELETE player by ID.
def delete_player_by_id(client, id)
  result = client.query(
    "DELETE FROM players WHERE id = #{id};"
  )
  client.affected_rows
end

# Main function
def main
  client = connect_with_options()
  begin
    version = get_tidb_version(client)
    puts("Connected to TiDB cluster! (TiDB version: #{version})")

    puts('Loading sample game data...')
    load_sample_game_data(client)
    puts('Loaded sample game data.')

    new_player = create_player(client, 100, 100)
    puts("Created a new player with ID #{new_player}.")

    player = get_player_by_id(client, new_player)
    puts("Got Player #{player['id']}: Player { id: #{player['id']}, coins: #{player['coins']}, goods: #{player['goods']} }")

    updated_rows = update_player(client, new_player, 50, 50)
    puts("Added 50 coins and 50 goods to player #{player['id']}, updated #{updated_rows} rows.")

    deleted_rows = delete_player_by_id(client, player['id'])
    puts("Deleted #{deleted_rows} player data.")
  ensure
    client.close
  end
end

# Run the main function
main