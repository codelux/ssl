class Detect
  # three things we need are openssl, the ssl certs directory, and the web platform conf files
  SSL_INSTALLATIONS = %w(etc/ssl)
  OPENSSL_INSTALLATIONS = `which openssl`
  SEARCH_APACHE2 = `which apache2ctl`
  SEARCH_NGINX = %w(/opt/nginx/conf/nginx.conf)
  @@nginx_locations=[]
  @@apache2_locations=[]
  @@domains=[]
  @@sites=[]

  def self.web_platforms
    names = []
    name=""
    names << "apache2" if has_apache2?
    names << "nginx" if has_nginx?
    unless names.empty?
      puts "The following web platforms were found on this server installation: "+names.join(", ")
      if names.count > 1
        puts "Please type the name of the web platform to install the ssl certificate on ["+names.join(", ")+"]."
        name = gets
      else
        name = names.last
      end
      case name
        when /nginx/i
          # scan for config file
          @@nginx_locations.each do |conf|
            f = File.open(conf) #opens the file for reading
            f.each do |line|
               if line.match /server_name(.+)?;/
                  @@domains << $1.split(" ")
               end
            end
            @@domains.uniq!
          end
          @@nginx_locations.each do |conf|
            f = File.open(conf) #opens the file for reading
            f.each do |line|
              if line.match /root(.*)?;/
                s = $1.split(" ")
                if s.count != 1
                  puts "root directive is not formatted correctly; aborting."
                  exit! 1
                else
                  @@sites << s.last
                end
              end
            end
            @@sites.uniq!
          end
          puts "The following sites were found on this web platform: \n\n"
          @@sites.each_with_index do |s, i|
            puts "#{i}: #{s}"
          end
          puts "\nPlease type the number corresponding to the site that you want ssl installed on:"
          site=gets
          puts "The following domains were found on this web platform: \n\n"
          puts "["+@@domains.join(", ")+"]\n\n"
          puts "Please type in the domain(s) that you want embedded in your ssl certificate. "+
                "Multiple domains should be comma separated. Wildcard certificates should be prefixed with "+
                "a *. (ie *.domains.com)."
          domains=gets
      end
    else
      puts "No web platforms were detected on this server installation."
    end
  end

  def self.has_nginx?
    SEARCH_NGINX.each do |dir|
      @@nginx_locations << dir if File.exists?(dir)
    end
    !@@nginx_locations.empty?
  end

  def self.has_apache2?
    @@apache2_locations << SEARCH_APACHE2 unless SEARCH_APACHE2.empty?
    !@@apache2_locations.empty?
  end

end