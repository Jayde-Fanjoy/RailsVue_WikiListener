require 'cassandra'

class ActivityController < ApplicationController
  @@cluster = Cassandra.cluster
  @@session = @@cluster.connect('wiki_changes')

  #before_action :authenticate_user!
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

    # Convert author_ids to a format compatible with ScyllaDB's IN clause
    # placeholders = author_ids.map { "?" }.join(", ")

    author_ids.each do |author|
      query = <<-CQL
        SELECT * 
        FROM recent_changes 
        WHERE author = ? 
        ORDER BY timestamp DESC 
        LIMIT 50
      CQL
  
    # Execute the query with the ScyllaDB session
      begin
        statement = @@session.prepare(query)
        result = @@session.execute(statement, arguments: [author])
        result.each do |row|
          events << {
            id: row["id"],
            server: row["server"],
            author: row["author"],
            title: row["title"],
            bot: row["bot"],
            timestamp: row["timestamp"].strftime("%Y-%m-%d %H:%M:%S %Z"),
          }
        end
      rescue StandardError => e
        logger.error "Error querying ScyllaDB: #{e.message}"
      end
    end
    
    events.sort_by! { |event| event[:timestamp] }
    render json: events
  end

  #Old way of doing it
  #def activity_feed
  #  author_ids = params[:author_ids] || []
  #  @events = Event.where(author_id: author_ids).order(created_at: :desc).limit(50) # Most recent events
  #  render json: @events
  #end
end
