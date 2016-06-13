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
    
    # # rescue ActiveRecord::RecordNotFound
    # #   if @user.nil?
    # #     render json: {message: "Пользователь не найден"}
    # #     return
    # #   end

    token = request.env['HTTP_API_TOKEN']? request.env['HTTP_API_TOKEN'] : params[:api_token]
    unless @user.check_token(token)
      render json: {message: "Authentication problem"}, status: :unprocessable_entity
    end
  end
  
  def set_event
    if request.env['HTTP_EVENT_ID']
      event_id = request.env['HTTP_EVENT_ID']
    elsif params[:event_id]
      event_id = params[:event_id]
    else
      event_id = params[:id]
    end
    if event_id.nil?
      render json: {message: "Нет event_id"}, status: :unprocessable_entity
      return
    end
    @event = Event.find(event_id)
    rescue ActiveRecord::RecordNotFound
      render json: {message: "Событие не найдено"}
  end
  
  def user_to_hash(user)
    {id: user.id, created_at: user.created_at.strftime('%Y-%m-%d %H:%M'), first_name: user.first_name,
      last_name: user.last_name, picture: user.picture.url, phone: user.phone,
      email: user.email, website: user.website, fb_url: user.fb_url, vk_url: user.vk_url,
      ok_url: user.ok_url, city: user.city, country: user.country, 
      lat: user.lat, lng: user.lng, rating: user.rating,
      count_created_events: Event.where(user_id: user.id).count, 
      count_participated_events: user.count_participated_events,
      created_events: nil, participated_events: nil
    }
  end
  
  def event_to_hash(event, user, per_page)
    {id: event.id, name: event.name, description: event.description,
        date_start: event.date_start.strftime('%Y-%m-%d %H:%M'), date_end: event.date_end ? event.date_end.strftime('%Y-%m-%d %H:%M') : event.date_end, 
        is_participating: event.participant?(user),
        location: {country: event.country, city: event.city, address: event.address, lat: event.lat, lng: event.lng},
        created_at: event.created_at.strftime('%Y-%m-%d %H:%M'), 
        count_participants: event.count_participants, count_comments: event.comments.count, count_photos: event.photos.count,
        tags: event.tags.map{|t| t.force_encoding("UTF-8")}, author: user_to_hash(event.author), 
        main_photo: event.photos.count>0 ? photo_as_hash(event.photos.order(:id).first) : nil,
        photos: photos_as_array(event, per_page), participants: nil, comments: nil}
  end
  
  def photos_as_array(event,per_page)
    if params[:photos] == '1'
      ps = []
      event.photos.paginate(page: 1, per_page: per_page).each do|ph| 
        ps << photo_as_hash(ph)
      end
      ps
    else
      nil
    end
  end
    
  def photo_as_hash(ph)
    {id: ph.id, event_id: ph.event_id, is_liked: ph.liked?(@user), count_likes: ph.likings.count,
      picture: ph.picture.url, created_at: ph.created_at.strftime('%Y-%m-%d %H:%M')}
  end

  def comment_to_hash(comment)
    {id: comment.id, event_id: comment.event_id, author: user_to_hash(comment.author),
      recipient: comment.recipient_id ? user_to_hash(User.find(comment.recipient_id)) : nil
      # content: comment.content
      # created_at: comment.created_at.strftime('%Y-%m-%d %H:%M')
    }
  end

end
