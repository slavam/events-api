class ApplicationController < ActionController::API
  def set_user
    if request.env['HTTP_USER_ID']
      user_id = request.env['HTTP_USER_ID']
    elsif params[:user_id]
      user_id = params[:user_id]
    else
      user_id = params[:id]? params[:id] : params[:user_id]
    end
    if user_id.nil?
      render json: {message: "Authentication problem"}, status: :unprocessable_entity
      return
    end
    @user = User.find(user_id)
    rescue ActiveRecord::RecordNotFound
      if @user.nil?
        render json: {message: "Пользователь не найден"}
        return
      end

    token = request.env['HTTP_API_TOKEN']? request.env['HTTP_API_TOKEN'] : params[:api_token]
    unless @user.check_token(token)
      render json: {message: "Authentication problem"}, status: :unprocessable_entity
    end
  end
  
  def user_to_hash(user)
    {id: user.id, created_at: user.created_at, first_name: user.first_name,
      last_name: user.last_name, picture: user.picture.url, phone: user.phone,
      email: user.email, website: user.website, fb_url: user.fb_url, vk_url: user.vk_url,
      ok_url: user.ok_url, city: user.city, country: user.country, rating: user.rating,
      count_created_events: Event.where(user_id: user.id).count, 
      count_participated_events: user.count_participated_events}
  end
end
