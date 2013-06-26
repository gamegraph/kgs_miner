require 'active_record'
require 'activerecord-import'

# Represents a kgs username that has already been requested.
class KgsUsername < ActiveRecord::Base
  attr_accessible :requested, :un

  validates :requested, inclusion: { in: [true, false] }
  validates :un, presence: true, uniqueness: true

  def self.import_newly_discovered usernames
    return if usernames.empty?
    columns = [:un, :requested]
    values = usernames.map { |un| [un, false] }
    import columns, values, :validate => false # uniqueness already checked in `main`
    puts sprintf "inserted: %d usernames", usernames.length
  end
end
