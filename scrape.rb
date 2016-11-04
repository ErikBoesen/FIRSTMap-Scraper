require 'tba'
require 'pathname'
require 'json'
require 'hl-geocoder'

tba = TBA.new('erikboesen:firstmap_scraper:v0.1')

geo = Geocoder.new(File.read('key.txt'))


puts 'Reminder: if you think team data may have changed since last time you ran this script, make sure there\'s nothing in the data folder.'

if Pathname('data/teams.json').exist?
    teams = JSON.parse(File.read('data/teams.json'))
else
    teams = []
end

# Start off the loop on the first page of teams.
page_num = 0

unless teams.length > 0
    # Continuously fetch the next page of teams. Loop will be broken if the current page doesn't have anything on it.
    loop do
        page = tba.get_teams(page_num)
        # If there is data on the page (pages correlating to team numbers that don't exist will yield an empty array)
        if page.length > 0
            # For every team in the array from TBA
        	page.each do |team|
                # Add the team's number to the teams array
        		teams.push(team['team_number'])
        	end
            # Give confirmation
            puts "Parsed team list page #{page_num}."
            # Increase the number of pages parsed by one.
        	page_num += 1
        else
            # If the page return is empty, break the loop since all teams have been fetched.

            # Get the current year
            yr = Time.new.year;

            # Go through the whole list and remove any team that isn't active anymore
            teams.to_enum.with_index.reverse_each do |num, i|
                # Get a list of years the team was active.
                team_years = tba.get_team_years(num)

                puts "Checking team #{teams[i]}...";
                puts "The last year team #{teams[i]} was active was #{team_years.last}."
                # If there is a list of teams (sometimes the list is returned empty),
                # and the most recent year they participated is before this year...
                if team_years.length > 0 && team_years.last < yr
                    # Take it out of the list.
                    puts "#{teams[i]} is no longer active, removing."
                    teams.delete(i)
                end
            end

            # Once everything's done, store the cleaned team list.
            File.write('data/teams.json', JSON.generate(teams))
            break
        end
    end
end

puts "#{teams.length} active teams found."

if Pathname('data/locations.json').exist?
    puts 'Team locations have been fetched already.'
    locations = JSON.parse(File.read('data/locations.json'))
else
    locations = []
    puts 'Preparing to fetch their locations. This may take a while...'
end

unless locations.length > 0
    teams.each_with_index do |team, i|
        locations.push(tba.get_team(team)['location'])
        if locations[i]
            puts "Team #{team} is from #{locations[i]}."
        else
            puts "Team #{team} has no location specified and will be ignored."
        end
    end
end

pages_needed = (locations.length / 100).ceil

coordinates = []
first_page = 0

pages_needed.times do |i|
    if Pathname("data/coordinates/#{i}.json").exist?
        puts "Page #{i} of coordinates has been fetched already."
        coordinates += JSON.parse(File.read("data/coordinates/#{i}.json"))
        first_page += 1
    end
end

for i in (first_page * 100)..locations.length
    if locations[i]
        coordinates[i] = geo.geocode(locations[i])
    else
        coordinates[i] = nil
    end

    if i % 100 == 0
        File.write("data/coordinates/#{(i - 100) / 100}.json", coordinates[(i - 100)..i])
    end
end

puts 'Here\'s all the coordinates.'
puts coordinates.to_s