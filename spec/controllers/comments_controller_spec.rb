require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  let(:comment) { create(:comment) }

  describe 'GET #index' do
    sign_in_user

    subject { get :index }

    it 'populates an array of all comments' do
      comments = create_list(:comment, 2)
      subject
      expect(assigns(:comments)).to eq comments
    end

    it 'renders index view' do
      subject
      expect(response).to render_template :index
    end
  end
end
