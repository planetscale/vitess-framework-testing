namespace :guide_validation do
	desc "1 Validations Overview"
	task :step_1 do
		raise "validation failed" unless Person.create(name: "John Doe").valid?
		raise "validation should have failed" if Person.create(name: nil).valid?
	end

	task :step_1_1 do
	end

	task :step_1_2 do
		p = Person.new(name: "John Doe")
		raise "not new" unless p.new_record?
		raise "save failed" unless p.save
		raise "new" if p.new_record?
	end

	task :step_1_3 do
		# There are no code snippers; should we write some oureslves tha tuse the functions mentioned?
	end

	task :step_1_4 do
		p = Person.new
		raise "errors" unless p.errors.size == 0
		raise "should be invalid" if p.valid?
		raise "wrong error" if p.errors.objects.first.full_message != "Name can't be blank"

		p = Person.create
		raise "wrong error" if p.errors.objects.first.full_message != "Name can't be blank"
		raise "save succeeded" if p.save
		begin
			p.save!
		rescue ActiveRecord::RecordInvalid
		end
		begin
			Person.create!
		rescue ActiveRecord::RecordInvalid
		end
	end

	task :step_1_5 do
		raise "errors before validation" if Person.new.errors[:name].any?
		raise "no errors after validation" unless Person.create.errors[:name].any?
	end
end
