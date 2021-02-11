class PostsQuery
  def initialize(posts = Post.all)
    @posts = posts
  end

  def published
    @posts.where(published: true)
  end

  def published_search(query)
    @posts.where("published = true AND title like '%#{query}%'")
  end
end
