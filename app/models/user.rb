class User < ApplicationRecord
  TEMP_EMAIL_PREFIX = 'chat@me'
  TEMP_EMAIL_REGEX = /\Achat@me/

  has_many :comments, dependent: :destroy
  has_many :authorizations, dependent: :destroy

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable,
         :omniauthable, omniauth_providers: [:facebook]

  validates :firstname, presence: true

  def self.find_for_omniauth(auth)
    authorization = Authorization.where(provider: auth.provider, uid: auth.uid).first
    return authorization.user if authorization
    email = auth.info.email.nil? || auth.info.email.empty? ? create_temp_email(auth) : auth.info.email
    user = User.where(email: email).first
    unless user
      password = Devise.friendly_token[0,20]
      user = User.new(email: email, password: password, password_confirmation: password,
                      firstname: auth.info.first_name, lastname: auth.info.last_name)
      if user.temp_email?
        user.skip_confirmation!
      else
        user.send_reset_password_instructions
      end
      user.save
    end
    user.create_authorization(auth)
    user
  end

  def self.create_temp_email(auth)
    "#{TEMP_EMAIL_PREFIX}-#{auth.uid}-#{auth.provider}.com"
  end

  def create_temp_email(auth)
    self.update(email: User.create_temp_email(auth))
  end

  def email_verified?
    !(self.email.empty? || temp_email?) && confirmed?
  end

  def temp_email?
    self.email.match?(TEMP_EMAIL_REGEX)
  end

  def update_email(params)
    if update(params.merge(confirmed_at: nil))
      send_confirmation_instructions
      yield if block_given?
    end
  end

  def move_authorizations(user)
    if user
      user.authorizations.each do |authorization|
        self.authorizations.find_or_create_by(authorization.attributes.except("id", "created_at",
                                                                   "updated_at"))
      end
      user.destroy!
      yield if block_given?
    end
  end

  def create_authorization(auth)
    self.authorizations.find_or_create_by(provider: auth.provider, uid: auth.uid)
  end

  def update_params(params)
    email = params[:email]
    user = User.find_by_email(email)
    if user
      user.move_authorizations(self) do
        return {status: :existing, user: user }
      end
    else
      self.update_email(params) do
        return {status: :new, user: self }
      end
    end
  end

  def fullname
    "#{self.firstname.try(:camelize)} #{self.lastname.try(:camelize)}".strip
  end

end
