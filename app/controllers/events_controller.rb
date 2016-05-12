class EventsController < ApplicationController
  before_action :set_user, only: [:create, :update]
  before_action :set_event, only: [:show, :update, :destroy]

  # GET /events
  def index
    @events = Event.all

    render json: @events
  end

  # GET /events/1
  def show
    render json: @event
  end

  # POST /events
  def create
    # @event = Event.new(event_params)
    @event = Event.new(name: params[:name], description: params[:description], 
      author: @user, date_start: params[:date_time_start], date_end: params[:date_time_end],
      country: params[:location][:country], city: params[:location][:city], 
      address: params[:location][:address], lat: params[:location][:lat], lng: params[:location][:lng],)
    

    if @event.save
      render json: @event, status: :created, location: @event
    else
      render json: @event.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /events/1
  def update
    if params[:event][:is_participating]
      @user.want_to_go(@event)
      @event.is_participating = true
    end
    if @event.update(event_params)
      render json: @event
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
    end

    # Only allow a trusted parameter "white list" through.
    def event_params
      # params.fetch(:event, {})
      params.permit(:name, :description, :date_start, :date_end, :country,
        :city, :address, :lat, :lng)
    end
end
