require 'rails_helper'

RSpec.describe User, type: :model do
  it { should validate_presence_of :email}
  it { should validate_presence_of :password}
  it { should validate_presence_of :firstname}
  it { should have_many(:comments).dependent(:destroy)}
  it { should have_many(:authorizations).dependent(:destroy)}

  describe ".find_for_oauth" do
    let!(:user) { create(:user) }
    let(:auth) { OmniAuth::AuthHash.new(provider: "facebook", uid: "123456") }

    context "user already has authorization" do
      it "returns the user" do
        user.authorizations.create(provider: auth.provider, uid: auth.uid)
        expect(User.find_for_omniauth(auth)).to eq user
      end
    end

    context "user has not authorization" do
      context "user already exists" do
        let(:auth) { OmniAuth::AuthHash.new(provider: "facebook", uid: "123456",
                                            info: { email: user.email, first_name: Faker::Name.first_name })}

        it "does not create new user" do
          expect{ User.find_for_omniauth(auth) }.to_not change(User, :count)
        end

        it "creates new record for authorization" do
          expect{ User.find_for_omniauth(auth) }.to change(Authorization, :count).by(1)
        end

        it "creates authorization with provider and uid" do
          authorization = User.find_for_omniauth(auth).authorizations.first
          expect(authorization.provider).to eq auth.provider
          expect(authorization.uid).to eq auth.uid
        end

        it "returns the user" do
          expect(User.find_for_omniauth(auth)).to be_a(User)
        end
      end

      context "user does not exists" do
        let(:auth) { OmniAuth::AuthHash.new(provider: "facebook", uid: "123456",
                                            info: { email: "new@user.com", first_name: Faker::Name.first_name })}

        it "create new record user" do
          expect{ User.find_for_omniauth(auth) }.to change(User, :count).by(1)
        end

        it "returns new user" do
          expect(User.find_for_omniauth(auth)).to be_a(User)
        end

        it "fills user email" do
          user = User.find_for_omniauth(auth)
          expect(user.email).to eq auth.info.email
        end

        it "creates new record for authorization" do
          expect{ User.find_for_omniauth(auth) }.to change(Authorization, :count).by(1)
        end

        it "creates authorization with provider and uid" do
          authorization = User.find_for_omniauth(auth).authorizations.first
          expect(authorization.provider).to eq auth.provider
          expect(authorization.uid).to eq auth.uid
        end
      end

      context "user does not exists and social network does not return email" do
        let(:auth) { OmniAuth::AuthHash.new(provider: "twitter", uid: "123456",
                                            info: { email: "", first_name: Faker::Name.first_name })}

        it "create new record user" do
          expect{ User.find_for_omniauth(auth) }.to change(User, :count).by(1)
        end

        it "returns new user" do
          expect(User.find_for_omniauth(auth)).to be_a(User)
        end

        it "fills user email with temp email" do
          user = User.find_for_omniauth(auth)
          expect(user.email_verified?).to eq false
        end

        it "creates new record for authorization" do
          expect{ User.find_for_omniauth(auth) }.to change(Authorization, :count).by(1)
        end

        it "creates authorization with provider and uid" do
          authorization = User.find_for_omniauth(auth).authorizations.first
          expect(authorization.provider).to eq auth.provider
          expect(authorization.uid).to eq auth.uid
        end
      end
    end
  end

  describe "work with email" do
    let!(:user) { create(:user) }
    let(:auth) { OmniAuth::AuthHash.new(provider: "facebook", uid: "123456") }

    scenario "#create_temp_email" do
      user.create_temp_email(auth)
      expect(user.email).to match User::TEMP_EMAIL_REGEX
    end

    describe "#email_verified?" do
      scenario "with empty email" do
        user.email = ""
        expect(user.email_verified?).to eq false
      end

      scenario "with temp email" do
        user.create_temp_email(auth)
        expect(user.email_verified?).to eq false
      end

      scenario "with valid email" do
        user.update(email: "new@user.com")
        expect(user.email_verified?).to eq true
      end

      scenario "with non-confirmed email" do
        user.update(email: "new@user.com", confirmed_at: nil)
        expect(user.email_verified?).to eq false
      end
    end

    describe "#temp_email?" do
      scenario "with temp email" do
        user.email = User.create_temp_email(auth)
        expect(user.temp_email?).to eq true
      end

      scenario "with valid email" do
        expect(user.temp_email?).to eq false
      end

      scenario "with empty email" do
        expect(user.temp_email?).to eq false
      end
    end

    describe "#update_email" do
      scenario "without block" do
        user.update_email(email: "new@weqwee.com")
        expect(user.confirmed?).to eq false
        expect(user.email).to eq "new@weqwee.com"
      end

      scenario "with block" do
        expect(user.update_email(email: "new@weqwee.com"){1+1}).to eq 2
        expect(user.confirmed?).to eq false
        expect(user.email).to eq "new@weqwee.com"
      end
    end

    scenario "#create_authorization" do
      expect { user.create_authorization(auth) }.to change(Authorization, :count).by(1)
    end

    describe "#move_authorizations" do
      scenario "from existing user" do
        user2 = create(:user)
        user2.create_authorization(auth)
        expect(user.authorizations.count).to eq 0
        res = user.move_authorizations(user2) { 1+1 }
        expect(user.authorizations.count).to eq 1
        expect(res).to eq 2
      end

      describe "from nil user" do
        scenario "without block" do
          expect { user.move_authorizations(nil) }.to_not raise_error
        end

        scenario "with block" do
          expect( user.move_authorizations(nil) {1+1} ).to eq nil
        end
      end
    end

    describe "#update_params" do
      describe "email of existing user" do
        scenario "verify status" do
          user2 = create(:user)
          user2.email = User.create_temp_email(auth)
          user2.save
          user_status = user2.update_params(email: user.email)
          expect(user_status[:status]).to eq :existing
          expect(user_status[:user]).to eq user
        end

        scenario "remove user2" do
          user2 = create(:user)
          user2.create_temp_email(auth)
          user2.update_params(email: user.email)
          expect { user2.reload }.to raise_exception(ActiveRecord::RecordNotFound)
        end
      end
    end

    describe "email of new user" do
      scenario "verify status" do
        user2 = create(:user)
        user2.create_temp_email(auth)
        #user2.save
        user_status = user2.update_params(email: "new@weqwew.com")
        expect(user_status[:status]).to eq :new
        expect(user_status[:user]).to eq user2
        expect(user2.email).to eq "new@weqwew.com"
      end

      scenario "number of users unchanged" do
        user2 = create(:user)
        user2.email = User.create_temp_email(auth)
        user2.save
        expect { user2.update_params(email: "new@weqwew.com") }.to_not change(User, :count)
      end
    end
  end

  describe "#fullname" do
    scenario "with valid attributes" do
      expect(User.new(firstname: "ivan", lastname: "petrov").fullname).to eq "Ivan Petrov"
    end

    fscenario "with invalid attributes" do
      expect(User.new(firstname: "ivan", lastname: nil).fullname).to eq "Ivan"
      expect(User.new(firstname: "ivan", lastname: "").fullname).to eq "Ivan"
      expect(User.new(firstname: "", lastname: "petrov").fullname).to eq "Petrov"
      expect(User.new(firstname: nil, lastname: "petrov").fullname).to eq "Petrov"
      expect(User.new(firstname: nil, lastname: nil).fullname).to eq ""
    end
  end

end
