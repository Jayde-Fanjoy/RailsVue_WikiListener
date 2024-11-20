require 'http'
require 'uuidtools'

class WikiChangeListener
  STREAM_URL = 'https://stream.wikimedia.org/v2/stream/recentchange'

  def self.listen
    HTTP.get(STREAM_URL).body.each do |line|
      next if line.strip.empty?
      # Only grab the data
      if line.index("data: ") == 0
        proc_line = line[6..-1]
        event = JSON.parse(proc_line)
        handle_event(event)
      end
    rescue JSON::ParserError
      # Ignore malformed lines
    end
  end

  def self.handle_event(event)
    print(event['user'] + " made a change in " + event['title'] + " on " + event['server_name'] + ". (" + Time.at(event['timestamp']).strftime("%Y-%m-%d %H:%M:%S %Z") + ")" )

    # Store data in ScyllaDB
    WikiChange.add_event(
      id: UUIDTools::UUID.timestamp_create.to_s,
      server: event['server_name'],
      author: event['user'],
      title: event['title'],
      bot: event['bot'],
      timestamp: Time.at(event['timestamp'])
    )

    # Track unique servers and authors in PostgreSQL
    Server.find_or_create_by(name: event['server_name'])
    Author.find_or_create_by(name: event['user'])
  end
end