10.times do
  name = Faker::Name.name
  address = Faker::Lorem.sentence
  age = Faker::Internet.email
  password = "123456"
  password_confirmation = "123456"
  User.create(name: name, address: address, email: age, password: password, password_confirmation: password_confirmation)

end
users = User.take(2)

3.times do
  name = Faker::Lorem.sentence
  users.each do |user|
    user.test_suits.create(name: name)
  end
end

test_suit = TestSuit.take

3.times do
  user = users.first
  name = Faker::Lorem.sentence
  test_suit.test_cases.create(name: name, user_id: user.id)
end
