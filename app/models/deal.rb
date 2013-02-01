class Deal < ApiModel
  belongs_to :city

  string :short_title
  string :long_title
  string :description
  time :offer_starts_at
  time :offer_ends_at

  has_many :deal_images
  has_many :options

  delegate :price, :to => :primary_option, :allow_nil => true
  delegate :value, :to => :primary_option, :allow_nil => true

  def list_deal_images
    @list_deal_images ||= deal_images.select(&:list)
  end

  def list_deal_image
    @list_deal_image ||= list_deal_images.first
  end

  def wide_deal_images
    @wide_deal_images ||= deal_images.select(&:wide)
  end

  def wide_deal_image
    @wide_deal_image ||= wide_deal_images.first
  end

  def ordered_options
    @ordered_options ||= options.sort_by(&:price)
  end

  def primary_option
    @primary_option ||= options.detect(&:primary?) || ordered_options.first
  end

  def discount
    primary_option.try(:discount).to_f
  end

  def countdown
    @countdown ||= begin
      t = offer_ends_in
      {
        :days => t[0],
        :hours => t[1],
        :minutes => t[2],
        :seconds => t[3]
      }
    end
  end

  # returns an array of [days, hours, minutes, seconds] until offer_ends_at
  def offer_ends_in
    if offer_ends_at < Time.now
      [0, 0, 0, 0]
    else
      seconds = (offer_ends_at - Time.now).to_i
      if seconds < 60
        [0, 0, 0, seconds]
      else
        minutes, seconds = seconds.divmod(60)
        if minutes < 60
          [0, 0, minutes, seconds]
        else
          hours, minutes = minutes.divmod(60)
          if hours < 24
            [0, hours, minutes, seconds]
          else
            days, hours = hours.divmod(24)
            [days, hours, minutes, seconds]
          end
        end
      end
    end
  end
end
