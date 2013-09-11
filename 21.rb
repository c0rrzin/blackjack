module Blackjack
  class Dealer
    def initialize
      @cards = [2,3,4,5,6,7,8,9,10,10,10,10,"A"]*4
    end
    def deal
      @cards.shuffle!.pop
    end
  end

  class Player
    def initialize(cards, dealer)
      @number_aces = cards.select { |card|  card.is_a? String }.size
      sum = 0
      cards.each do |card|
        if card.is_a? Integer
          sum += card
        end
      end
      @fixed_sum = sum
      @dealer = dealer
    end

    def want_card?
      sum = process_aces
      sum < 13
    end

    def hit_me!
      if want_card?
        card = @dealer.deal
        update_attributes_with card
        return true
      end
      false
    end

    def show_cards
      @fixed_sum + @dynamic_sum
    end

    class << self
      def who_want_cards
        players = []
        ObjectSpace.each_object(self) do |player|
          players << player if player.want_card?
        end
        players
      end
    end

    private

    def process_aces
      @dynamic_sum = 11*@number_aces
      number_aces = @number_aces
      while @dynamic_sum + @fixed_sum > 21 && number_aces > 0
        @dynamic_sum -= 10
        number_aces -= 1
      end
      @dynamic_sum + @fixed_sum
    end

    def update_attributes_with card
      if card.is_a? Integer
        @fixed_sum += card
      else
        @number_aces += 1
      end 
      process_aces
    end
  end

  class Analytics
    def initialize(number_plays, verbose=false)
      @number_plays = number_plays
      @avg_hand ||= 0
      @losses = 0
      play(verbose)
      show_statistics
    end

    def show_statistics
      @avg_hand /= (@number_plays - @losses)
      puts "--- Strategy statistics ---"
      puts "Average hand: #{@avg_hand}"
      puts "Number losses: #{@losses} (#{@losses*100/@number_plays}%)"
    end

    private

    def play(verbose)
      @number_plays.times do |time|
        dealer = Blackjack::Dealer.new
        cards = [dealer.deal, dealer.deal]
        player = Blackjack::Player.new(cards, dealer)
        counter = 0
        while player.want_card?
          player.hit_me!
          counter += 1
        end
        if player.show_cards > 21
          @losses += 1
        else
          @avg_hand += player.show_cards
        end
        show_game_statistics(cards, counter, player.show_cards, time) if verbose
      end
    end

    def show_game_statistics(cards, counter, final_sum, number_game)
      puts "--- Game Statistics ##{number_game} ---"
      puts "Number of hit-me: #{counter}"
      puts "Initial hand: #{cards}"
      puts "final_sum: #{final_sum}"
    end
  end

end