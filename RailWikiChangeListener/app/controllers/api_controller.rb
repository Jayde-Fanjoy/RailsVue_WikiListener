class ApiController < ApplicationController
  before_action :admin_only, only: [:start, :stop] # Optional: Restrict to admins
  @@listener_thread = nil

  def start_listener
    if @@listener_thread&.alive?
      render json: { status: 'Listener already running' }
    else
      @@listener_thread = Thread.new { WikiChangeListener.listen }
      render json: { status: 'JLF29 Listener started' }
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

  def admin_only
    render json: { error: 'Not authorized' }, status: :unauthorized unless current_user.admin?
  end

end
