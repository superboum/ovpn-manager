class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :password
      t.string :phone
      t.string :address
      t.integer :role
      t.string :nationality
      t.integer :gender
      t.string :token
      t.string :certificate_id
      t.datetime :expire_date
      t.datetime :created_at
      t.datetime :updated_at
      t.date :birth
    end
  end
end
