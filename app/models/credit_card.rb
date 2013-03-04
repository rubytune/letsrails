class CreditCard < ApiModel
  belongs_to :person

  string :number
  integer :expiration_month
  integer :expiration_year
  string :first_six
  string :last_four
  integer :number_length
end
