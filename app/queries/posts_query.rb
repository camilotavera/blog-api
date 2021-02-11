class PostsQuery
  def initialize(posts = Post.all)
    @posts = posts
  end

  def published
    @posts.where(published: true)
  end

  def published_search(query)
    posts_ids = Rails.cache.fetch("posts_search/#{query}", expires_in: 1.hours) do
      @posts.where("published = true AND title like '%#{query}%'").map(&:id)
    end

    @posts.where(id: posts_ids)
  end
end
