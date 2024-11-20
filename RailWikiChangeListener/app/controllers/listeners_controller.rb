class ListenersController < ApplicationController
  $listener_running = false
  @@listener_thread = nil
  def start
    @@listener_thread = Thread.new { WikiChangeListener.listen }
    $listener_running = true 
    render json: { message: 'Listener started!' }, status: :ok
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end

  def stop
    if @@listener_thread.alive?
      @@listener_thread.kill
      $listener_running = false
      render json: { message: 'Listener stopped' }, status: :ok
    else
      render json: { status: 'No listener to stop' }
    end
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end
end
