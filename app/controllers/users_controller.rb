class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy, :i_want_to_go, :index]
  before_action :set_event, only: [:i_want_to_go, :index]
  

  # GET /users
  def index
    page = params[:page]? params[:page].to_i : 1
    per_page= params[:per_page]? params[:per_page].to_i : 25
    
    users = @event.users
    
    if params[:coordinates]
      users_with_coord = @event.users.where('lat > 0 ')
      coords = params[:coordinates].tr('[] ','').split(',')
      
      users = users_with_coord.within(5, :units => :kms, :origin => coords)
      # from = Geokit::LatLng.new(coords[0], coords[1])
      # users.each do |u|
      #   if u.lat and u.lng
      #     to = Geokit::LatLng.new(u.lat, u.lng)
      #     u.distance = from.distance_to( to, :units=>:kms )
      #   end
      # end
      # users = users.select { |u| (!u.distance.nil?) and (0 < u.distance) and (u.distance < 5) } 
      # users.order(:distance)
      # users = @event.users.where("distance < 5 and distance > 0").order(:distance)
    end

    
    us = []
    
    users.paginate(page: page, per_page: per_page).each do|u| 
      us << user_to_hash(u)
    end
    # last_page = ((users.count - per_page * page) <= 0)
    render json: {participants: us, count: users.count}
  end

  # GET /users/1
  def show
    user = User.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: {message: "Не найден заданный пользователь"}, status: :unprocessable_entity
    else
    if user
      per_page= params[:per_page]? params[:per_page].to_i : 25
      render json: {user: fill_user(user, per_page)} #, api_token: @user.code_token}    
    end
  end

  def fill_user(user, per_page)
    full_user = user_to_hash(user)
    
    created_events = Event.where(user_id: user.id).order(:date_start).reverse_order
    ces = []
    created_events.each do|e| 
      ces <<  event_to_hash(e, user, per_page)
    end
    participated_events = user.events.order(:date_start).reverse_order
    pes = []
    participated_events.each do|e| 
      pes <<  event_to_hash(e, user, per_page)
    end
    full_user[:created_events] = ces
    full_user[:participated_events] = pes
    full_user
  end

  # POST /users
  def create
    if params[:social_network]
      if !params[:user_id]
        render json: {message: "Нет ID пользователя в социальной сети"}, status: :unprocessable_entity
        return
      end
      if params[:email]
        @user = User.find_by(email: params[:email])
        if @user #!!@user.authenticate(params[:password])
          @user.remember_token
          created_events = Event.where(user_id: @user.id).order(:date_start).reverse_order
          ces = []
          created_events.each do|e| 
            ces <<  event_to_hash(e, @user, 25)
          end
          participated_events = @user.events.order(:date_start).reverse_order
          pes = []
          participated_events.each do|e| 
            pes <<  event_to_hash(e, @user, 25)
          end
          full_user = user_to_hash(@user)
          full_user[:created_events] = ces
          full_user[:participated_events] = pes
          render json: {user: full_user, api_token: @user.code_token}
          return
        end
      end
      @user = User.where(uid: params[:user_id], provider: params[:social_network]).first
      if !@user
        @user = User.new(user_params)
        # @user.email = 'test@test.com'
        @user.password = '123'
        @user.uid = params[:user_id]
        @user.provider = params[:social_network]
        if params[:user_pic]
          extention = params[:user_pic].match(/\/(.+);/)[1]
          data = params[:user_pic].match(/,(.+)/)[1]
          @user.image_data(extention, data)        
        end
      end
    else
      if !params[:email] or !params[:password]
        render json: {message: "Нет обязательных параметров"}
        return
      end
      if User.find_by(email: params[:email])
        render json: {message: "Данный пользователь уже существует"}, status: :not_acceptable
        return
      else
        @user = User.new(user_params)
      end
    end
    
    if @user.save
      @user.remember_token
      u = user_to_hash(@user)
      render json: {user: u, api_token: @user.code_token}
      # render json: @user, status: :created, location: @user, serializer: UserWithTokenSerializer
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1
  def update
    if params[:user] and params[:user][:picture]
      extention = params[:user][:picture].match(/\/(.+);/)[1]
      data = params[:user][:picture].match(/,(.+)/)[1]
      @user.image_data(extention, data)
    end
    if @user.update(user_params)
      created_events = Event.where(user_id: @user.id).order(:date_start).reverse_order
      ces = []
      created_events.each do|e| 
        ces <<  event_to_hash(e, @user, 25)
      end
      participated_events = @user.events.order(:date_start).reverse_order
      pes = []
      participated_events.each do|e| 
        pes <<  event_to_hash(e, @user, 25)
      end
      full_user = user_to_hash(@user)
      full_user[:created_events] = ces
      full_user[:participated_events] = pes
      render json: full_user
      # render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def i_want_to_go
    @user.want_to_go(@event)
    render json: @user
  end
  
  def login
    @user = User.find_by(email: params[:email])
    if !!@user.authenticate(params[:password])
      @user.remember_token
      created_events = Event.where(user_id: @user.id).order(:date_start).reverse_order
      ces = []
      created_events.each do|e| 
        ces <<  event_to_hash(e, @user, 25)
      end
      participated_events = @user.events.order(:date_start).reverse_order
      pes = []
      participated_events.each do|e| 
        pes <<  event_to_hash(e, @user, 25)
      end
      full_user = user_to_hash(@user)
      full_user[:created_events] = ces
      full_user[:participated_events] = pes
      # render json: full_user
      render json: {user: full_user, api_token: @user.code_token}
      # render json: @user, status: :created, location: @user, serializer: UserWithTokenSerializer
    else
      render json: {message: "Неверный логин или пароль"}, status: :not_acceptable
      # render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy
  end

  def recovery
    if params[:email]
      @user = User.find_by(email: params[:email])
      if @user
        # ('a'..'z').to_a.shuffle[0..7].join
        new_pw = User.new_token[0, 5]
        @user.password_digest = User.digest(new_pw)
        if @user.save
          # send new_pw
          # @user.email = "mwm1955@gmail.com"
          UserMailer.password_reset(@user, new_pw).deliver_now
          render json: {message: "password was sent"}
          # render json: {message: new_pw}
        end
      else
        render json: {message: "Отсутствует пользователь с заданным почтовым адресом"}
      end
    else
      render json: {message: "Отсутствует почтовый адрес"}
    end
  end

  private
    # Only allow a trusted parameter "white list" through.
    def user_params
      if params[:user]
        params.require(:user).permit(:first_name, :last_name, :email, 
        :phone, :website, :fb_url, :vk_url, :ok_url, :city, :country, :password, :lat, :lng)
      elsif params[:social_network]
        params.permit(:first_name, :last_name, :email)
      else
        params.permit(:first_name, :last_name, :email, 
        :phone, :website, :fb_url, :vk_url, :ok_url, :city, :country, :password, :lat, :lng)
      end
    end
end
