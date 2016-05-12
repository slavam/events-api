class PhotosController < ApplicationController
  before_action :set_event, only: [:create, :update, :index, :destroy]
  before_action :set_user, only: [:create, :update, :index, :destroy]
  before_action :set_photo, only: [:update]
  
  before_action :set_photo, only: [:show, :update, :destroy]

  # GET /photos
  def index
    per_page = params[:per_page]? params[:per_page].to_i : 25
    @photos = @event.photos
    ps = []
    @photos.paginate(page: params[:page], per_page: per_page).each do|ph| 
      ps << {id: ph.id, event_id: ph.event_id, is_liked: ph.liked?(@user), count_likes: ph.likings.count,
      picture: ph.picture.url}
    end
    
    last_page = ((@photos.count - per_page.to_i * params[:page].to_i) <= 0)
    render json: {photos: ps, lastPage: last_page}
    # render json: {photos: @photos.paginate(page: params[:page], per_page: per_page), lastPage: last_page}
    # render json: @photos.paginate(page: params[:page], per_page: per_page), serializer: ActiveModel::Serializer::ArraySerializer, each_serializer: Photo2Serializer
    # render json: @photos.paginate(page: params[:page], per_page: per_page)
    # render json: @photos.paginate(page: params[:page], per_page: per_page), serializer: ActiveModel::Serializer::ArraySerializer, each_serializer: Photo2Serializer
    # render :json => @photos  , serializer: Photo2Serializer
  end

  # GET /photos/1
  def show
    render json: @photo
  end

  # POST /photos
  def create
    extention = params[:picture].match(/\/(.+);/)[1]
    data = params[:picture].match(/,(.+)/)[1]
    @photo = Photo.new(user_id: params[:user_id],event_id: params[:event_id])
    @photo.image_data(extention, data)

    if @photo.save
      render json: @event.photos.paginate(page: 1) #, per_page: 10) #, status: :created, location: @photo
    else
      render json: @photo.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /photos/1
  def update
    if params[:like]
      if params[:like] == "true"
        @photo.like_photo(@user)
      else
        @photo.dislike_photo(@user)
      end
      render json: {} #@photo
    else
      if @photo.update(photo_params)
        render json: @photo
      else
        render json: @photo.errors, status: :unprocessable_entity
      end
    end
  end

  # DELETE /photos/1
  def destroy
    # render json: @user
    if @user.id == @event.author.id # AK Только владелец события 2016.05.11
      # @photo.remove_picture!
      # @photo.save!
      Photo.find(params[:id]).destroy
      # @photo.destroy
      render json: {message: "deleted"}
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find(params[:event_id])
    end
    
    def set_photo
      @photo = Photo.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def photo_params
      params.permit(:picture, :event_id, :user_id)
      # params.fetch(:photo, {})
    end
end
