class Author < ApplicationRecord
	has_many :book2s, dependent: :destroy
	self.table_name = "author"
end

