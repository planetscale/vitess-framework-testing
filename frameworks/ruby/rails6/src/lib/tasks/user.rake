require 'terminal-table'

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

	task :list do
		users = User.all.collect { |user| [user.id, user.name, user.email, user.activated] }
		table = Terminal::Table.new :rows => users
		puts table
	end
end

