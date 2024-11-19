require 'cassandra'

class WikiChange
  @@cluster = Cassandra.cluster
  @@session = @@cluster.connect('wiki_changes')

  def self.recent_changes_by_authors(authors)
    authors_placeholder = authors.map { '?' }.join(',')
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
      @@session.execute(statement, arguments: [id, server, author, title, bot, timestamp])
      puts "Event added successfully!"
    rescue Cassandra::Errors::NoHostsAvailable => e
      puts "Failed to connect to ScyllaDB: #{e.message}"
    rescue StandardError => e
      puts "An error occurred: #{e.message}"
    end
  end

end