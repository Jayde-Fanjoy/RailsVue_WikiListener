class ApiController < ApplicationController
  @@listener_thread = nil

  def start_listener
    if @@listener_thread&.alive?
      render json: { status: 'Listener already running' }
    else
      @@listener_thread = Thread.new { WikiChangeListener.listen }
      render json: { status: 'Listener started' }
    end
  end

  def stop_listener
    if @@listener_thread&.alive?
      @@listener_thread.kill
      render json: { status: 'Listener stopped' }
    else
      render json: { status: 'No listener to stop' }
    end
  end
end
