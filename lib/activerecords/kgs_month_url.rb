require 'active_record'

# Represents a url that has already been requested.
class KgsMonthUrl < ActiveRecord::Base
  attr_accessible :url, :requested

  validates :requested, inclusion: { in: [true, false] }
  validates :url, presence: true, uniqueness: true
end
