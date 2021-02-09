class AddAuthorAndBook2s < ActiveRecord::Migration[6.1]
  def change
    create_table :authors do |t|
      t.string :name
      t.timestamps
    end

    create_table :book2s do |t|
      t.string :title
      t.belongs_to :author, foreign_key: true
      t.timestamps
    end
  end
end


