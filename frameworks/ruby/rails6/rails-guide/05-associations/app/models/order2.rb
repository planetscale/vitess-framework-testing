class Order2 < ApplicationRecord
	belongs_to :customer, class_name: :Customer2
	has_and_belongs_to_many :books, class_name: :Book6, join_table: :book6s_order2s

	enum status: [:shipped, :being_packed, :complete, :cancelled]

	scope :created_before, ->(time) { where('created_at < ?', time) }
end

