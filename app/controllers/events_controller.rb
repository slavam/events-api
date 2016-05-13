class EventsController < ApplicationController
  before_action :set_user, only: [:create, :update, :index]
  before_action :set_event, only: [:show, :update, :destroy]

  # GET /events
  def index
    page = params[:page]? params[:page].to_i : 1
    per_page= params[:per_page]? params[:per_page].to_i : 25
    if params[:filter] and params[:filter][:is_participant]
      events = @user.events
    else
      events = Event.all
    end
    es = []
    events.paginate(page: page, per_page: per_page).each do|e| 
      es <<  event_to_hash(e, @user, per_page)
      # {id: e.id, name: e.name, description: e.description,
      #   date_start: e.date_start, date_end: e.date_end, is_participating: e.participant?(@user),
      #   location: {country: e.country, city: e.city, address: e.address, lat: e.lat, lng: e.lng},
      #   created_at: e.created_at, count_participants: e.count_participants, count_comments: e.comments.count,
      #   tags: nil, author: user_to_hash(e.author), photos: photos_as_array(e, per_page)}
    end
    last_page = ((events.count - per_page * page) <= 0)
    render json: {events: es, lastPage: last_page}
    # render json: {message: page}
    # @events = Event.all
    # render json: @events
  end

  # GET /events/1
  def show
    render json: @event
  end

  # POST /events
  def create
    if (params[:event] and params[:location] and params[:event][:name] and params[:event][:description] \
      and params[:event][:date_time_start] and params[:event][:date_time_end] \
      and params[:location][:country] and params[:location][:city] \
      and params[:location][:address] and params[:location][:lat] and params[:location][:lng])
      @event = Event.new(name: params[:event][:name], description: params[:event][:description], 
        author: @user, date_start: params[:event][:date_time_start], date_end: params[:event][:date_time_end],
        country: params[:location][:country], city: params[:location][:city], 
        address: params[:location][:address], lat: params[:location][:lat], lng: params[:location][:lng],)
  
      if @event.save
        @user.want_to_go(@event)
        @event.is_participating = true
        render json: @event, status: :created, location: @event
      else
        render json: @event.errors, status: :unprocessable_entity
      end
    else
      render json: {message: "Отсутствует обязательное поле"}
    end
  end

  # PATCH/PUT /events/1
  def update
    if params[:event] and params[:event][:is_participating]
      @user.want_to_go(@event)
      @event.is_participating = true
    end
    if @event.update(event_params) and @event.update(location_params)
      @event.is_participating = @event.participant?(@user)
      # render json: @event
      us = []
      users = @event.users
      users.each do|u| 
        us << user_to_hash(u)
      end
      full_event = event_to_hash(@event, @user, 25)
      full_event[:participants] = us
      render json: full_event
    else
      render json: @event.errors, status: :unprocessable_entity
    end
  end

  # DELETE /events/1
  def destroy
    @event.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: {message: "Событие не найдено"}
    end

    # Only allow a trusted parameter "white list" through.
    def event_params
      # params.fetch(:event, {})
      params[:event]? params.require(:event).permit(:name, :description, :date_start, :date_end) : {} #, :country, :city, :address, :lat, :lng)
    end
    
    def location_params
      params[:location]? params.require(:location).permit(:country, :city, :address, :lat, :lng) : {}
    end
    
    def photos_as_array(event,per_page)
      if params[:photos] == '1'
        ps = []
        event.photos.paginate(page: 1, per_page: per_page).each do|ph| 
          ps << {id: ph.id, event_id: ph.event_id, is_liked: ph.liked?(@user), count_likes: ph.likings.count,
          picture: ph.picture.url}
        end
        ps
      else
        nil
      end
    end
end
