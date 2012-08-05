require 'platforms/nginx'
require 'platforms/apache2'

class Detect
  # three things we need are openssl, the ssl certs directory, and the web platform conf files
  SSL_LOCATION = "etc/ssl"
  OPENSSL_INSTALLATIONS = `which openssl`
  @@nginx_locations=[]
  @@apache2_locations=[]


  def self.web_platforms
    platforms = []
    # variables storing user entered data begins with a u_
    u_platform, u_domains="",""
    subclasses = Platform.get_subclasses
    subclasses.each do |c|
      platforms << c::KEY if c.has_installation?
    end
    unless platforms.empty?
      puts "The following web platforms were found on this server installation: "+platforms.join(", ")
      if platforms.count > 1
        puts "Please type the name of the web platform to install the ssl certificate on ["+platforms.join(", ")+"]."
        u_platform = gets.chomp
      else
        u_platform = platforms.last
      end
      Platform.get_subclasses.each do |c|
        if Regexp.new(c::KEY, "i") =~ u_platform
          # scan for config file
          c.locations.each do |conf|
            f = File.open(conf) #opens the file for reading
            f.each do |line|
               if line.match /server_name(.+)?;/
                 c.domains << $1.split(" ")
               end
            end
            c.domains.uniq!
          end
          c.locations.each do |conf|
            f = File.open(conf) #opens the file for reading
            f.each do |line|
              if line.match /root(.*)?;/
                s = $1.split(" ")
                if s.count != 1
                  puts "root directive is not formatted correctly; aborting."
                  exit! 1
                else
                  c.sites << s.last
                end
              end
            end
            c.sites.uniq!
          end
          puts "The following sites were found on this web platform: \n\n"
          c.sites.each_with_index do |s, i|
            puts "#{i}: #{s}"
          end
          puts "\nPlease type the number corresponding to the site that you want ssl installed on:"
          site=gets
          puts "The following domains were found on this web platform: \n\n"
          puts "["+c.domains.join(", ")+"]\n\n"
          puts "Please type in the domain(s) that you want embedded in your ssl certificate. "+
                "Multiple domains should be comma separated. Wildcard certificates should be prefixed with "+
                "a *. (ie *.domains.com)."
          u_domains=gets
          break
        end
      end
    else
      puts "No web platforms were detected on this server installation."
    end
  end

  def self.has_openssl?
    OPENSSL_INSTALLATIONS ? true : false
  end
end