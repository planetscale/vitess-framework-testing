class Order2 < ApplicationRecord
	belongs_to :customer, class_name: :Customer2, foreign_key: :customer2_id, counter_cache: :orders_count, inverse_of: :orders
	has_and_belongs_to_many :books, class_name: :Book6, join_table: :book6s_order2s

	enum status: [:shipped, :being_packed, :complete, :cancelled]

	scope :created_before, ->(time) { where('created_at < ?', time) }
end

