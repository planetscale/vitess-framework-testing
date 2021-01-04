namespace :user do
	desc "Create user"
	task :create do
		User.create!(
			name:                  Faker::Name.name,
			email:                 Faker::Internet.email,
			password:              "password",
			password_confirmation: "password",
			activated:             true,
			activated_at:          Time.zone.now
		)
	end
end

