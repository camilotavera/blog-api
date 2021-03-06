class PostsController < ApplicationController
  include SecuredConcern
  before_action :authenticate_user!, only: %i[create update]

  # GET /posts
  def index
    @query = PostsQuery.new
    @posts = @query.published
    @posts = @query.published_search(params[:search]) if !params[:search].nil? && params[:search].present?
    render json: @posts.includes(:user), status: :ok
  end

  # GET /posts/{id}
  def show
    @post = Post.find(params[:id])
    if @post.published? || (Current.user && @post.user_id == Current.user.id)
      render json: @post, status: :ok
    else
      render json: { error: 'Not Found' }, status: :not_found
    end
  end

  # POST /posts
  def create
    @post = Current.user.posts.create!(create_params)
    render json: @post, status: :created
  end

  # PUT /posts/{id}
  def update
    @post = Current.user.posts.find(params[:id])
    @post.update!(update_params)
    render json: @post, status: :ok
  end


  private

  def create_params
    params.require(:post).permit(:title, :content, :published)
  end

  def update_params
    params.require(:post).permit(:title, :content, :published)
  end
end
