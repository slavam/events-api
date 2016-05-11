class ApplicationController < ActionController::API
  def set_user
    if params[:user_id]
      user_id = params[:user_id]
    else
      user_id = params[:id]? params[:id] : params[:user_id]
    end
    @user = User.find(user_id)
    token = request.env['HTTP_API_TOKEN']? request.env['HTTP_API_TOKEN'] : params[:api_token]
    unless @user.check_token(token)
      render json: {message: "Authentication problem"}, status: :unprocessable_entity
    end
  end
end
