class CreateTicket < ActiveRecord::Migration[6.0]
  def change
    create_table :tickets do |t|
      t.integer  :amount
      t.string   :payment_method
      t.integer :user, index: true
      t.datetime :paid_at
      t.datetime :start_at
      t.datetime :end_at
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_reference :tickets, :user, index: true, foreign_key: true

  end
end
