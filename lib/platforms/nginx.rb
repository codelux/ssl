require 'platforms/platform'

class Nginx < Platform
  @@locations=[]
  @@domains=[]
  @@sites=[]
  KEY = "nginx"
  SEARCH = %w(/opt/nginx/conf/nginx.conf)

  def self.has_installation?
    SEARCH.each do |dir|
      @@locations << dir if File.exists?(dir)
    end
    !@@locations.empty?
  end

  def self.locations
    @@locations
  end

  def self.sites
    @@sites
  end

  def self.domains
    @@domains
  end
end