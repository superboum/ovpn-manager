require 'sinatra/activerecord'

class User < ActiveRecord::Base
  has_many :ticket

  def set_password(rpass)
    self.password = Digest::SHA256.hexdigest(self.email + ':' + rpass)
  end

  def check_password(rpass)
    self.password == Digest::SHA256.hexdigest(self.email + ':' + rpass)
  end
end
