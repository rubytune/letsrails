class DealImage < ApiModel
  belongs_to :deal

  string :url
  integer :width
  integer :height

  LIST_WIDTH = 280
  WIDE_WIDTH = 680

  def list
    width == LIST_WIDTH
  end

  def wide
    width == WIDE_WIDTH
  end
end
