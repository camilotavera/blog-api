require 'rails_helper'

RSpec.describe 'Posts', type: :request do
  describe 'GET /posts with data in the DB' do
    let!(:posts) { create_list(:post, 10, published: true) }

    it 'return all the pubilshed posts' do
      get '/posts'
      payload = JSON.parse(response.body)

      expect(payload.size).to eq(posts.size)
      expect(payload).not_to be_empty
      expect(response).to have_http_status(:ok)
    end
  end

  describe ' GET /posts Search by query' do
    let!(:another_post) { create(:published_post, title: 'another post') }
    let!(:hola_mundo) { create(:published_post, title: 'Hola mundo') }
    let!(:hola_rails) { create(:published_post, title: 'Hola rails') }
    let!(:hola_not_published) { create(:unpublished_post, title: 'Hola NO published') }

    it 'filter post by title' do
      get '/posts?search=Hola'
      payload = JSON.parse(response.body)
      expect(payload).not_to be_empty
      expect(payload.size).to eq(2)
      expect(payload.map { |p| p['id'] }.sort).to eq([hola_mundo.id, hola_rails.id].sort)
      expect(payload.map { |p| p['id'] }.sort).not_to include(hola_not_published.id)
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /posts/{id}' do
    let!(:post) { create(:post) }
    before { get "/posts/#{post.id}" }

    it 'return a post' do
      payload = JSON.parse(response.body)

      expect(payload).not_to be_empty
      expect(payload['id']).to eq(post.id)
      expect(payload['title']).to eq(post.title)
      expect(payload['content']).to eq(post.content)
      expect(payload['published']).to eq(post.published)
      expect(payload['author']['name']).to eq(post.user.name)
      expect(payload['author']['id']).to eq(post.user.id)
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /posts without data in the DB' do
    before { get '/posts' }

    it 'return OK' do
      payload = JSON.parse(response.body)

      expect(payload).to be_empty
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /posts/0' do
    before { get "/posts/#{0}" }

    it 'return 404 if post not exists' do
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /posts' do
    let!(:user) { create(:user) }

    it 'create a post' do
      req_payload = {
        post: {
          title: "I'm a new post",
          content: " I'm a content of a new post in my rails db",
          published: false,
          user_id: user.id
        }
      }
      post '/posts', params: req_payload

      res_payload = JSON.parse(response.body)
      expect(res_payload).not_to be_empty
      expect(res_payload['id']).not_to be_nil
      expect(response).to have_http_status(:created)
    end

    it 'return a error message on an invalid post' do
      req_payload = {
        post: {
          content: " I'm a content of a new post in my rails db",
          published: false,
          user_id: user.id
        }
      }
      post '/posts', params: req_payload

      res_payload = JSON.parse(response.body)
      expect(res_payload).not_to be_empty
      expect(res_payload['error']).not_to be_empty
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'Put /posts' do
    let!(:post) { create(:post) }

    it 'update a post' do
      req_payload = {
        post: {
          title: "I'm a Edited post",
          content: " I'm a Edited content of a new post in my rails db",
          published: true
        }
      }

      put "/posts/#{post.id}", params: req_payload
      res_payload = JSON.parse(response.body)

      expect(res_payload).not_to be_empty
      expect(res_payload['id']).to eq(post.id)
      expect(response).to have_http_status(:ok)
    end

    it 'return a error message on an invalid post' do
      req_payload = {
        post: {
          title: nil,
          content: nil,
          published: false
        }
      }
      put "/posts/#{post.id}", params: req_payload

      res_payload = JSON.parse(response.body)
      expect(res_payload).not_to be_empty
      expect(res_payload['error']).not_to be_empty
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
  
end
