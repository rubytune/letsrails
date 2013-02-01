class City < ApiModel
  belongs_to :country

  string :name
  string :slug
  time_zone :time_zone

  has_many :deals

  delegate :locale, :to => :country, :allow_nil => true

  def self.geolocate(ip_address)
    # TODO: Real implementation
    fallback
  end

  def self.fallback
    find(1)
  end
end
