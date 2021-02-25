namespace :guide_query_interface do
	task :seed do
		for i in 1..10
			Customer2.create(first_name: i.humanize.humanize)
		end
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
		#    here, MySQL provides implicit ordering by primary key, so we can
		#    expect specific results here
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
end

