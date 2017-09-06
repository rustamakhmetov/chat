require 'acceptance/acceptance_helper'

feature 'Turbolinks', %q{
  In order to be able to change comment
  As an user
  I want to be able to edit an comment
} do
  given!(:user) { create(:user) }
  given!(:edit_caption) { t('.edit', :default => t("helpers.links.edit")) }
  given(:edit_tag) { "form#edit_comment_#{comment.id}" }
  given(:profile_caption) { t('.change_profile', :default => t("helpers.links.change_profile")) }
  given(:new_comment_caption) { t('.new', :default => t("helpers.links.new")) }
  given(:create_comment_caption) { t('.create', :default => t("helpers.links.create")) }

  before do
    sign_in(user)
  end

  scenario 'Change pages', js: true do
    visit root_path
    click_on profile_caption
    wait_for_ajax
    click_on 'Back'
    wait_for_ajax
    click_on new_comment_caption
    wait_for_ajax
    within ".new-comment" do
      fill_in 'Body', with: 'Body 1'
      click_on create_comment_caption
      wait_for_ajax
    end
    within ".comments" do
      expect(page).to have_content 'Body 1'
      expect(page).to_not have_content('Body 1', count: 2)
    end
    expect(page).to have_content('Your comment successfully added.', count: 1)
  end
end
