require 'openssl'

class Ovpn
  CONFIG  = "./config/ovpn.conf"
  KEYS    = "./persist/keys/"
  DHPEM   = "./persist/keys/dh.pem"
  CAKEY   = "./persist/keys/ca.key"
  CACRT   = "./persist/keys/ca.crt"

  def generate_server_keys
    generate_diffie
    generate_certificate_authority
    generate_key "server"
  end
  
  def generate_diffie
    puts "Generating Diffie-Hellman Key (dh.pem)"
    diffie = OpenSSL::PKey::DH.new(4096)
    File.write(DHPEM, diffie)
    puts "Generation success !"
  end

  def generate_certificate_authority
    puts "Generating Certificate Authority Private Key (ca.key)"
    root_key = OpenSSL::PKey::RSA.new 4096 # the CA's public/private key
    File.write(CAKEY, root_key)
    puts "Generation success !"
    
    puts "Generating Certificate Authority (ca.crt)"
    root_ca = OpenSSL::X509::Certificate.new
    root_ca.version = 2 # cf. RFC 5280 - to make it a "v3" certificate
    root_ca.serial = 1
    root_ca.subject = OpenSSL::X509::Name.parse "/DC=fr/DC=deuxfleurs/CN=vpn"
    root_ca.issuer = root_ca.subject # root CA's are "self-signed"
    root_ca.public_key = root_key.public_key
    root_ca.not_before = Time.now
    root_ca.not_after = root_ca.not_before + 10 * 365 * 24 * 60 * 60 # 10 years validity
    ef = OpenSSL::X509::ExtensionFactory.new
    ef.subject_certificate = root_ca
    ef.issuer_certificate = root_ca
    root_ca.add_extension(ef.create_extension("basicConstraints","CA:TRUE",true))
    root_ca.add_extension(ef.create_extension("keyUsage","keyCertSign, cRLSign", true))
    root_ca.add_extension(ef.create_extension("subjectKeyIdentifier","hash",false))
    root_ca.add_extension(ef.create_extension("authorityKeyIdentifier","keyid:always",false))
    root_ca.sign(root_key, OpenSSL::Digest::SHA256.new)
    File.write(CACRT, root_ca)
    puts "Generation success !"
  end

  def generate_key (name)
    root_ca = OpenSSL::X509::Certificate.new File.read CACRT
    root_key = OpenSSL::PKey::RSA.new File.read CAKEY

    puts "Generating "+name+" Private Key ("+name+".key)"
    key = OpenSSL::PKey::RSA.new 2048
    File.write(KEYS+name+".key", key)
    puts "Generation success !"

    puts "Generating "+name+" Certificate ("+name+".crt)"
    cert = OpenSSL::X509::Certificate.new
    cert.version = 2
    cert.serial = 2
    cert.subject = OpenSSL::X509::Name.parse "/DC=fr/DC=deuxfleurs/CN="+name
    cert.issuer = root_ca.subject # root CA is the issuer
    cert.public_key = key.public_key
    cert.not_before = Time.now
    cert.not_after = cert.not_before + 10 * 365 * 24 * 60 * 60 # 10 years validity
    ef = OpenSSL::X509::ExtensionFactory.new
    ef.subject_certificate = cert
    ef.issuer_certificate = root_ca
    cert.add_extension(ef.create_extension("keyUsage","digitalSignature", true))
    cert.add_extension(ef.create_extension("subjectKeyIdentifier","hash",false))
    cert.sign(root_key, OpenSSL::Digest::SHA256.new)
    File.write(KEYS+name+".crt", cert)
    puts "Generation success !"
  end

  def embedded_conf (name, remotes) 
    config = File.read ('config/ovpn-client.conf')
    
    config = config.gsub("{{ CA }}", File.read(KEYS+'ca.crt'))
    config = config.gsub("{{ CERT }}", File.read(KEYS+name+'.crt'))
    config = config.gsub("{{ KEY }}", File.read(KEYS+name+'.key'))
    config = config.gsub("{{ REMOTE }}", remotes)

    return config
  end
end

#o = Ovpn.new()
#o.launch
#o.check
#o.generate_server_keys
#o.generate_key "john"
#Process.wait
