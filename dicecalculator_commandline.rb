## Edge of the Empire Dice Probability Calculator.
# Calculate the Probability of a given dice set
# - Nik Aleliunas

#Dice symbol key: (S)uccess, (A)dvantage, (F)ailure), (T)hreat, t(R)iumph, (D)espair
boost = [ nil, nil, 'S', 'SA', 'AA', 'A']
setback = [ nil, nil, 'F', 'F', 'T', 'T']
ability = [ nil, 'S', 'S', 'SS', 'A', 'A', 'SA', 'AA']
difficulty = [ nil, 'F', 'FF', 'T', 'T', 'T', 'TT', 'FT']
proficiency = [ nil, 'S', 'S', 'SS', 'SS', 'A', 'SA', 'SA', 'SA', 'AA', 'AA', 'SR']
challenge = [ nil, 'F', 'F', 'FF', 'FF', 'T', 'T', 'FT', 'FT', 'TT', 'TT', 'FD']
simplified = false #Simplified output true or false
combinations = false
dice_string = nil

while(ARGV.length > 0)
    if (ARGV[0][0] == '-')
        if(ARGV[0][1] == 'S')
            simplified = true
            ARGV.shift
        elsif(ARGV[0][1] == 'C')
            combinations = true
            ARGV.shift
        end
    else
        dice_string = ARGV.shift
    end
end

if(dice_string == nil)
    puts "Dice Pool: (Use the first letter to signify a die: B,S,A,D,P or C.)"
    STDOUT.flush
    dice_string = gets.chomp
end


#count the number of each type of die input
boost_num       = dice_string.count 'B'
setback_num     = dice_string.count 'S'
ability_num     = dice_string.count 'A'
difficulty_num  = dice_string.count 'D'
proficiency_num = dice_string.count 'P'
challenge_num   = dice_string.count 'C'

#Create the number of possibilities. (sides on die)^(# of dice)
possibilities_max = 6**(boost_num+setback_num) * 8**(ability_num+difficulty_num) * 12**(proficiency_num+challenge_num)

if (possibilities_max <= 1)
    p "No Dice."
    exit
end

#calculate the maximum range of success/failure & advantage/threat. Most die have a side with 2 of each symbol, except advantage and setback die. (Failures/Threats will be counted at negative indecies. Look up Ruby's use of negative indicies, boyo. It's pretty rad.) t(R)iumph and (D)espair are only counted for their successes.
success_max = boost_num + 2*(ability_num + proficiency_num)
advantage_max =  2*(boost_num + ability_num + proficiency_num)

failure_max = setback_num + 2*(difficulty_num + challenge_num)
threat_max = setback_num + 2*(difficulty_num + challenge_num)

puts "Max Success: #{success_max}, Max Advantage: #{advantage_max}"

puts "Max Failure: #{failure_max}, Max Threat: #{threat_max}"
#create a result grid off those ranges.
result_grid = Array.new(success_max + failure_max + 1) {Array.new(advantage_max + threat_max + 1,0.0)}

#create die grid
die_grid = []

#populate die grid with the input dice
boost_num.times       do die_grid << boost       end
setback_num.times     do die_grid << setback     end
ability_num.times     do die_grid << ability     end
difficulty_num.times  do die_grid << difficulty  end
proficiency_num.times do die_grid << proficiency end
challenge_num.times   do die_grid << challenge   end


#iterate through all possible combonations of dice in grid, add them to the result grid
die_grid.shift.product(*die_grid) do |combi|
    combi = combi.join
    if (combinations == true) then p combi end
    success_count = (combi.count 'S') - (combi.count 'F')
    advantage_count = (combi.count 'A') - (combi.count 'T')
    result_grid[success_count][advantage_count] +=1
end

#create percentile pools for success rate, advantage rate and threat rate
die_pool_success = 0.0
die_pool_advantage = 0.0
die_pool_threat = 0.0
puts "\n++++RESULTS for Dice Pool: #{dice_string}++++\n"
if(simplified == false) then puts "------------" end
#Success
for i in 0..success_max
    #Advantage
    for j in 0..advantage_max
        # Only show the results if there is a chance of it happening.
        if (result_grid[i][j] != 0)
            # Make the result into a percentage
            result_grid[i][j] = (result_grid[i][j]/possibilities_max)*100
            
            #if there is success, then add this percent to the growing success die percentage.
            if(i != 0) then die_pool_success += result_grid[i][j] end
            #likewise for advantage
            if(j != 0) then die_pool_advantage += result_grid[i][j] end
            #print the result
            if(simplified == false) then puts "#{i} Success & #{j} Advantage: #{result_grid[i][j].round(2)}%" end
        end
    end
    #Threat
    for j in (advantage_max+threat_max).downto(advantage_max+1)
        if (result_grid[i][j] != 0)
            result_grid[i][j] = (result_grid[i][j]/possibilities_max)*100
            if(i != 0) then die_pool_success += result_grid[i][j] end
            #see Success and Advantage
            if(j != 0) then die_pool_threat += result_grid[i][j] end
            if(simplified == false) then puts "#{i} Success & #{threat_max +advantage_max + 1 - j} Threat: #{result_grid[i][j].round(2)}%" end
        end
    end
    if(simplified == false) then puts"------------" end
end

#Failure
for i in (success_max + failure_max).downto(success_max+1)
    #Advantage
    for j in 0..advantage_max
        if (result_grid[i][j] != 0)
            result_grid[i][j] = (result_grid[i][j]/possibilities_max)*100
            #See Success and Advantage
            if(j != 0) then die_pool_advantage += result_grid[i][j] end
            if(simplified == false) then puts "#{((success_max + failure_max + 1) - i)} Failure & #{j} Advantage: #{result_grid[i][j].round(2)}%" end
        end
    end
    #Threat
    for j in (advantage_max+threat_max).downto(advantage_max+1)
        if (result_grid[i][j] != 0)
            result_grid[i][j] = (result_grid[i][j]/possibilities_max)*100
            if(j != 0) then die_pool_threat += result_grid[i][j] end
            if(simplified == false) then puts "#{(failure_max + success_max + 1) - i} Failure & #{threat_max +advantage_max + 1 - j} Threat: #{result_grid[i][j].round(2)}%" end
        end
    end
    if(simplified == false) then puts"------------" end
end

puts "Total Chance of Success: #{die_pool_success}"
puts "Total Chance of Advantage: #{die_pool_advantage}"
puts "Total Chance of Threat: #{die_pool_threat}"
puts"+++++++++++++++"
