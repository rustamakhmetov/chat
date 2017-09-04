require 'acceptance/acceptance_helper'

feature 'Dashboard', %q{
  In order to be able to manage comments
  As an user
  I want to be able to manage comments
} do

  given(:user) { create(:user)}

  scenario 'see buttons' do
    sign_in(user)

    expect(page).to have_content I18n.t("helpers.links.change_profile")
    expect(page).to have_content I18n.t("helpers.links.new")
    expect(page).to have_content I18n.t("helpers.links.logout")
  end

  # scenario 'Non-registered user try sign in' do
  #   visit new_user_session_path
  #   fill_in 'Email', with: 'wrong@yandex.ru'
  #   fill_in 'Password', with: '123456789'
  #   click_on 'Sign in'
  #
  #   expect(page).to have_content 'Invalid Email or password.'
  #   expect(current_path).to eq new_user_session_path
  # end

end