require 'tba'
require 'geocode'

tba = TBA.new('erikboesen:firstmap_scraper:v0.1')
geo = Geocode.new_geocoder :google, {:google_api_key => 'abcd1234_SAMPLE_GOOGLE_API_KEY_etc'}

# Define empty array of teams. This will be filled in the loop below with all the valid team numbers.
teams = []
# Start off the loop on the first page of teams.
page_num = 0


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
        puts "Page #{page_num} of teams exists and has been parsed."
        # Increase the number of pages parsed by one.
    	page_num += 1
    else
        # If the page return is empty, break the loop since all teams have been fetched.
        puts "Page #{pages} is empty. We're done here. Moving on to location fetching."
        break
    end
end

# Output list of teams
puts 'Teams gathered: ' + teams


locations = []
puts 'Initializing fetching of every team\'s location. This will take a while.'

teams.each_with_index do |team, i|
    locations.push(tba.get_team(team)['location'])
end

puts locations

coordinates = []

locations.each_with_index do |loc, i|
    if locations[i]
        #coordinates[i] = (geo.geocode loc).results[0].geometry.location
        puts (geo.geocode loc)
        #puts coordinates[i]
        #puts i + '/' + max
    else
        coordinates.push(null)
    end
end

puts 'Here\'s all the coordinates.'
puts coordinates.to_s