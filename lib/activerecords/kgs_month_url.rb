# Represents a url that has already been requested.
class KgsMonthUrl < ActiveRecord::Base
  validates :url, presence: true, uniqueness: true
end
