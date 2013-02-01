class Purchase < ApiModel
  belongs_to :person
  belongs_to :credit_card
  belongs_to :option

  integer :quantity

  has_many :vouchers
end
