# spec/home_spec.rb

require 'rails_helper'

RSpec.describe 'User is an admin', type: :system do
  before do
    @user = User.create(
      email: 'test@example.com',
      password: 'password123',
      password_confirmation: 'password123',
      role: :admin # Adjust depending on how roles are defined
    )
  end

  it 'visits the landing page' do
    # Sign in the user
    visit new_user_session_path
    fill_in 'Email', with: @user.email
    fill_in 'Password', with: 'password123'
    click_button 'Log in'

    # Test landing page
    visit root_path
    expect(page).to have_content('You have successfully authenticated.')
    expect(page).to have_content('Listener Control')
  end
end

RSpec.describe 'User is a user', type: :system do
  before do
    @user2 = User.create!(
      email: 'test2@example.com',
      password: 'password123',
      password_confirmation: 'password123',
      role: :user # Adjust depending on how roles are defined
    )
  end

  it 'visits the landing page' do
    # Sign in the user
    visit new_user_session_path
    fill_in 'Email', with: @user2.email
    fill_in 'Password', with: 'password123'
    click_button 'Log in'

    # Test landing page
    visit root_path
    expect(page).to have_content('You have successfully authenticated.')
    expect(page).to_not have_content('Listener Control')
  end
end
