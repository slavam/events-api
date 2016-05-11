class PhotosController < ApplicationController
  before_action :set_event, only: [:create, :update]
  before_action :set_user, only: [:create, :update]
  before_action :set_photo, only: [:update]
  
  before_action :set_photo, only: [:show, :update, :destroy]

  # GET /photos
  def index
    @photos = Photo.all

    render json: @photos.paginate(page: params[:page], per_page: 5)
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
      if params[:like] == true
        @photo.like_photo(@user)
      else
        @photo.dislike_photo(@user)
      end
      render json: @photo
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
    @photo.destroy
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
