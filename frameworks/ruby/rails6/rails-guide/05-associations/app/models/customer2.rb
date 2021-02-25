class Customer2 < ApplicationRecord
	has_many :orders, class_name: :Order2
	has_many :reviews
end

