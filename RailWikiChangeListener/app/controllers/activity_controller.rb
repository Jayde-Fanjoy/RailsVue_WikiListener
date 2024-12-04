require "cassandra"

class ActivityController < ApplicationController
  before_action :authenticate_user!

  scylla_host = ENV.fetch("SCYLLA_HOST", "127.0.0.1")
  scylla_port = ENV.fetch("SCYLLA_PORT", "9042")

  def initialize
    @@cluster = Cassandra.cluster(hosts: [ scylla_host ], port: scylla_port.to_i)
    @@session = @@cluster.connect # ('wiki_changes')
    keyspace = "wiki_changes"
    table = "recent_changes"

    @@session.execute(<<-CQL)
      CREATE KEYSPACE IF NOT EXISTS #{keyspace}
        WITH replication = {
          'class': 'SimpleStrategy',
          'replication_factor': 1
        }
    CQL
    @@session.execute("USE #{keyspace}")

    @@session.execute(<<-CQL)
      CREATE TABLE IF NOT EXISTS #{table} (
        id UUID PRIMARY KEY,
        user TEXT,
        server_url TEXT,
        bot BOOLEAN,
        timestamp TIMESTAMP
      )
    CQL
  end

  def index
    @authors = Author.order("RANDOM()").limit(10) # 10 random authors
    @events = [] # Empty events initially
  end

  def activity_feed
    author_ids = params[:author_ids] || []
    logger.debug "Query Started"

    if author_ids.empty?
      render json: []
      logger.debug "No Authors"
      return
    end

    events = []

    author_ids.each do |author|
      query = <<-CQL
        SELECT *#{' '}
        FROM recent_changes#{' '}
        WHERE author = ?#{' '}
        ORDER BY timestamp DESC#{' '}
        LIMIT 50
      CQL

      # Execute the query with the ScyllaDB session
      begin
        statement = @@session.prepare(query)
        result = @@session.execute(statement, arguments: [ author ])
        result.each do |row|
          events << {
            id: row["id"],
            server: row["server"],
            author: row["author"],
            title: row["title"],
            bot: row["bot"],
            timestamp: row["timestamp"].strftime("%Y-%m-%d %H:%M:%S %Z")
          }
        end
      rescue StandardError => e
        logger.error "Error querying ScyllaDB: #{e.message}"
      end
    end

    events.sort_by! { |event| -event[:timestamp] }
    render json: events
  end

  def authenticate_user!
    redirect_to new_user_session_path, notice: "Please sign in to access this page" unless user_signed_in?
  end
end
