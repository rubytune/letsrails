class ApiModel
  include HTTParty
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  include Attribution

  base_uri 'localhost:2601'

  def initialize(attrs={})
    attrs.each do |k,v|
      send("#{k}=", v)
    end
  end

  def self.cast(obj)
    case obj
    when Hash then new(obj)
    when self then obj
    else raise ArgumentError.new("can't convert #{obj.class} to #{name}")
    end
  end

  # HTTP stuff
  def self.get(path, options={})
    url = File.join(base_uri, path)
    if options[:query].present?
      url << "?#{options[:query].to_param}"
    end
    resp = nil
    ms = Benchmark.ms { resp = super }
    logger.info("GET %s %3d %0.1fms" % [url, resp.code, ms])
    logger.ap resp.parsed_response if resp.code == 200
    resp
  end

  def self.from_response(resp)
    case resp.code
    when 200
      data = resp.parsed_response
      if data.is_a?(Array)
        data.map{|d| new(d) }
      else
        new(data)
      end
    when 404
      nil
    else
      raise "HTTP #{resp.code}"
    end
  end

  # Finders
  def self.all(query={})
    from_response(get("/#{name.underscore.pluralize}", :query => query))
  end

  def self.find(id)
    from_response(get("/#{name.underscore.pluralize}/#{id}"))
  end

  def self.logger
    Rails.logger
  end

  def logger
    self.class.logger
  end

  # Common attributes
  integer :id
  time :created_at
  time :updated_at

  # ActiveModel-ish stuff
  def to_param
    id
  end

  def persisted?
    false
  end

end
