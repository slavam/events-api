class CommentsController < ApplicationController
  before_action :set_user, only: [:create, :destroy]
  before_action :set_event, only: [:create, :index]
  before_action :set_comment, only: [:show, :update, :destroy]

  # GET /comments
  def index
    per_page = params[:per_page]? params[:per_page].to_i : 25
    page = params[:page]? params[:page].to_i : 1
    comments = @event.comments
    cs = []
    comments.paginate(page: page, per_page: per_page).each do|c| 
      cs << comment_to_hash(c)
    end
    
    # last_page = (comments.count <= per_page * page)
    render json: {comments: cs, count: comments.count}    
    # @comments = Comment.all
    # render json: @comments
  end

  # GET /comments/1
  def show
    render json: @comment
  end

  # POST /comments
  def create
    # @comment = Comment.new(comment_params)
    @comment = @user.comments.build(comment_params)
    @comment.event_id = @event.id
    if params[:comment] and params[:comment][:recipient]
      recipient_id = params[:comment][:recipient]
    elsif params[:recipient]
      recipient_id = params[:recipient]
    else
      recipient_id = nil
    end
        
    @comment.recipient_id = recipient_id

    if @comment.save
      render json: comment_to_hash(@comment)
      # render json: @comment, status: :created, location: @comment
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /comments/1
  def update
    if @comment.update(comment_params)
      render json: @comment
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  # DELETE /comments/1
  def destroy
    if @user.id == @comment.author.id # ВЛ Только автор 2016.05.17
      @comment.destroy
      render json: {message: "deleted"}
    else
      render json: {message: "Удалять может только автор комментария"}
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_comment
      @comment = Comment.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: {message: "Комментарий не найден"}
    end

    # Only allow a trusted parameter "white list" through.
    def comment_params
      # params.fetch(:comment, {})
      params.permit(:content, :recipient_id)
    end
    
end
