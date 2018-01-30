# ovpn-manager

If you plan to really use this software, you should regularly regenerate your own docker container, as the one provided will not be updated regularly and could not integrate the latest available security patches.

## Production

Example of `config.yml`:

```
# /srv/ovpn-manager/persist/config.yml
cookie_secret: "toto"
mail:
  server: "smtp.provider.tld"
  port: 587
  starttls: true
  username: "you@provider.tld"
  password: "password"
  ssl_no_verify: false
  auth: "login"
  from: "you@provider.tld"
name: "you"
base_url: "http://127.0.0.1:9292"
remotes: |
  remote vpn01.provider.tld 1194
  remote vpn01.provider.tld 8010
  remote vpn02.provider.tld 1194
```

Now run:

```
sudo docker run \
  --name ovpn-manager-01 \
  -v=/srv/ovpn-manager/persist:/root/manager/persist \
  --privileged \
  -p 9292:9292 \
  -p 8010:8010/udp \
  -i -t \
  superboum/ovpn-manager

sudo docker exec -t -i ovpn-manager-01 \
  bundle exec racksh 'u = User.new :email => "you@provider.tld"; u.set_password("toto"); u.save'

```

## Development

```
cp config/database.sample.yml config/database.yml
cp persist/config.sample.yml persist/config.yml
bundle exec rake --tasks
bundle exec rake db:create
bundle exec rake db:migrate
bundle exec racksh 'u = User.new :email => "you@provider.tld"; u.set_password("toto"); u.save'
```

(racksh is very impressive, you can access to your environment in a REPL with your configurations loaded).

Build the container:

```
sudo docker build -t superboum/ovpn-manager .
```
