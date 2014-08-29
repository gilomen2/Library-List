-- This comment enforces unit-test coverage for this file:
-- coverage: 0
local http = require 'summit.http'
local json = require 'json'
local menu = require 'summit.menu'
local sms = require 'summit.sms'

channel.answer()

channel.say('Hello. Enter a 5 digit zip code to get a list of nearby public libraries.')
local zip = channel.gather({minDigits="5", maxDigits="5"})

local function get_locations(...)
	local good, err = http.get("http://ziplocate.us/api/v1/" .. zip)
	if not err then
		longitude = tostring(json:decode(good.data).lng)
		latitude = tostring(json:decode(good.data).lat)
	end
	local res, err = http.get("https://maps.googleapis.com/maps/api/place/nearbysearch/json?location="..latitude..","..longitude.."&radius=10000&types=library&key=AIzaSyDUOEwuYy_BhcayifaKzX9Sc6wI4zUxRMM")
	if not err then
		libraries = json:decode(res.data)
	end
	return libraries
end
local function get_sms(location)
	channel.say("Would you like to get this information as a text message? Press 1 for yes or any other number for no.")
	local yes_or_no = channel.gather()
	if yes_or_no == "1" then
		channel.say("Enter your ten digit phone number followed by the pound sign.")
		local caller_number = channel.gather()
		local to = "+1"..caller_number
		local from = "+14145337983"
		local message = location.name.."/n"..location.vicinity
		local ok, err = sms.send(to, message, from)
		if not err then
			channel.say("Great. Check your messages. Goodbye!")
		end
		if err then
			channel.say("I'm sorry. We weren't able to send the message. Goodbye.")
			channel.hangup()
		end
	else
		channel.say("Goodbye!")
	end
end
local function say_location_info(x)
	if x == 1 then
		location = get_locations().results[1]
		channel.say("The closest library is ".. location.name)
		get_sms(location)
	elseif x == 2 then
		location = get_locations().results[2]
		channel.say("The second closest library is ".. location.name)
		get_sms(location)
	else
		location = get_locations().results[3]
		channel.say("The third closest library is ".. location.name)
		get_sms(location)
	end
end

local function invalid_response( ... )
	channel.say("Please press 1, 2, or 3 followed by the pound sign.")
end

local my_menu = menu()
my_menu.add("1", "Press 1 to hear the closest location", 
	function() 
		return say_location_info(1)
	end
)
my_menu.add("2", "Press 2 to hear the second closest location",
	function() 
		return say_location_info(2)
	end
)
my_menu.add("3", "Press 2 to hear the second closest location", 
	function() 
		return say_location_info(3)
	end
)
my_menu.default(invalid_response)

local action = my_menu.run()
action()

channel.hangup()