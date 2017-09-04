require 'acceptance/acceptance_helper'

feature 'Create comment', %q{
  In order to be able communion
  As an user
  I want to be able write comment
} do

  given(:user) { create(:user)}

  scenario 'Authenticate user write comment', js: true do
    sign_in(user)

    visit root_path
    click_on t('.new', :default => t("helpers.links.new"))

    within ".new-comment" do
      fill_in 'Body', with: 'Body 1'
      click_on t('.create', :default => t("helpers.links.create"))
    end

    within ".comments" do
      expect(page).to have_content 'Body 1'
    end
    expect(page).to have_content 'Your comment successfully added.'
  end

  scenario 'Authenticate user add invalid comment', js:true do
    sign_in(user)

    visit root_path
    click_on t('.new', :default => t("helpers.links.new"))

    fill_in 'Body', with: ''
    click_on t('.create', :default => t("helpers.links.create"))
    wait_for_ajax

    expect(page).to have_content 'Body can\'t be blank'
  end

  #
  # context "multiple sessions" do
  #   scenario "question appears on another user's page", js: true do
  #     Capybara.using_session('user') do
  #       sign_in user
  #       visit questions_path
  #     end
  #
  #     Capybara.using_session('user2') do
  #       sign_in create(:user)
  #       visit questions_path
  #     end
  #
  #     Capybara.using_session('guest') do
  #       visit questions_path
  #     end
  #
  #     Capybara.using_session('user') do
  #       click_on 'Ask question'
  #
  #       fill_in 'Title', with: 'Title 1'
  #       fill_in 'Body', with: 'Body 1'
  #       click_on 'Create'
  #
  #       expect(page).to have_content 'Title 1'
  #       expect(page).to have_content 'Body 1'
  #       expect(page).to have_content 'Your question successfully created.'
  #     end
  #
  #     Capybara.using_session('guest') do
  #       expect(page).to have_content 'Title 1'
  #     end
  #
  #     Capybara.using_session('user2') do
  #       expect(page).to have_content 'Title 1'
  #     end
  #   end
  # end
end