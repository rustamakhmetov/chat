require 'acceptance/acceptance_helper'

feature 'User sign up', %q{
  In order to be able to write comment
  As an user
  I want to be able to sign up
} do

  given(:user) { create(:user) }

  scenario 'Registered user try to sign up' do
    sign_in(user)
    expect(page).to have_content 'Signed in successfully.'
    expect(current_path).to eq root_path

    visit new_user_registration_path
    expect(page).to have_content 'You are already signed in.'
  end

  scenario 'Non-registered user try to sign up' do
    new_user = OpenStruct.new(attributes_for(:user))

    visit new_user_registration_path

    fill_in 'Firstname', with: new_user.firstname
    fill_in 'Email', with: new_user.email
    fill_in 'Password', with: new_user.password
    fill_in 'Password confirmation', with: new_user.password
    click_on 'Sign up'

    expect(page).to have_content "A message with a confirmation link has been sent to your email address"

    open_email(new_user.email)
    current_email.click_link 'Confirm my account'
    expect(page).to have_content 'Your email address has been successfully confirmed.'

    fill_in 'Email', with: new_user.email
    fill_in 'Password', with: new_user.password
    click_on 'Sign in'

    expect(page).to have_content 'Signed in successfully.'
  end

  scenario 'Non-registered user try to sign up with invalid data' do
    visit new_user_registration_path
    fill_in 'Password', with: '12345678'
    fill_in 'Password confirmation', with: '12345678'
    click_on 'Sign up'
    expect(page).to have_content "Email can't be blank"
    expect(page).to have_content "Firstname can't be blank"
  end
end