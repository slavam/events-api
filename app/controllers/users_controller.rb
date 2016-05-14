class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy, :i_want_to_go, :index]
  before_action :set_event, only: [:i_want_to_go, :index]
  

  # GET /users
  def index
    page = params[:page]? params[:page].to_i : 1
    per_page= params[:per_page]? params[:per_page].to_i : 25
    us = []
    users = @event.users
    users.paginate(page: page, per_page: per_page).each do|u| 
      us << user_to_hash(u)
    end
    last_page = ((users.count - per_page * page) <= 0)
    render json: {participants: us, lastPage: last_page}
    # params[:coordinates]
  end

  # GET /users/1
  def show
    render json: @user
  end

  # POST /users
  def create
    @user = User.new(user_params)
    
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
      created_events = Event.where(user_id: @user.id)
      ces = []
      created_events.each do|e| 
        ces <<  event_to_hash(e, @user, 25)
      end
      participated_events = @user.events
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
      created_events = Event.where(user_id: @user.id)
      ces = []
      created_events.each do|e| 
        ces <<  event_to_hash(e, @user, 25)
      end
      participated_events = @user.events
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
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find(params[:event_id])
    end
    
    # def set_user
    #   @user = User.find(params[:id])
    #   token = request.env['HTTP_API_TOKEN']? request.env['HTTP_API_TOKEN'] : params[:api_token]
    #   unless @user.check_token(token)
    #     render json: {message: "Authentication problem"}, status: :unprocessable_entity
    #   end
    # end

    # Only allow a trusted parameter "white list" through.
    def user_params
      if params[:user]
        params.require(:user).permit(:first_name, :last_name, :email, 
        :phone, :website, :fb_url, :vk_url, :ok_url, :city, :country, :password)
      else
        params.permit(:first_name, :last_name, :email, 
        :phone, :website, :fb_url, :vk_url, :ok_url, :city, :country, :password)
      end
    end
end
