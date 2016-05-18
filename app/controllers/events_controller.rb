class EventsController < ApplicationController
  before_action :set_user, only: [:create, :update, :index]
  before_action :set_event, only: [:show, :update, :destroy]

  # GET /events
  def index
    page = params[:page]? params[:page].to_i : 1
    per_page= params[:per_page]? params[:per_page].to_i : 25
    if params[:filter]
      sql = "select e.* from events e "
      if params[:filter][:is_participant]
        if params[:filter][:is_participant] == '1'
          participant = " join participants p on p.event_id = e.id and p.user_id=#{@user.id} WHERE "
        else
          participant = " join participants p on p.event_id = e.id and p.user_id != #{@user.id} WHERE "
        end
      else
        ""
      end
      if params[:filter][:is_author]
        if params[:filter][:is_author] == '1'
          author = " e.user_id = #{@user.id} AND "
        else
          author = " e.user_id != #{@user.id} AND "
        end
      else
        author = ""
      end
      if params[:filter][:tags]
        t = params[:filter][:tags].tr('[]','{}').tr(' ','')
        tags = params[:filter][:tags] ? "('#{t}' && e.tags) and " : ""
      end
      country = params[:filter][:country]? " e.country = '#{params[:filter][:country]}' AND ": ""
      city = params[:filter][:city]? " e.city = '#{params[:filter][:city]}' AND ": ""
      event_name = params[:filter][:name]? "e.name LIKE '%#{params[:filter][:name]}%' AND " : ""
      start_date = (params[:filter][:date_from] and params[:filter][:date_to])? 
        " (e.date_start BETWEEN '#{params[:filter][:date_from]}' AND '#{params[:filter][:date_to]}') AND " : ""
      finish = " 1=1 " # order by e.created_at
      q = sql + (params[:filter][:is_participant]? participant : " WHERE ") + author + country + city + event_name + start_date + tags + finish
      # render json: {message: q}
      # events = Event.find_by_sql(q)
      events = Event.paginate_by_sql(q, :page => page, :per_page => per_page)
      
    else
      events = Event.all
    end
# filter[tags]: Array - массив со строками тэгов событий (необязательно)
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
        tags: params[:event][:tags] ? params[:event][:tags].tr('[]','{}'). tr(' ', '') : [],
        address: params[:location][:address], lat: params[:location][:lat], lng: params[:location][:lng])
  
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
      if params[:event][:is_participating] == '1'  # i am going
        @user.want_to_go(@event)
        @event.is_participating = true
      else  # i am not going
        @user.i_am_not_going(@event)
        @event.is_participating = false
      end
    end
    if params[:event] and params[:event][:tags]
      @event.tags = []
      ts = params[:event][:tags].tr('[] ','').split(',')
      ts.each {|t| @event.tags << t}
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
      cs = []
      comments = @event.comments
      # comments.paginate(page: page, per_page: per_page).each do|c| 
      comments.each do|c| 
        cs << comment_to_hash(c)
      end
    
      # full_event[:comments] = {comments: cs, lastPage: (comments.count <= per_page * page)}
      full_event[:comments] = cs
      
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

    # Only allow a trusted parameter "white list" through.
    def event_params
      # params.fetch(:event, {})
      params[:event]? params.require(:event).permit(:name, :description, :date_start, :date_end) : {} #, :country, :city, :address, :lat, :lng)
    end
    
    def location_params
      params[:location]? params.require(:location).permit(:country, :city, :address, :lat, :lng) : {}
    end
    
end
