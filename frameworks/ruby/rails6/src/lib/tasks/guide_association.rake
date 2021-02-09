namespace :guide_association do
	task :step_1 do
		@author = Author.create(name: "Somebody")
		@book = @author.book2s.create(title: "Epic Novel")
		@author.destroy
		# TODO:  Issue a bare SQL query to ensure that Somebody and Epic Novel are both gone from the database
	end
end

