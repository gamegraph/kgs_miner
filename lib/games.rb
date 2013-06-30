module KgsMiner
  class Games
    def self.uniq_usernames_in games
      return [] if games.empty?
      usernames = Set.new games.map(&:usernames).flatten
      assert_num_uniq_players(games, usernames)
      puts sprintf "parsed: %d distinct usernames", usernames.length
      usernames.to_a
    end

    private

    def self.assert_num_uniq_players games, usernames
      rng = expected_num_uniq_players(games)
      unless rng.cover? usernames.length
        raise "Expected #{rng} usernames, found #{usernames.length}"
      end
    end

    # KGS usernames seem to be case-insensitive.  However, we
    # downcase usernames in `Game.new` so, given a set of G games
    # in which one player is always present, the max. number of
    # unique players is G + 1.  The minimum, if they play only one
    # other person, is 2.
    def self.expected_num_uniq_players games
      (2..games.length + 1)
    end
  end
end
