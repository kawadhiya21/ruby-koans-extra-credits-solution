class Game
	def initialize(num_of_players)
		@players = Array.new(num_of_players)
		@players.each_with_index { |val, index|
			puts "Enter player #{index+1}'s name"
			name = gets.chomp.capitalize
			@players[index] = Player.new(name)
		}
	end

	def play
		i = 1
		# AND whether each player's score is less than 3000. Else move to final round
		while @players.inject(true) { |game, player| (game && (player.totalScore < 3000))}
			puts "Turn #{i}"
			puts "--------"
			i += 1
			game
		end

		20.times { |n| print "-" }
		print "Final TURN Alert !!!!"
		20.times { |n| print "-" }
		puts
		# one last time
		game

		puts "Finale scores"
		@players.sort! do |p1, p2|
			case
			when p1.totalScore > p2.totalScore
				-1
			when p1.totalScore <= p2.totalScore
				1
			end
		end
					
		@players.each { |player| puts "Player #{player.name} : #{player.totalScore}" }
	end

	def game
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
				puts "Total Score : #{dice.sum + player.totalScore}"
			end
			#Add the scores if:
			# => Score is more than 300 on first roll
			# => Score is more than 0 on other rolls
			player.updateScore(dice.sum) if (dice.sum > 0 && player.scores.size > 0) || (dice.sum >= 300 && player.scores.size == 0)
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
		@final_turn = false
	end

	def updateScore(score)
		@scores << score
	end

	def totalScore
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
		score
	end

	private
	def score
		counts = Hash.new {0}
		@rolls.each { |chr| counts[chr] += 1 }
		sum = 0
		temp_count = 0
		# Rules
		# Three 1's => 1000 points
  		# Three 6's =>  600 points
  		# Three 5's =>  500 points
  		# Three 4's =>  400 points
  		# Three 3's =>  300 points
  		# Three 2's =>  200 points
  		# One   1   =>  100 points
  		# One   5   =>   50 points
		counts.each do |num, count|
			# 1, 1, 1 = 1000
		    if num == 1 and count >= 3
		    	temp_count += 3
		        sum += 1000
		        count -= 3
		    end

		    # 1 = 100
		    if num == 1 and count > 0
		        temp_count += count
		        sum += 100 * count
		        count = 0
		    end

		    # count of any number > 3, then x*100
		    if count >= 3
		        temp_count += 3
		        sum += num*100
		        count -= 3
		    end

		    # 5 = 50
		    if num == 5 and count > 0
		        temp_count += count
		        sum += 50 * count
		        count = 0
		    end
	    end

	    @num = temp_count

	    # if the sum for particular roll = 0, make the complete turn sum = 0
	    # and nullify the number of dices left
	    if sum == 0
	    	@num = 0
	    	@sum = 0
	    else
	    	@sum += sum
	    end

	    # total sum for the turn and number of valid dices left
	    return @sum, @num
	end
end

puts "Enter the number of players"
count_players = gets.chomp
if !(count_players.to_i.to_s == count_players)
	puts "Invalid number of players" 
else
	game = Game.new(count_players.to_i)
	game.play
end

