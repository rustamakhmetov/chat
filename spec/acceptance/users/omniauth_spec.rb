require 'acceptance/acceptance_helper'

feature 'Omniauth authorization', %q{
  In order to be able authorization from social network
  As an user
  I want to be able to sign in from social network
} do
  given!(:user) { create(:user) }

  describe "Authorization from Facebook" do
    scenario "Existing user try login from facebook with identical email" do
      visit new_user_session_path
      expect(page).to have_link "Sign in with Facebook"

      auth = omniauth_mock(:facebook, email: user.email)
      click_on "Sign in with Facebook"

      expect(page).to have_content "Successfully authenticated from Facebook account"
    end

    scenario "Existing user try login from social network with other email" do
      visit new_user_session_path
      expect(page).to have_link "Sign in with Facebook"

      auth = omniauth_mock(:facebook)
      expect(auth.info.email).to_not eq user.email
      click_on "Sign in with Facebook"

      expect(page).to have_content("You have to confirm your email address before continuing")
      open_email(auth.info.email)
      current_email.click_link 'Confirm my account'
      expect(page).to have_content 'Your email address has been successfully confirmed.'

      click_on "Sign in with Facebook"
      expect(page).to have_content "Successfully authenticated from Facebook account"
    end

    describe "User try login from Facebook with empty email" do
      scenario "denied to fill an empty email" do
        visit new_user_session_path
        expect(page).to have_link "Sign in with Facebook"

        auth = omniauth_mock(:facebook, email: "")
        click_on "Sign in with Facebook"

        expect(page).to have_content "Please confirm your email address"
        fill_in 'Email', with: ""
        click_on "Continue"

        expect(page).to have_content("Email can't be blank")
      end

      scenario "existing user" do
        visit new_user_session_path
        expect(page).to have_link "Sign in with Facebook"

        users_count = User.count

        auth = omniauth_mock(:facebook, email: "")
        expect(auth.info.email).to eq ""
        click_on "Sign in with Facebook"
        expect(users_count+1).to eq User.count

        expect(page).to have_content "Please confirm your email address"
        fill_in 'Email', with: user.email
        click_on "Continue"
        expect(users_count).to eq User.count

        expect(page).to_not have_content("You have to confirm your email address before continuing")
        expect(page).to have_content "Signed in successfully."
      end

      describe "new user" do
        scenario "full authenticate" do
          visit new_user_session_path
          expect(page).to have_link "Sign in with Facebook"

          users_count = User.count

          auth = omniauth_mock(:facebook, email: "")
          expect(auth.info.email).to eq ""
          click_on "Sign in with Facebook"
          expect(users_count+1).to eq User.count

          expect(page).to have_content "Please confirm your email address"
          email = "new@dfdsfdsfsd.com"
          fill_in 'Email', with: email
          click_on "Continue"
          expect(users_count+1).to eq User.count

          expect(page).to have_content("You have to confirm your email address before continuing")
          open_email(email)
          current_email.click_link 'Confirm my account'
          expect(page).to have_content 'Your email address has been successfully confirmed.'

          click_on "Sign in with Facebook"
          expect(page).to have_content "Successfully authenticated from Facebook account."
        end

        scenario "with temporary e-mail goes to the e-mail form" do
          auth = omniauth_mock(:facebook, email: "")
          temp_mail = User.create_temp_email(auth)
          user.update(email: temp_mail)
          users_count = User.count

          visit new_user_session_path
          click_on "Sign in with Facebook"
          expect(users_count).to eq User.count

          expect(page).to have_content "Please confirm your email address"
          email = "new@dfdsfdsfsd.com"
          fill_in 'Email', with: email
          click_on "Continue"

          expect(page).to have_content("You have to confirm your email address before continuing")
          open_email(email)
          current_email.click_link 'Confirm my account'
          expect(page).to have_content 'Your email address has been successfully confirmed.'

          click_on "Sign in with Facebook"
          expect(page).to have_content "Successfully authenticated from Facebook account."
        end

        scenario "login with an unapproved email is prohibited" do
          auth = omniauth_mock(:facebook, email: "")
          temp_mail = User.create_temp_email(auth)
          user.update(email: temp_mail)
          users_count = User.count

          visit new_user_session_path
          click_on "Sign in with Facebook"
          expect(users_count).to eq User.count

          expect(page).to have_content "Please confirm your email address"
          email = "new@dfdsfdsfsd.com"
          fill_in 'Email', with: email
          click_on "Continue"

          visit new_user_session_path
          click_on "Sign in with Facebook"

          expect(page).to have_content("You have to confirm your email address before continuing")
        end
      end
    end
  end
end