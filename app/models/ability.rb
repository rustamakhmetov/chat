class Ability
  include CanCan::Ability

  attr_reader :user

  def initialize(user)
    @user = user
    if user&.email_verified?
      user_abilities
    else
      guest_abilities
    end
  end

  def guest_abilities
    can :read, :all
  end

  def user_abilities
    guest_abilities
    can :create, Comment
    can :update, Comment, user: user
  end
end
