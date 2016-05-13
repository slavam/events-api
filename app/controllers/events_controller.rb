class EventsController < ApplicationController
  before_action :set_user, only: [:create, :update, :index]
  before_action :set_event, only: [:show, :update, :destroy]

  # GET /events
  def index
    page = params[:page]? params[:page].to_i : 1
    per_page= params[:per_page]? params[:per_page].to_i : 25
    if params[:filter]
      sql = "select e.* from events e "
      participant = params[:filter][:is_participant]? " join participants p on p.event_id = e.id and p.user_id=#{@user.id} WHERE ": ""
      author = params[:filter][:is_author]? " e.user_id = #{@user.id} AND " : ""
      country = params[:filter][:country]? " e.country = '#{params[:filter][:country]}' AND ": ""
      city = params[:filter][:city]? " e.city = '#{params[:filter][:city]}' AND ": ""
      # start = " (e.date_start BETWEEN '?' AND '?') AND "
      finish = " 1=1 "
      q = sql + (params[:filter][:is_participant]? participant : " WHERE ") + author + country + city + finish
      # render json: {message: q}
      # events = Event.find_by_sql(q)
      events = Event.paginate_by_sql(q, :page => page, :per_page => per_page)
      
    else
      events = Event.all
    end
# filter[date_from]: String (yyyy-mm-dd) - дата "С" выборки по периоду по датам начала событий (необязательно)
# filter[date_to]: String (yyyy-mm-dd) - дата "ПО" выборки по периоду по датам начала событий (необязательно)
# filter[tags]: Array - массив со строками тэгов событий (необязательно)
# filter[name]
    es = []
    # events.paginate(page: page, per_page: per_page).each do|e| 
    events.each do|e| 
      es <<  event_to_hash(e, @user, per_page)
    end
    last_page = ((events.count - per_page * page) <= 0)
    render json: {events: es, lastPage: last_page}
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
    
    # def photos_as_array(event,per_page)
    #   if params[:photos] == '1'
    #     ps = []
    #     event.photos.paginate(page: 1, per_page: per_page).each do|ph| 
    #       ps << {id: ph.id, event_id: ph.event_id, is_liked: ph.liked?(@user), count_likes: ph.likings.count,
    #       picture: ph.picture.url}
    #     end
    #     ps
    #   else
    #     nil
    #   end
    # end
end
