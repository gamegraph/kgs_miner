module KgsMiner
  class Games
    def self.uniq_usernames_in games
      usernames = Set.new games.map(&:usernames).flatten
      assert_num_uniq_players(games, usernames)
      usernames.to_a
    end

    private

    def self.assert_num_uniq_players games, usernames
      rng = expected_num_uniq_players(games)
      unless rng.cover? usernames.length
        raise "Expected #{rng} usernames, found #{usernames.length}"
      end
    end

    # Given a set of G games between me and everyone else, the max.
    # number of unique players is G + 1.  The minimum, if I play
    # only one other person, is 2.
    def self.expected_num_uniq_players games
      (2..games.length + 1)
    end
  end
end
