from TBAPythonAPI import *
import geocoder
from tqdm import tqdm

current_year = 2017

TBA = TBAParser(1418, "FIRST_MAP_DATA_GENERATOR", "0.1.1")

events = TBA.get_event_list(current_year)

j_regionals = 'var regionals = [\n'
j_districts = 'var districts = [\n'

print('Compiling Competition JS...\n')

try:
    for event in tqdm(events):

        if event.venue_address.startswith("TBD"):
            event_location = [0,0]

            if str(event.event_district) == "0" or str(event.event_district) == "10":
                event_location = geocoder.google('Tel Aviv').latlng

                if not len(event_location) == 2:
                    event_location = geocoder.yahoo('Tel Aviv').latlng

                if not len(event_location) == 2:
                    event_location = geocoder.arcgis('Tel Aviv').latlng

        else:
            event_location = geocoder.google(event.venue_address.replace("\n", " ")).latlng

            if not len(event_location) == 2:
                event_location = geocoder.yahoo(event.venue_address).latlng

            if not len(event_location) == 2:
                event_location = geocoder.arcgis(event.venue_address).latlng


        if str(event.event_type) == "0":
            event_js = "\n  [\"" + event.name + "\", {lat:" + str(event_location[0]) + ", lng:" + str(event_location[1]) + "}, " + str(int(event.week) + 1) + ", \"" + str(event.key) + "\", \"" + event.start_date + " - " + event.end_date + "\"],"
            j_regionals += event_js

        elif str(event.event_type) == "1" or str(event.event_type) == "2":
            district_abreviation = ""
            err = None

            if str(event.event_district) == "1":
                district_abreviation = "FIM District"
            elif str(event.event_district) == "2":
                district_abreviation = "MAR District"
            elif str(event.event_district) == "3":
                district_abreviation = "NE District"
            elif str(event.event_district) == "4":
                district_abreviation = "PNW District"
            elif str(event.event_district) == "5":
                district_abreviation = "IN District"
            elif str(event.event_district) == "6":
                district_abreviation = "CHS District"
            elif str(event.event_district) == "7":
                district_abreviation = "NC District"
            elif str(event.event_district) == "8":
                district_abreviation = "PCH District"
            elif str(event.event_district) == "9":
                district_abreviation = "ONT District"
            elif str(event.event_district) == "10" or str(event.event_district) == "0":
                district_abreviation = "ISR District"
            else:
                err = 'NotNone'
                print("ERRRRRRORRRR " + str(event.event_district) + " : " + event.name)

            if err == None:
                event_js = "\n  [\"" + district_abreviation + "\", \"" + event.name + "\", {lat:" + str(event_location[0]) + ", lng:" + str(event_location[1]) + "}, " + str(int(event.week) + 1) + ", \"" + str(event.key) + "\", \"" + event.start_date + " - " + event.end_date + "\"],"
                j_districts += event_js

        else:
            pass

    j_regionals = j_regionals[:-1]
    j_districts = j_districts[:-1]

    j_regionals += '\n]'
    j_districts += '\n]'

    competition_js = j_regionals + '\n\n\n' + j_districts;

    text_file = open("competitions.js", "w")
    text_file.write(competition_js)
    text_file.close()

    print('\nCompetition Data written to "/competition.js"\n')
except Exception as e:
    if e is KeyboardInterrupt:
        raise KeyboardInterrupt
    else:
        print('Location Error Likely Running Hot.  Try again in a few minutes, or contact the adminstrator of this code.\n\n')

teams = TBA.get_team_list()

print('\nCompiling Team Info JS...\n')

team_num_js = ''
coordinates_js = ''

try:
    for team in tqdm(teams):
        team_number = team.team_number
        location = team.location

        try:
            team_location = geocoder.google(location).latlng

            if not len(team_location) == 2:
                team_location = geocoder.yahoo(location).latlng

            if not len(team_location) == 2:
                team_location = geocoder.arcgis(location).latlng

            team_location_str = ',{lat:' + str(team_location[0]) + ',lng:' + str(team_location[1]) + '}'

            # write team_number to team_js array
            team_num_js += ',' + str(team_number)

            coordinates_js += team_location_str
        except:
            pass

    team_num_js = 'var teams=[' + team_num_js[1:] + ']'
    coordinates_js = ', coordinates=[' + coordinates_js[1:] + ']'

    team_js = team_num_js + coordinates_js

    team_file = open("data.js", "w")
    team_file.write(team_js)
    team_file.close()


    print('\nTeam Data written to "/data.js"\n\n')
except Exception as e:
    if e is KeyboardInterrupt:
        raise KeyboardInterrupt
    else:
        pass
