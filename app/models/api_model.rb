class ApiModel
  include HTTParty

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

  # Danger, thar be metaprogramming ahead :)

  # Attribute macros
  def self.string(attr)
    attr_reader(attr)
    define_method("#{attr}=") do |arg|
      instance_variable_set("@#{attr}", arg.to_s)
    end
  end

  def self.boolean(attr)
    attr_reader(attr)
    define_method("#{attr}=") do |arg|
      instance_variable_set("@#{attr}", !!arg)
    end
    alias_method "#{attr}?", attr
  end

  def self.integer(attr)
    attr_reader(attr)
    define_method("#{attr}=") do |arg|
      instance_variable_set("@#{attr}", arg.to_i)
    end
  end

  def self.float(attr)
    attr_reader(attr)
    define_method("#{attr}=") do |arg|
      instance_variable_set("@#{attr}", arg.to_f)
    end
  end

  def self.decimal(attr)
    attr_reader(attr)
    define_method("#{attr}=") do |arg|
      instance_variable_set("@#{attr}", BigDecimal.new(arg.to_s))
    end
  end

  def self.date(attr)
    attr_reader(attr)
    define_method("#{attr}=") do |arg|
      v = case arg
      when Date then arg
      when Time, DateTime then arg.to_date
      when String then Date.parse(arg)
      else raise ArgumentError.new("can't convert #{arg.class} to Date")
      end
      instance_variable_set("@#{attr}", v)
    end
  end

  def self.time(attr)
    attr_reader(attr)
    define_method("#{attr}=") do |arg|
      v = case arg
      when Date, DateTime then arg.to_time
      when Time then arg
      when String then Time.parse(arg)
      else raise ArgumentError.new("can't convert #{arg.class} to Time")
      end
      instance_variable_set("@#{attr}", v)
    end
  end

  def self.time_zone(attr)
    attr_reader(attr)
    define_method("#{attr}=") do |arg|
      instance_variable_set("@#{attr}", ActiveSupport::TimeZone[arg.to_s])
    end
  end

  # Association macros
  def self.belongs_to(association_name)
    begin
      association_class = association_name.to_s.classify.constantize
    rescue NameError => ex
      raise ArgumentError.new("Association #{association_name} in #{name} is invalid because #{association_name.to_s.classify} does not exist")
    end

    # foo_id
    define_method("#{association_name}_id") do
      ivar = "@#{association_name}_id"
      if instance_variable_defined?(ivar)
        instance_variable_get(ivar)
      else
        if obj = send(association_name)
          instance_variable_set(ivar, obj.id)
        else
          instance_variable_set(ivar, nil)
        end
      end
    end

    # foo_id=
    define_method("#{association_name}_id=") do |arg|
      instance_variable_set("@#{association_name}_id", arg.to_i)
    end

    # foo
    define_method(association_name) do
      if instance_variable_defined?("@#{association_name}")
        instance_variable_get("@#{association_name}")
      elsif id = instance_variable_get("@#{association_name}_id")
        instance_variable_set("@#{association_name}", association_class.find(id))
      else
        instance_variable_set("@#{association_name}", nil)
      end
    end

    # foo=
    define_method("#{association_name}=") do |arg|
      if instance_variable_defined?("@#{association_name}_id")
        remove_instance_variable("@#{association_name}_id")
      end
      instance_variable_set("@#{association_name}", association_class.cast(arg))
    end
  end

  def self.has_many(association_name)
    begin
      association_class = association_name.to_s.singularize.classify.constantize
    rescue NameError => ex
      raise ArgumentError.new("Association #{association_name} in #{name} is invalid because #{association_name.to_s.classify} does not exist")
    end

    # foos
    define_method(association_name) do
      ivar = "@#{association_name}"
      if instance_variable_defined?(ivar)
        instance_variable_get(ivar)
      else
        instance_variable_set(ivar, Array(association_class.all("#{self.class.name.underscore}_id" => id)))
      end
    end

    # foos=
    define_method("#{association_name}=") do |arg|
      objs = Array(arg).map do |obj|
        o = association_class.cast(obj)
        o.send("#{self.class.name.underscore}=", self)
        o.send("#{self.class.name.underscore}_id=", id)
        o
      end
      instance_variable_set("@#{association_name}", objs)
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

  def to_param
    id
  end

end
