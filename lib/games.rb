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

    # KGS usernames seem to be case-insensitive.  However, a player
    # can change the capitalization of their account somehow. See
    # http://www.gokgs.com/gameArchives.jsp?user=Alf&oldAccounts=t&year=2012&month=12
    # Therefore, it's possible to find a maximum of games * 2 usernames.
    def self.expected_num_uniq_players games
      (2..games.length * 2)
    end
  end
end
