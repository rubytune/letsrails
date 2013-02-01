class Country < ApiModel
  string :name
  string :code
  string :language

  has_many :cities

  def locale
    language.downcase.to_sym
  end
end
