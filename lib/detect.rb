require 'platforms/nginx'
require 'platforms/apache2'

class Detect
  # three things we need are openssl, the ssl certs directory, and the web platform conf files
  SSL_CERTS_LOCATION = "etc/ssl/certs"
  SSL_CACERTS_LOCATION = "etc/ssl/private"
  OPENSSL_INSTALLATIONS = `which openssl`
  @@nginx_locations=[]
  @@apache2_locations=[]


  def self.web_platforms(options)
    platforms = []
    subclasses = Platform.get_subclasses
    subclasses.each do |c|
      platforms << c::KEY if c.has_installation?
    end
    unless platforms.empty?
      puts "\n\nThe following web platforms were found on this server installation:"
      platforms.each_with_index do |p, i|
        puts "#{i}: #{p}"
      end
      if platforms.count > 1
        puts "\n\nPlease type the number corresponding to the web platform to install the ssl certificate on:"
        puts "[0]"
        options[:platform] = gets.chomp
        options[:platform] = 0 if options[:platform].empty?
      else
        options[:platform] = 0
      end
      Platform.get_subclasses.each do |c|
        if Regexp.new(c::KEY, "i") =~ platforms[options[:platform].to_i]
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
          puts "\nThe following sites were found on this web platform: \n\n"
          c.sites.each_with_index do |s, i|
            puts "#{i}: #{s}"
          end
          puts "\nPlease type the number corresponding to the site that you want ssl installed on:"
          puts "[0]"
          options[:site] = gets
          options[:site] = 0 if options[:site].empty?
          puts "The following domains were found on this web platform: \n\n"
          puts "["+c.domains.join(", ")+"]\n\n"
          puts "Please type in the domain(s) that you want embedded in your ssl certificate. "+
                "Multiple domains should be comma separated. Wildcard certificates should be prefixed with "+
                "a *. (ie *.domains.com)."
          options[:cert_domains]=gets.chomp
          puts "Please type in company/organization name for the ssl certificate. Press enter to leave blank."
          options[:cert_org]=gets.chomp
          puts "Please type in department name for the ssl certificate. Press enter to leave blank."
          options[:cert_dept]=gets.chomp
          puts "Please type in city name for the ssl certificate. Press enter to leave blank."
          options[:cert_city]=gets.chomp
          puts "Please type in state or province name for the ssl certificate. Press enter to leave blank."
          options[:cert_city]=gets.chomp
          puts "Please type in 2-character ISO-3166 country code for the ssl certificate "+
               "(please see https://www.ssl.com/csrs/country_codes for accepted codes)."
          puts "[US]"
          options[:cert_country]=gets.chomp
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

  def self.ssl_certs(options)
    puts "Please enter this server installation's ssl certificates location. This where the certificate will be "+
      "created along with the signing request to be sent to the certificate authority to be signed."
    puts "[#{Detect::SSL_CERTS_LOCATION}]"
    options[:ssl_certs_location] = gets.chomp
    options[:ssl_certs_location] = Detect::SSL_CERTS_LOCATION if options[:ssl_certs_location].empty?
  end

  def self.ssl_cacerts(options)
    puts "Please enter this server installation's ssl root and intermediate certificates location. This is where "+
      "any intermediate certificate, if any is required, will be installed."
    puts "[#{Detect::SSL_CACERTS_LOCATION}]"
    options[:ssl_cacerts_location] = gets.chomp
    options[:ssl_cacerts_location] = Detect::SSL_CACERTS_LOCATION if options[:ssl_cacerts_location].empty?
  end
end