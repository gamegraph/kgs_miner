# Represents a kgs username that has already been requested.
class KgsUsername < ActiveRecord::Base
  validates :requested, inclusion: { in: [true, false] }
  validates :un, presence: true, uniqueness: true
end
