class ApplicationController < ActionController::API
  # Use to handling errors
  rescue_from Exception, with: :render_internal_error
  rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  # rescue_from Can be using in the controller als a block
  # rescue_from ActiveRecord::RecordInvalid do |e|
  #   render json: { error: e.message }, status: :unprocessable_entity
  # end

  def render_not_found(exception, code = nil, msg = nil)
    render json: {
      status: :not_found,
      code: code,
      error: exception,
      message: msg
    }, status: :not_found
  end

  def render_unprocessable_entity(exception, code = nil, msg = nil)
    render json: {
      status: :unprocessable_entity,
      code: code,
      error: exception,
      message: msg
    }, status: :unprocessable_entity
  end

  def render_internal_error(exception, code = nil, msg = nil)
    log.error exception.message.to_s
    render json: {
      status: :internal_error,
      code: code,
      error: exception,
      message: msg
    }, status: :internal_error
  end
  
end
