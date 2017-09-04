require 'rails_helper'

describe Ability do
  subject(:ability) { Ability.new(user)}

  describe "for guest" do
    let(:user) { nil }

    it { should be_able_to :read, :all }
    it { should_not be_able_to :manage, :all }
  end

  describe "for user" do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let(:comment) { create(:comment, user: user) }
    let(:other_comment) { create(:comment, user: other_user) }

    it { should_not be_able_to :manage, :all }
    it { should be_able_to :read, :all }

    it { should be_able_to :create, Comment }

    it { should be_able_to :update, comment }
    it { should_not be_able_to :update, other_comment }

    # it { should be_able_to [:update, :destroy, :edit], answer }
    # it { should_not be_able_to [:update, :destroy, :edit], other_answer }

    # it { should be_able_to [:update, :destroy], create(:comment, commentable: question,
    #                                        commentable_type: "Question", user: user) }
    # it { should_not be_able_to [:update, :destroy], create(:comment, commentable: question,
    #                                        commentable_type: "Question", user: other_user) }
    #
    # it { should be_able_to :accept, create(:answer, question: question) }
    # it { should_not be_able_to :accept, create(:answer, question: question, accept: true) }
    # it { should_not be_able_to :accept, create(:answer, question: other_question) }

  end
end