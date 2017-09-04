require 'acceptance/acceptance_helper'

feature 'Edit comment', %q{
  In order to be able to change comment
  As an user
  I want to be able to edit an comment
} do
  given!(:user) { create(:user) }
  given!(:edit_caption) { t('.edit', :default => t("helpers.links.edit")) }

  describe 'Author' do
    given!(:comment) { create(:comment, user: user) }

    before do
      sign_in user
      visit root_path
    end

    scenario 'see edit link' do
      within '.comments' do
        expect(page).to have_link(edit_caption)
      end
    end

    scenario 'edit comment', js: true do
      edit_caption = t('.edit', :default => t("helpers.links.edit"))
      edit_tag = "form#edit_comment_#{comment.id}"
      expect(page).to_not have_selector(edit_tag)
      click_on edit_caption
      expect(page).to_not have_link(edit_caption)
      expect(page).to have_selector(edit_tag)
      fill_in 'Body', with: 'new comment'
      click_on 'Save'
      expect(page).to_not have_selector(edit_tag)
      expect(page).to have_link(edit_caption)
      expect(page).to_not have_content(comment.body)
      expect(page).to have_content('new comment')
    end
  end

  describe 'Non author' do
    given!(:comment) { create(:comment, user: create(:user) ) }

    before do
      sign_in user
      visit root_path
    end

    scenario "don't see edit link" do
      within '.comments' do
        expect(page).to_not have_link(edit_caption)
      end
    end

    scenario "don't see update form" do
      edit_tag = "form#edit_comment_#{comment.id}"
      expect(page).to_not have_selector(edit_tag)
    end
  end

end