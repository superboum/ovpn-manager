require 'sinatra'
require "sinatra/config_file"
require 'securerandom'
require 'pony'
require_relative 'model/init'
require_relative 'lib/ovpn'

config_file 'persist/config.yml'

#enable :sessions
use Rack::Session::Cookie,
  :key => 'rack.session',
  :path => '/',
  :secret => settings.cookie_secret

Pony.options = {
  :from => settings.mail['from'],
  :via => :smtp,
  :via_options => {
    :address              => settings.mail['server'],
    :port                 => settings.mail['port'],
    :enable_starttls_auto => settings.mail['starttls'],
    :user_name            => settings.mail['username'],
    :password             => settings.mail['password'],
    :openssl_verify_mode  => settings.mail['ssl_no_verify'] ? OpenSSL::SSL::VERIFY_NONE : OpenSSL::SSL::VERIFY_PEER,
    :authentication       => settings.mail['auth'], # :plain, :login, :cram_md5, no auth by default
    :domain               => "localhost.localdomain" # the HELO domain provided by the client to the server

  }
}

o = Ovpn.new()
o.generate_server_keys unless File.exists?('persist/keys/server.key')

helpers do
  def user?
    @user.instance_of? User and @user.role >= 0
  end
  def restrictToUser! 
    redirect to('/login'),303 unless user?
  end
end

before do
  @user = User.find session[:user] unless session[:user] == nil
end

get '/login' do
  haml :connect
end

post '/login' do
  u = User.find_by email: params['email']
  if u == nil || !u.check_password(params['password']) then
    redirect to('/login'),303
  else
    session[:user] = u.id
    redirect to('/'),303
  end
end

get '/logout' do
  session[:user] = nil
  redirect to('/login'), 303
end

get '/create_account' do
  haml :create_account, :locals => { :token => params[:token]}
end

post '/create_account' do
  u = User.find_by token: params[:token]
  
  if 
    params['email'] == ''    ||
    params['password1'] == '' ||
    params['password1'] != params['password2'] || 
    params['token'] == nil ||
    u == nil then
    redirect to('/create_account?token='+params['token'])
  else
    u.role = 0
    u.email = params[:email]
    u.set_password(params['password1'])
    u.token = nil
    u.save

    o.generate_key u.email
    session[:user] = u.id
    redirect to('/'), 303
  end
end

get '/certificates' do
  headers \
    "Content-Disposition" => "attachment; filename=#{settings.name}.ovpn;",
    "Content-Type" => "application/octet-stream",
    "Content-Transfer-Encoding" => "binary"

  o.embedded_conf(@user.email, settings.remotes)
end

get '/' do
  restrictToUser!
  haml :home

end

def invite(email)
  u = User.new
  u.token = SecureRandom.urlsafe_base64
  u.save
  Pony.mail(
    :to => email, 
    :subject => 'Invitation VPN', 
    :body => "Vous avez été invité à vous créer un compte sur le VPN Celeris.\nSi vous souhaitez vous inscrire, rendez-vous sur #{settings.base_url}/create_account?token="+u.token+" \nSinon, vous pouvez ignorer cet email."
  )
  return u
end

post '/invite' do
  restrictToUser!
  u = invite(params[:email])
  logger.info "Email sent to "+params[:email]+" with token "+u.token
  redirect to('/'), 303
end
