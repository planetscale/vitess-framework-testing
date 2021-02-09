class AddAuthorAndBook2s < ActiveRecord::Migration[6.1]
  def change
    create_table :author do |t|
      t.string :name
      t.timestamps
    end

    create_table :book2s do |t|
      t.string :title
      t.timestamps
    end

    add_reference :book2s, :author
    add_foreign_key :book2s, :author
  end
end


