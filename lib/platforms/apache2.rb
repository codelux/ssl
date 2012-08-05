require 'platforms/platform'

class Apache2 < Platform
  @@locations=[]
  @@domains=[]
  @@sites=[]
  KEY="apache2"
  SEARCH = `which apache2ctl`

  def self.has_installation?
    @@locations << SEARCH unless SEARCH.empty?
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