class CommentsController < ApplicationController
  before_action :authenticate_user!

  def create
    @commentable = find_commentable
    @comment = @commentable.comments.build(comment_params.merge(user: current_user))
    respond_to do |format|
      if @comment.save
        format.json { render json: { commentable: @commentable.class.name.underscore, commentable_id: @commentable.id } }
        format.js
      else
        format.json { render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity }
        format.js
      end
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:body)
  end

  def find_commentable
    params.each do |name, value|
      return Regexp.last_match(1).classify.constantize.find(value) if name =~ /(.+)_id$/
    end
    nil
  end
end
