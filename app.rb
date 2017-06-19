# We are using the Sinatra Web Framework
require 'sinatra'
require 'json'
# We're using a .env file to load our
# environment variables. Make sure to
# create a .env file for yourself with
# your numbers and domain.
require 'dotenv/load'

# Map our inbound numbers to different cities.
# In a production system this would most likely
# be queried from your database.
locations = {
  ENV['INBOUND_NUMBER_1'] => 'Chicago',
  ENV['INBOUND_NUMBER_2'] => 'San Francisco',
}

# The current statuses for the transport in the
# different cities.
# In a production system this would most likely
# be queried from your database.
statuses = {
  'Chicago'       => 'There are minor delays on the L Line. There are no further delays.',
  'San Francisco' => 'There are currently no delays',
  'Austin'        => 'There are currently no delays'
}

# This endpoint is called when the call first connects
get '/answer' do
  # We map the number dialled to a location
  location = locations[params['to']]
  # We map the location to the current status
  status = statuses[location]
  # respond to the user
  respond_with(location, status)
end

# This endpoint is called when the user has typed
# a number on their phone to choose a city
post '/city' do
  # We parse the JSON in the request body
  body = JSON.parse(request.body.read)
  # We extract the user's selection, and turn it into a number
  selection = body['dtmf'].to_i
  # Finally, we select the status and city name from the list
  location = statuses.keys[selection-1]
  status = statuses[location]
  # respond to the user
  respond_with(location, status)
end

# This method is shared between both endpoints to play
# back the status and then ask for more input
def respond_with(location, status)
  content_type :json
  return [
    # A friendly localized welcome message
    {
      'action': 'talk',
      'text': "Current status for the #{location} Transport Authority:"
    },
    # The current transport status for this city
    {
      'action': 'talk',
      'text': status
    },
    # Next, we give the user the option to get the details for other cities as well
    {
      'action': 'talk',
      'text': 'For more info, press 1 for Chicago, 2 for San Francisco, and 3 for Austin. Or hang up to end your call.',
      'bargeIn': true
    },
    # Listen to a user's input play back that city's status
    {
      'action': 'input',
      'eventUrl': ["#{ENV['DOMAIN']}/city"],
      # we give the user a bit more time before we hang up on them
      'timeOut': 10,
      # we only expect one digit
      'maxDigits': 1
    }
  ].to_json
end
