require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  let(:comment) { create(:comment) }

  describe 'POST #create' do
    sign_in_user

    context 'with valid attributes' do
      subject { post :create, params: { comment: attributes_for(:comment) }, format: :json }

      it 'saves the new comment to database' do
        expect { subject }.to change(@user.comments, :count).by(1)
      end

      it 'current user link to the new comment' do
        subject
        expect(assigns("comment").user).to eq @user
      end

      it 'render template create' do
        subject
        expect(response).to render_template "comments/create.json"
        comment = @user.comments.first
        expect(response.body).to be_json_eql(@user.id).at_path("user_id")
        expect(response.body).to be_json_eql(comment.id).at_path("id")
        expect(response.body).to be_json_eql(comment.body.to_json).at_path("body")
      end
    end

    context 'with invalid attributes' do
      it 'does not save the answer' do
        expect { post :create, params: { comment: attributes_for(:invalid_comment),
                                         format: :json }}.to_not change(Comment, :count)
      end

      it 'render template create' do
        post :create, params: { comment: attributes_for(:invalid_comment), format: :json }
        expect(response).to have_http_status(422)
      end
    end
  end

end
