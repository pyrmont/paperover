require "http"
require "json"
require "uri"

# Abort if two arguments weren't passed.
abort("Usage: ruby pinboard.rb <articles.json> <user:token>") unless ARGV.length == 2

# Read the file into a Hash.
links = JSON.parse(IO.read(ARGV[0]))

# Set up the authentication token.
token = ARGV[1]
authentication = "auth_token=" + token

# Create persistent connection.
conn = HTTP.persistent("https://api.pinboard.in")

# Save each link to Pinboard.
links.each_with_index do |link, index|
    # Create empty hash.
    arguments = Hash.new

    # Set up the arguments
    arguments["url"] = link["href"]
    arguments["description"] = link["description"]
    arguments["extended"] = link["extended"] unless link["extended"] == ""
    arguments["tags"] = link["tags"].gsub(",", " ") unless link["tags"] == ""
    arguments["dt"] = link["time"]
    arguments["replace"] = "no"
    arguments["shared"] = link["shared"]
    arguments["toread"] = link["toread"]

    # Convert arguments hash to an encoded string.
    argument_string = URI.encode_www_form(arguments)

    # Set up the timeouts.
    default_timeout = 3
    timeout = default_timeout

    loop do
        # Try to save the link to Pinboard.
        response = conn.get("/v1/posts/add/?" + authentication + "&" + argument_string + "&format=json")
        response.flush

        # Break unless the server sent a too many requests server error.
        break unless response.status == 429

        # Back off for an increased timeout and then try again.
        timeout = timeout * 2
        sleep(timeout)
    end

    # Access to the API is rate limited (currently 3 seconds).
    sleep(default_timeout) unless index == 0
end

# Close the connection.
conn.close
