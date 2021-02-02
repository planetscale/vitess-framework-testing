class Book < ApplicationRecord
	belongs_to :library
end

class Library < ApplicationRecord
	has_many :books
	validates_associated :books
	self.table_name = "library"
end

