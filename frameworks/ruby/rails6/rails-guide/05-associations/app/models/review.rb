class Review < ApplicationRecord
	belongs_to :customer, class_name: :Customer2
	belongs_to :book, class_name: :Book6

	enum state: [:not_reviewed, :published, :hidden]
end

