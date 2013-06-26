# Represents a kgs username that has already been requested.
class KgsUsername < ActiveRecord::Base
  validates :un, presence: true, uniqueness: true
end
