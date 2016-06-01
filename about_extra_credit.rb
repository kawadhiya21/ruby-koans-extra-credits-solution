class Game
  def initialize(num_of_players)
    # Initialize the number of players playing the game
    @players = Array.new(num_of_players)
    
    @players.each_with_index { |val, index|
      puts "Enter player #{index+1}'s name"
      name = gets.chomp.capitalize
      @players[index] = Player.new(name)
    }
  end

  def start_game
    turn_count = 1
    # Bitwise AND whether each player's score is 
    # less than 3000. Else move to final round
    while @players.inject(true) { |gm, plyr| (gm && (plyr.total_score < 3000))}
      puts "Turn #{turn_count}"
      puts "--------"
      turn_count += 1
      play_turns
    end

    20.times { |n| print "-" }
    print "Final TURN Alert !!!!"
    20.times { |n| print "-" }
    puts
    
    # Calling play_turns once for the final round
    play_turns

    sort_final_scores
    display_final_scores
  end

  private
  def sort_final_scores
    @players.sort! do |p1, p2|
      case
      when p1.total_score > p2.total_score
        -1
      when p1.total_score <= p2.total_score
        1
      end
    end
  end

  def display_final_scores
    puts "Final scores"
    @players.each { |player| puts "Player #{player.name} : #{player.total_score}" }
  end 

  def play_turns
    @players.each do |player|
      # Initialize a new dice
      dice = DiceSet.new
      # check for first chance
      first_chance = true
      
      # Keep a check on number of dices left
      while dice.num > 0
        # First Chance
        if first_chance == true
          dice.roll  # roll the dice
          first_chance = false
        else
          # All other chances
          # Ask if the user wants to roll the dice
          puts "Do you want to roll the non-scoring #{dice.num} dices? (y/n)"
          choice = gets.chomp
          if choice.downcase == "y"
            dice.roll
          else
            break
          end
        end
        puts "Player #{player.name} rolls #{dice.rolls}."
        puts "Score in this round: #{dice.sum}"
        puts "Total Score : #{dice.sum + player.total_score}"
      end
      #Add the scores if:
      # => Score is more than 300 on first roll
      # => Score is more than 0 on other rolls
      player.update_score(dice.sum) if 
        (dice.sum > 0 && player.scores.size > 0) || 
        (dice.sum >= 300 && player.scores.size == 0)
      puts
    end
  end
end

class Player
  attr_accessor :scores
  attr_accessor :name
  def initialize(name)
    @name = name
    @scores = []
  end

  def update_score(score)
    @scores << score
  end

  def total_score
    return @scores.inject(0) { |sum, x| sum + x}
  end
end

class DiceSet
  attr_accessor :num
  attr_accessor :sum
  attr_accessor :rolls

  def initialize(num=5)
    @num = 5
    @sum = 0
  end

  def roll
    return false if @num == 0
    @rolls = Array.new(@num)
    @rolls.map! { |e| Random.rand(5) + 1 }
    calculate_score_and_dices
  end

  private
  def calculate_score_and_dices
    counts = Hash.new {0}
    @rolls.each { |chr| counts[chr] += 1 }
    current_roll_total = 0
    total_dices_rolled = 0
    counts.each do |num, count|
      # 1, 1, 1 = 1000
      if num == 1 and count >= 3
        total_dices_rolled += 3
        current_roll_total += 1000
        count -= 3
      end
      # 1 = 100
      if num == 1 and count > 0
        total_dices_rolled += count
        current_roll_total += 100 * count
        count = 0
      end
      # count of any number > 3, then x*100
      if count >= 3
        total_dices_rolled += 3
        current_roll_total += num*100
        count -= 3
      end
      # 5 = 50
      if num == 5 and count > 0
        total_dices_rolled += count
        current_roll_total += 50 * count
        count = 0
      end
    end

    if total_dices_rolled == @num
      @num = 5
    else
      @num -= total_dices_rolled
    end 
    # if the sum for particular roll = 0, make the complete turn sum = 0
    # and nullify the number of dices left
    if current_roll_total == 0
      @num = @sum = 0
    else
      @sum += current_roll_total
    end
  end
end

puts "Enter the number of players"
count_players = gets.chomp
if !(count_players.to_i.to_s == count_players)
  puts "Invalid number of players"
else
  game = Game.new(count_players.to_i)
  game.start_game
end

