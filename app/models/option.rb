class Option < ApiModel
  belongs_to :deal

  string :title
  decimal :price
  decimal :value
  boolean :primary

  def discount
    @discount ||= 100 * (price.to_d / value.to_d)
  end
end
