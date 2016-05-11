class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy, :i_want_to_go]
  before_action :set_event, only: :i_want_to_go
  

  # GET /users
  def index
    @users = User.all
    # @feed_items = current_user.feed.paginate(page: params[:page])
    render json: @users
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
      render json: @user, status: :created, location: @user, serializer: UserWithTokenSerializer
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
      render json: @user
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
      render json: @user, status: :created, location: @user, serializer: UserWithTokenSerializer
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
      params[:user]? params.require(:user).permit(:first_name, :last_name, :email, 
        :phone, :website, :fb_url, :vk_url, :ok_url, :city, :country, :password) : {}
    end
end
