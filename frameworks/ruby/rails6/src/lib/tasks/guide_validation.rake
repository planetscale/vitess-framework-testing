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
		# There are no code snippets; should we write some ourselves that use the functions mentioned?
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

	task :step_2_1 do
		p = Person2.new(terms_of_service: "something")
		raise "should be invalid 1" if p.valid?
		p = Person2.new(terms_of_service: "yes")
		raise "should be valid 1" unless p.valid?
		p = Person2.new(terms_of_service: "yes", eula: "something")
		raise "should be invalid 2" if p.valid?
		p = Person2.new(terms_of_service: "yes", eula: "TRUE")
		raise "should be valid 2" unless p.valid?
	end

	task :step_2_2 do
		lib = Library.create(name: "Library")
		raise "should be valid 1" unless lib.valid?
		b = lib.books.create(title: "Good Book")
		raise "should be valid 2" unless b.valid?
		b = lib.books.create(title: "Bad Book")
		raise "should be valid 3" unless b.valid?
		b = Book.create(title: "Fake Book")
		raise "should not be valid" if b.valid?
	end

	task :step_2_3 do
		p = Person3.new(email: "te@s.t")
		raise "should be invalid 1" if p.valid?
		p = Person3.new(email: "te@s.t", email_confirmation: "tte@s.t")
		raise "should be invalid 2" if p.valid?
		p = Person3.new(email: "te@s.t", email_confirmation: "te@s.t")
		raise "should be valid" unless p.valid?
	end

	task :step_2_4 do
		p = Person3.new(email: "inva@l.id", email_confirmation: "inva@l.id")
		raise "should be invalid" if p.valid?
		p = Person3.new(email: "va@l.id", email_confirmation: "va@l.id")
		raise "should be valid" unless p.valid?
	end

	task :step_2_5 do
		p = Person3.new(email: "invalid", email_confirmation: "invalid")
		raise "should be invalid" if p.valid?
		p = Person3.new(email: "valid@ema.il", email_confirmation: "valid@ema.il")
		raise "should be valid" unless p.valid?
	end

	task :step_2_6 do
		p = Person4.new(opt_in: "something")
		raise "should be invalid" if p.valid?
		p = Person4.new(opt_in: "yes")
		raise "should be valid 1" unless p.valid?
		p = Person4.new(opt_in: "no")
		raise "should be valid 2" unless p.valid?
	end

	task :step_2_7 do
		p = Person3.new(email: "a@b.c", email_confirmation: "a@b.c")
		raise "should be too short" if p.valid?
		p = Person3.new(email: "waaaay@too.long", email_confirmation: "waaaay@too.long")
		raise "should be too long" if p.valid?
		p = Person3.new(email: "gold@i.locks", email_confirmation: "gold@i.locks")
		raise "should be just right" unless p.valid?
	end

	task :step_2_8 do
		n = Numbers.new(integer: "a", float: "b")
		raise "should be invalid 1" if n.valid?
		n = Numbers.new(integer: "1", float: "b")
		raise "should be invalid 2" if n.valid?
		n = Numbers.new(integer: "a", float: "1.1")
		raise "should be invalid 3" if n.valid?
		n = Numbers.new(integer: "1.1", float: "1.1")
		raise "should be invalid 4" if n.valid?
		n = Numbers.new(integer: "1", float: "1.1")
		raise "should be valid" unless n.valid?
	end

	task :step_2_9 do
		p = Person3.new(email: "miss@i.ng")
		raise "should be invalid" if p.valid?
		p = Person3.new(email: "pres@en.t", email_confirmation: "pres@en.t")
		raise "should be valid" unless p.valid?
	end

	task :step_2_10 do
		n = Numbers.new(integer: "2", float: "2.2", string: "something")
		raise "should be invalid" if n.valid?
		n = Numbers.new(integer: "2", float: "2.2")
		raise "should be valid" unless n.valid?
	end

	task :step_2_11 do
		p = Person3.new(email: "per@s.on", email_confirmation: "per@s.on")
		raise "should be valid" unless p.valid?
		p.save!
		p = Person3.new(email: "per@s.on", email_confirmation: "per@s.on")
		raise "should be invalid" if p.valid?
	end

	task :step_2_12 do
		p = Person3.new(email: "evil@per.son", email_confirmation: "evil@per.son")
		raise "should be invalid" if p.valid?
		p = Person3.new(email: "good@per.son", email_confirmation: "good@per.son")
		raise "should be valid" unless p.valid?
	end

	task :step_2_13 do
		p = Person3.new(email: "Bad@ema.il", email_confirmation: "Bad@ema.il")
		raise "should be invalid" if p.valid?
		p = Person3.new(email: "good@ema.il", email_confirmation: "good@ema.il")
		raise "should be valid" unless p.valid?
	end
end

