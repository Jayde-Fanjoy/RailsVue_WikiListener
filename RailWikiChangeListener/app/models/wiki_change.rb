require "cassandra"

class WikiChange
  scylla_host = ENV.fetch("SCYLLA_HOST", "127.0.0.1")
  scylla_port = ENV.fetch("SCYLLA_PORT", "9042")

  def initialize
    @@cluster = Cassandra.cluster(hosts: [ scylla_host ], port: scylla_port.to_i)
    @@session = @@cluster.connect # ('wiki_changes')
  end

  def self.checkIfExists
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
        id TEXT,
        server TEXT,
        author TEXT,
        bot BOOLEAN,
        title TEXT,
        timestamp TIMESTAMP,
        PRIMARY KEY (author, timestamp, id)
      )
    CQL
  end

  def self.recent_changes_by_authors(authors)
    authors_placeholder = authors.map { "?" }.join(",")
    statement = @@session.prepare(
      "SELECT * FROM recent_changes WHERE author IN (#{authors_placeholder}) ORDER BY timestamp DESC LIMIT 100"
    )
    @@session.execute(statement, arguments: authors)
  end

  def self.add_event(id:, server:, author:, title:, bot:, timestamp:)
    # Prepare the CQL query
    query = <<-CQL
      INSERT INTO wiki_changes.recent_changes (id, server, author, title, bot, timestamp)
      VALUES (?, ?, ?, ?, ?, ?)
    CQL

    begin
      # Use a prepared statement for better performance and security
      statement = @@session.prepare(query)
      @@session.execute(statement, arguments: [ id, server, author, title, bot, timestamp ])
      puts "Event added successfully!"
    rescue Cassandra::Errors::NoHostsAvailable => e
      puts "Failed to connect to ScyllaDB: #{e.message}"
    rescue StandardError => e
      puts "An error occurred: #{e.message}"
    end
  end
end
