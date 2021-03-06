require 'acceptance/acceptance_helper'

feature 'Edit comment', %q{
  In order to be able to change comment
  As an user
  I want to be able to edit an comment
} do
  given!(:user) { create(:user) }
  given!(:edit_caption) { t('.edit', :default => t("helpers.links.edit")) }
  given(:edit_tag) { "form#edit_comment_#{comment.id}" }


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
      expect(page).to have_content('new comment', count: 1)
    end

    scenario 'cancels edit comment', js: true do
      expect(page).to have_css("tr#show#{comment.id}")
      expect(page).to_not have_selector(edit_tag)
      click_on edit_caption
      expect(page).to have_selector(edit_tag)
      click_on 'Cancel'
      expect(page).to_not have_selector(edit_tag)
      expect(page).to have_css("tr#show#{comment.id}")
    end

    scenario 'edit comment after his create', js: true do
      # create
      click_on t('.new', :default => t("helpers.links.new"))
      within ".new-comment" do
        fill_in 'Body', with: 'Body 1'
        click_on t('.create', :default => t("helpers.links.create"))
      end
      within ".comments" do
        expect(page).to have_content('Body 1', count: 1)
      end

      # edit
      within "tbody tr:last-child" do
        click_on edit_caption
        wait_for_ajax
      end
      comment2 = Comment.where.not(id: comment.id).first
      edit_tag = "form#edit_comment_#{comment2.id}"
      expect(page).to have_selector(edit_tag)

      #save
      click_on 'Save'
      wait_for_ajax
      expect(page).to_not have_selector(edit_tag)
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

  context "multiple sessions" do
    given!(:comment) { create(:comment, user: user) }

    scenario "an updated comment appears on another user's page", js: true do
      Capybara.using_session('user') do
        sign_in user
        visit root_path
      end

      Capybara.using_session('user2') do
        sign_in create(:user)
        visit root_path
      end

      Capybara.using_session('user') do
        click_on edit_caption
        fill_in 'Body', with: 'Body 1'
        click_on 'Save'
        wait_for_ajax

        within ".comments" do
          expect(page).to have_content('Body 1', count: 1)
        end
        expect(page).to have_content('Your comment successfully updated.', count: 1)
      end

      Capybara.using_session('user2') do
        within ".comments" do
          expect(page).to have_content 'Body 1'
          expect(page).to_not have_link t('.edit', :default => t("helpers.links.edit"))
        end
      end
    end
  end

end