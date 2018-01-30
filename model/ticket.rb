require 'sinatra/activerecord'

class Ticket < ActiveRecord::Base
  belongs_to :user
end
