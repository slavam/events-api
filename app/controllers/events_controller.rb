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
          participant = " WHERE e.id not in (select distinct(p.event_id) from participants p where p.user_id=#{@user.id}) AND "
          # participant = " join participants p on p.event_id = e.id and p.user_id != #{@user.id} WHERE "
        end
      else
        ""
      end
      if params[:filter][:is_author]
        if params[:filter][:is_author] == '1'
          author = " e.user_id = (#{@user.id}) AND "
        else
          author = " e.user_id != #{@user.id} AND "
        end
      else
        author = ""
      end
      if params[:filter][:tags]
        t = params[:filter][:tags].tr('[]','{}').tr(' ','')
        tags = params[:filter][:tags] ? "('#{t}' && e.tags) and " : ""
      else
        tags = ""
      end
      country = params[:filter][:country]? " e.country = '#{params[:filter][:country]}' AND ": ""
      city = params[:filter][:city]? " e.city = '#{params[:filter][:city]}' AND ": ""
      event_name = params[:filter][:name]? "e.name LIKE '%#{params[:filter][:name]}%' AND " : ""
      if (params[:filter][:date_from] and params[:filter][:date_to])
        start_date = " (e.date_start BETWEEN '#{params[:filter][:date_from]}' AND '#{params[:filter][:date_to]}') AND "
      elsif params[:filter][:date_from]
        start_date = " (e.date_start > '#{params[:filter][:date_from]}') AND "
      elsif params[:filter][:date_to]
        start_date = " (e.date_start < '#{params[:filter][:date_to]}') AND "
      else
        start_date = ""
      end
      finish = " 1=1 order by e.created_at desc "
      q = sql + (params[:filter][:is_participant]? participant : " WHERE ") + author + country + city + event_name + start_date + tags + finish
      events_all = Event.find_by_sql(q)
      # events = Event.paginate_by_sql(q, :page => page, :per_page => per_page)
     else
      events_all = Event.all
    end
    events_count = events_all.count
    events = events_all[(page-1)*per_page, per_page]
    es = []
    # events.paginate(page: page, per_page: per_page).each do|e| 
    events.each {|e| es <<  event_to_hash(e, @user, per_page)} if events # and events.count > 0
    render json: {events: es, count: events_count}
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
        if params[:event][:photos]
          ps = params[:event][:photos].tr('[]','').split(' ')
          ps.each do |p|
            extention = p.match(/\/(.+);/)[1]
            data = p.match(/,(.+)/)[1]
            photo = Photo.new(user_id: @user.id, event_id: @event.id)
            photo.image_data(extention, data)
            photo.save
          end
        end
        full_event = event_to_hash(@event, @user, 25)
        us = []
        us << user_to_hash(@user)
        full_event[:participants] = us
        render json: full_event
        # render json: @event, status: :created, location: @event
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
    @event.date_start = params[:event][:date_time_start] if params[:event] and params[:event][:date_time_start]
    @event.date_end = params[:event][:date_time_end] if params[:event] and params[:event][:date_time_end]
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
      if @event.photos.count > 0 
        ps = []
        # @event.photos.paginate(page: 1, per_page: per_page).each do|ph| 
        @event.photos.each do|ph| 
          ps << photo_as_hash(ph)
        end
        full_event[:photos] = ps
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
