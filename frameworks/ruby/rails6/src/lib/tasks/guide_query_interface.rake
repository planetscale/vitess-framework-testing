namespace :guide_query_interface do
	task :seed do
		for i in 1..10
			Customer2.create!(first_name: i.humanize.humanize)
		end

		for i in 1..10
			Supplier5.create!(state: "ST#{i}")
		end

		for i in 1..10
			Author5.create!(name: "Novelist #{i}")
		end

		for i in 1..10
			for j in 1..10
				for k in 1..3
					Book6.create!(
						supplier: Supplier5.find(i),
						author: Author5.find(j),
						title: "Book #{i}-#{j}-#{k}",
						price: (i * 100) + (j * 10) + k,
						year_published: 2000 + i + j + k,
						out_of_print: (k % 2 == 0)
					)
				end
			end
		end

		c = Customer2.find(1)
		c.orders.create!(books: Book6.where(id: [1]), status: :complete)
		c = Customer2.find(2)
		c.orders.create!(books: Book6.where(id: [1]), status: :complete)
		c.orders.create!(books: Book6.where(id: [1, 2]), status: :complete)
		c = Customer2.find(3)
		c.orders.create!(books: Book6.where(id: [1]), status: :complete)
		c.orders.create!(books: Book6.where(id: [1, 2]), status: :complete)
		c.orders.create!(books: Book6.where(id: [1, 2, 3]), status: :complete)
		c = Customer2.find(4)
		c.orders.create!(books: Book6.where(id: [1]), status: :complete)
		c.orders.create!(books: Book6.where(id: [1, 2]), status: :complete)
		c.orders.create!(books: Book6.where(id: [1, 2, 3]), status: :complete)
		c.orders.create!(books: Book6.where(id: [1, 2, 3, 5]), status: :complete)
		c = Customer2.find(5)
		c.orders.create!(books: Book6.where(id: [1]), status: :complete)
		c.orders.create!(books: Book6.where(id: [1, 2]), status: :complete)
		c.orders.create!(books: Book6.where(id: [1, 2, 3]), status: :complete)
		c.orders.create!(books: Book6.where(id: [1, 2, 3, 5]), status: :complete)
		c.orders.create!(books: Book6.where(id: [1, 2, 3, 5, 7]), status: :complete)
		c = Customer2.find(6)
		c.orders.create!(books: Book6.where(id: [1]), status: :complete)
		c.orders.create!(books: Book6.where(id: [1, 2]), status: :complete)
		c.orders.create!(books: Book6.where(id: [1, 2, 3]), status: :complete)
		c.orders.create!(books: Book6.where(id: [1, 2, 3, 5]), status: :complete)
		c.orders.create!(books: Book6.where(id: [1, 2, 3, 5, 7]), status: :complete)
		c.orders.create!(books: Book6.where(id: [1, 2, 3, 5, 7, 11]), status: :complete)
		c = Customer2.find(7)
		c.orders.create!(books: Book6.where(id: [1]), status: :complete)
		c.orders.create!(books: Book6.where(id: [1, 2]), status: :complete)
		c.orders.create!(books: Book6.where(id: [1, 2, 3]), status: :complete)
		c.orders.create!(books: Book6.where(id: [1, 2, 3, 5]), status: :complete)
		c.orders.create!(books: Book6.where(id: [1, 2, 3, 5, 7]), status: :complete)
		c.orders.create!(books: Book6.where(id: [1, 2, 3, 5, 7, 11]), status: :complete)
		c.orders.create!(books: Book6.where(id: [1, 2, 3, 5, 7, 11, 13]), status: :complete)
		c = Customer2.find(8)
		c.orders.create!(books: Book6.where(id: [1]), status: :complete)
		c.orders.create!(books: Book6.where(id: [1, 2]), status: :complete)
		c.orders.create!(books: Book6.where(id: [1, 2, 3]), status: :complete)
		c.orders.create!(books: Book6.where(id: [1, 2, 3, 5]), status: :complete)
		c.orders.create!(books: Book6.where(id: [1, 2, 3, 5, 7]), status: :complete)
		c.orders.create!(books: Book6.where(id: [1, 2, 3, 5, 7, 11]), status: :complete)
		c.orders.create!(books: Book6.where(id: [1, 2, 3, 5, 7, 11, 13]), status: :complete)
		c.orders.create!(books: Book6.where(id: [1, 2, 3, 5, 7, 11, 13, 17]), status: :complete)
		c = Customer2.find(9)
		c.orders.create!(books: Book6.where(id: [1]), status: :complete)
		c.orders.create!(books: Book6.where(id: [1, 2]), status: :complete)
		c.orders.create!(books: Book6.where(id: [1, 2, 3]), status: :complete)
		c.orders.create!(books: Book6.where(id: [1, 2, 3, 5]), status: :complete)
		c.orders.create!(books: Book6.where(id: [1, 2, 3, 5, 7]), status: :complete)
		c.orders.create!(books: Book6.where(id: [1, 2, 3, 5, 7, 11]), status: :complete)
		c.orders.create!(books: Book6.where(id: [1, 2, 3, 5, 7, 11, 13]), status: :complete)
		c.orders.create!(books: Book6.where(id: [1, 2, 3, 5, 7, 11, 13, 17]), status: :complete)
		c.orders.create!(books: Book6.where(id: [1, 2, 3, 5, 7, 11, 13, 17, 19]), status: :complete)
		c = Customer2.find(10)
		c.orders.create!(books: Book6.where(id: [1]), status: :complete)
		c.orders.create!(books: Book6.where(id: [1, 2]), status: :complete)
		c.orders.create!(books: Book6.where(id: [1, 2, 3]), status: :complete)
		c.orders.create!(books: Book6.where(id: [1, 2, 3, 5]), status: :complete)
		c.orders.create!(books: Book6.where(id: [1, 2, 3, 5, 7]), status: :complete)
		c.orders.create!(books: Book6.where(id: [1, 2, 3, 5, 7, 11]), status: :complete)
		c.orders.create!(books: Book6.where(id: [1, 2, 3, 5, 7, 11, 13]), status: :complete)
		c.orders.create!(books: Book6.where(id: [1, 2, 3, 5, 7, 11, 13, 17]), status: :complete)
		c.orders.create!(books: Book6.where(id: [1, 2, 3, 5, 7, 11, 13, 17, 19]), status: :complete)
		c.orders.create!(books: Book6.where(id: [1, 2, 3, 5, 7, 11, 13, 17, 19, 23]), status: :complete)
	end

	task :step_2_1 do
		# 2.1.1 find
		raise "customer wrong 1" unless Customer2.find(10).first_name == 'Ten'
		c = Customer2.find([1, 10])
		raise "count wrong 2" unless c.size == 2
		raise "customer wrong 2" unless c[0].first_name == 'One'
		raise "customer wrong 3" unless c[1].first_name == 'Ten'

		# 2.1.2 take
		# While ActiveRecord explicitly does not make any ordering guarantees
		#    with .take(), MySQL provides implicit ordering by primary key, so
		#    we can expect specific results here
		raise "customer wrong 4" unless Customer2.take.first_name == 'One'
		c = Customer2.take(2)
		raise "count wrong 2" unless c.size == 2
		raise "customer wrong 5" unless c[0].first_name == 'One'
		raise "customer wrong 6" unless c[1].first_name == 'Two'

		# 2.1.3 first
		raise "customer wrong 7" unless Customer2.first.first_name == 'One'
		c = Customer2.first(3)
		raise "count wrong 3" unless c.size == 3
		raise "customer wrong 8" unless c[0].first_name == 'One'
		raise "customer wrong 9" unless c[1].first_name == 'Two'
		raise "customer wrong 10" unless c[2].first_name == 'Three'
		raise "customer wrong 11" unless Customer2.order(:first_name).first.first_name == 'Eight'

		# 2.1.4 last
		raise "customer wrong 12" unless Customer2.last.first_name == 'Ten'
		c = Customer2.last(3)
		raise "count wrong 4" unless c.size == 3
		raise "customer wrong 13" unless c[0].first_name == 'Eight'
		raise "customer wrong 14" unless c[1].first_name == 'Nine'
		raise "customer wrong 15" unless c[2].first_name == 'Ten'
		raise "customer wrong 16" unless Customer2.order(:first_name).last.first_name == 'Two'

		# 2.1.5 find_by
		raise "customer wrong 17" unless Customer2.find_by!(first_name: 'Seven').id == 7
	end

	task :step_2_2 do
		# 2.2.1 find_each
		Customer2.find_each do |c|
			raise "customer wrong 1" unless c.first_name == c.id.humanize.humanize
		end
		Customer2.where(id: [1, 2, 3, 5, 7, 11]).find_each do |c|
			raise "customer wrong 2" unless c.first_name == c.id.humanize.humanize
			raise "customer wrong 3" unless ['One', 'Two', 'Three', 'Five', 'Seven'].include? c.first_name
		end
		# 2.2.1.1 Options for find_each
		# :batch_size
		Customer2.find_each(batch_size: 3) do |c|
			raise "customer wrong 4" unless c.first_name == c.id.humanize.humanize
		end
		# :start
		Customer2.find_each(start: 8) do |c|
			raise "customer wrong 5" unless c.first_name == c.id.humanize.humanize
			raise "customer wrong 6" unless [8, 9, 10].include? c.id
		end
		# :finish
		Customer2.find_each(start: 5, finish: 8) do |c|
			raise "customer wrong 7" unless c.first_name == c.id.humanize.humanize
			raise "customer wrong 8" unless [5, 6, 7, 8].include? c.id
		end
		# :error_on_ignore
		# ???

		# 2.2.2 find_in_batches
		Customer2.find_in_batches do |c|
			raise "count wrong 1" unless c.size == 10
		end
		# 2.2.1.1 Options for find_in_batches
		# :batch_size
		Customer2.find_in_batches(batch_size: 2) do |c|
			raise "count wrong 2" unless c.size == 2
		end
		# :start
		Customer2.find_in_batches(batch_size: 4, start: 3) do |batch|
			raise "count wrong 3" unless batch.size == 4
			batch.each do |c|
				raise "id wrong 1" if c.id < 2
			end
		end
		# :finish
		Customer2.find_in_batches(finish: 8) do |batch|
			raise "count wrong 4" unless batch.size == 8
			batch.each do |c|
				raise "id wrong 2" if c.id > 8
			end
		end
		# :error_in_ignore
		# ???
	end

	task :step_3_1 do
		books = Book6.where("title LIKE 'Book 1-1-%'").to_a
		raise 'count wrong' unless books.size == 3
		books.each do |b|
			raise "supplier wrong" unless b.supplier5_id == 1
			raise "author wrong" unless b.author5_id == 1
		end
	end

	task :step_3_2 do
		books = Book6.where("title = ?", 'Book 1-1-1').to_a
		raise 'count wrong 1' unless books.size == 1
		book = books.first
		raise 'supplier wrong 1' unless book.supplier5_id == 1
		raise 'author wrong 1' unless book.author5_id == 1
		raise 'price wrong 1' unless book.price == 111
		raise 'published date wrong 1' unless book.year_published == 2003
		raise 'out of print wrong 1' unless book.out_of_print == false

		books = Book6.where("title = ? AND out_of_print = ?", 'Book 4-8-2', false).to_a
		raise 'count wrong 2' unless books.size == 0
		books = Book6.where("title = ? AND out_of_print = ?", 'Book 4-8-2', true).to_a
		raise 'count wrong 2' unless books.size == 1
		book = books.first
		raise 'supplier wrong 2' unless book.supplier5_id == 4
		raise 'author wrong 2' unless book.author5_id == 8
		raise 'price wrong 2' unless book.price == 482
		raise 'published date wrong 2' unless book.year_published == 2014
		raise 'out of print wrong 2' unless book.out_of_print == true

		books = Book6.where("created_at >= :start_date AND created_at <= :end_date", {
			start_date: '2021-01-01', end_date: '3021-01-01'
		}).to_a
		raise 'count wrong 3' unless books.size == (10 * 10 * 3)
	end

	task :step_3_3 do
		# 3.3.1 Equality Conditions
		books = Book6.where(out_of_print: true).to_a
		raise 'count wrong 1' unless books.size == (10 * 10 * 1)

		books = Book6.where('out_of_print' => true).to_a
		raise 'count wrong 2' unless books.size == (10 * 10 * 1)

		author = Author5.first
		books = Book6.where(author5_id: author.id).to_a
		raise 'count wrong 3' unless books.size == (10 * 3)
		Author5.joins(:books).where(books: { author: author }) # What does this do?  What do we actually check?

		# 3.3.2 Range Conditions
		books = Book6.where(created_at: (Time.new(2021, 01, 01)..Time.new(3021, 01, 01))).to_a
		raise 'count wrong 4' unless books.size == (10 * 10 * 3)
		books = Book6.where(year_published: 2005..2010).to_a
		raise 'count wrong 5' unless books.size == 81
		books.each do |b|
			raise "published date wrong (#{b.id})" unless b.year_published >= 2005 && b.year_published <= 2010
		end

		# 3.3.3 Subset Conditions
		customers = Customer2.where(orders_count: [1, 3, 5]).to_a
		raise 'count wrong 6' unless customers.size == 3
	end

	task :step_3_4 do
		customers = Customer2.where.not(orders_count: [1, 3, 5]).to_a
		raise 'count wrong' unless customers.size == 7
	end

	task :step_3_5 do
		customers = Customer2.where(first_name: 'Two').or(Customer2.where(orders_count: [1, 3, 5])).to_a
		raise 'count wrong 1' unless customers.size == 4
		customers = Customer2.where(first_name: 'One').or(Customer2.where(orders_count: [1, 3, 5])).to_a
		raise 'count wrong 1' unless customers.size == 3
	end

	task :step_4 do
		customers = Customer2.order(:created_at).to_a
		raise 'count wrong 1' unless customers.size == 10
		(0..9).each do |i|
			raise "id wrong 1 (#{i})" unless customers[i].id == (i + 1)
		end

		customers = Customer2.order(created_at: :desc).to_a
		raise 'count wrong 2' unless customers.size == 10
		(0..9).each do |i|
			raise "id wrong 2 (#{i})" unless customers[i].id == (10 - i)
		end

		customers = Customer2.order(created_at: :desc, orders_count: :asc).to_a
		raise 'count wrong 3' unless customers.size == 10
		(0..9).each do |i|
			raise "id wrong 3 (#{i})" unless customers[i].id == (10 - i)
		end

		customers = Customer2.order("orders_count ASC", "created_at DESC").to_a
		raise 'count wrong 4' unless customers.size == 10
		(0..9).each do |i|
			raise "id wrong 4 (#{i})" unless customers[i].id == (i + 1)
		end
	end
end

