require 'acceptance/acceptance_helper'

feature 'User sign in', %q{
  In order to be able to write comment
  As an user
  I want to be able to sign in
} do

  given(:user) { create(:user)}

  scenario 'Registered user try to sign in' do
    sign_in(user)

    expect(page).to have_content 'Signed in successfully.'
    expect(current_path).to eq root_path
  end

  scenario 'Non-registered user try sign in' do
    visit new_user_session_path
    fill_in 'Email', with: 'wrong@yandex.ru'
    fill_in 'Password', with: '123456789'
    click_on 'Sign in'

    expect(page).to have_content 'Invalid Email or password.'
    expect(current_path).to eq new_user_session_path
  end

end