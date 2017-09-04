# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

email = "test@chat.com"
user = User.find_by_email(email)
unless user
  user = User.create(email: email, password: "12345678",
                firstname: Faker::Name.first_name,
                lastname: Faker::Name.last_name,
                confirmed_at: Time.now)
end

if user.comments.empty?
  10.times { user.comments.create(body: Faker::Lorem.sentence)}
end

