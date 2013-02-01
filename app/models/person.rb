class Person < ApiModel
  string :email
  string :first_name
  string :last_name
  string :password

  has_many :purchases
end
