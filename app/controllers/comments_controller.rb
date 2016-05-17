class CommentsController < ApplicationController
  before_action :set_user, only: [:create]
  before_action :set_event, only: [:create]
  before_action :set_comment, only: [:show, :update, :destroy]

  # GET /comments
  def index
    @comments = Comment.all

    render json: @comments
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
    @comment.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_comment
      @comment = Comment.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def comment_params
      # params.fetch(:comment, {})
      params.permit(:content, :recipient_id)
    end
    
    def comment_to_hash(comment)
      {id: comment.id, event_id: comment.event_id, author: user_to_hash(comment.author), 
        recipient: comment.recipient_id ? user_to_hash(User.find(comment.recipient_id)) : nil, 
        content: comment.content, created_at: comment.created_at.strftime('%Y-%m-%d %H:%M'),
        
      }
    end
    
end
