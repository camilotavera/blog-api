require 'rails_helper'

RSpec.describe 'Posts with Authentication', type: :request do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let!(:user_post) { create(:post, user_id: user.id) }
  let!(:other_user_post) { create(:post, user_id: other_user.id, published: true) }
  let!(:other_user_post_draft) { create(:post, user_id: other_user.id, published: false) }
  let!(:auth_headers) { { 'Authorization' => "Bearer #{user.auth_token}" } }
  let!(:other_auth_headers) { { 'Authorization' => "Bearer #{other_user.auth_token}" } }
  let!(:create_params) { { 'post' => { 'title' => Faker::Lorem.sentence, 'content' => Faker::Lorem.paragraph, 'published' => true } } }
  let!(:update_params) { { 'post' => { 'title' => Faker::Lorem.sentence, 'content' => Faker::Lorem.paragraph, 'published' => true } } }

  describe 'GET /posts/{id}' do
    context 'With valid Auth' do
      context "when requesting others author's post" do
        context 'when post is public' do
          before { get "/posts/#{other_user_post.id}", headers: auth_headers }

          context 'Response Body' do
            subject { response_body }
            it { is_expected.to include(:id) }
          end
          context 'Response' do
            subject { response }
            it { is_expected.to have_http_status(:ok) }
          end
        end

        context 'when post is draft' do
          before { get "/posts/#{other_user_post_draft.id}", headers: auth_headers }

          context 'Response Body' do
            subject { response_body }
            it { is_expected.to include(:error) }
          end
          context 'Response' do
            subject { response }
            it { is_expected.to have_http_status(:not_found) }
          end
        end
      end

      context "when requesting user's post" do
      end
    end
  end

  describe 'POST /posts' do
    context 'With valid auth' do
      before { post '/posts', params: create_params, headers: auth_headers }

      context 'Response Body' do
        subject { response_body }
        it { is_expected.to include(:id, :title, :content, :published, :author) }
      end
      context 'Response' do
        subject { response }
        it { is_expected.to have_http_status(:created) }
      end
    end

    context 'with invalid auth' do
      before { post '/posts', params: create_params, headers: { 'Authorization' => 'Bearer xxxx' } }

      context 'Response Body' do
        subject { response_body }
        it { is_expected.to include(:error) }
      end
      context 'Response' do
        subject { response }
        it { is_expected.to have_http_status(:unauthorized) }
      end
    end

    context 'without auth headers' do
      before { post '/posts', params: create_params }

      context 'Response Body' do
        subject { response_body }
        it { is_expected.to include(:error) }
      end
      context 'Response' do
        subject { response }
        it { is_expected.to have_http_status(:unauthorized) }
      end
    end
  end

  describe 'PUT /posts/{id}' do
    context "when updating user's post" do
      before { put "/posts/#{user_post.id}", params: update_params, headers: auth_headers }

      context 'Response Body' do
        subject { response_body }
        it { is_expected.to include(:id, :title, :content, :published, :author) }
        it { expect(response_body[:id]).to eq(user_post.id) }
      end
      context 'Response' do
        subject { response }
        it { is_expected.to have_http_status(:ok) }
      end
    end

    context "when updating other user's post" do
      before { put "/posts/#{other_user_post.id}", params: update_params, headers: auth_headers }

      context 'Response Body' do
        subject { response_body }
        it { is_expected.to include(:error) }
      end
      context 'Response' do
        subject { response }
        it { is_expected.to have_http_status(:not_found) }
      end
    end

    context "when updating user's post without auth" do
      before { put "/posts/#{user_post.id}", params: update_params }

      context 'Response Body' do
        subject { response_body }
        it { is_expected.to include(:error) }
      end
      context 'Response' do
        subject { response }
        it { is_expected.to have_http_status(:unauthorized) }
      end
    end
  end

  private

  def response_body
    JSON.parse(response.body).with_indifferent_access
  end

end