require "date"
require "highline"
require "http"
require "json"
require "oga"
require "uri"
require "yaml"

# Check and set the key variables.

if ARGV.length == 1
    config = YAML.load_file(ARGV[0])
    username = config["username"]
    password = config["password"]
    rss_uri = config["rss_uri"]
    source_slug = config["source_slug"]
    destination_id = config["destination_id"]
    public_status = config["public_status"]
    unread_status = config["unread_status"]
elsif ARGV.length == 7
    username = ARGV[0]
    password = ARGV[1]
    rss_uri = ARGV[4]
    source_slug = ARGV[2]
    destination_id = ARGV[3]
    public_status = (ARGV[5] == "true") ? true : false
    unread_status = (ARGV[6] == "true") ? true : false
else
    cli = HighLine.new
    username = cli.ask("Please enter your Instapaper username:") { |q|
        q.responses[:not_valid] = 'Username cannot be blank.'
        q.validate = /^(?!\s*$).+/
    }
    password = cli.ask("Please enter your Instapaper password:") { |q| q.echo = "*" }
    rss_uri = cli.ask("Please enter the URI of the RSS feed:") { |q|
        q.responses[:not_valid] = 'URI most be a valid address beginning with https://.'
        q.validate = /\A#{URI::regexp(['https'])}\z/
    }
    source_slug = cli.ask("Please enter the URI slug of the source folder:") { |q|
        q.responses[:not_valid] = 'URI slug cannot be blank.'
        q.validate = /^(?!\s*$).+/
    }
    destination_id = cli.ask("Please enter the ID of the destination folder (eg. 1234567):", Integer) { |q|
        q.responses[:not_valid] = 'ID must be an integer and must be greater than 0.'
        q.validate = /^[1-9][0-9]*$/
    }
    public_status = cli.agree("Do you want the links to be public?")
    unread_status = cli.agree("Do you want the links to be marked as 'toread'?")
end

# Set up the base URI and slugs.

base_uri = "https://www.instapaper.com"
source_slug = "/" + source_slug unless source_slug[0,1] == "/"
rss_slug = rss_uri.sub(base_uri, '')

# Log in and get the cookies.

response = HTTP.post(base_uri + "/user/login", :form => {:username => username, :password => password, :keep_logged_in => "yes"})
cookie_jar = response.cookies

# Set up a persistent connection.

conn = HTTP.cookies(cookie_jar).encoding("UTF-8").persistent(base_uri)

# Create an empty array to hold all the links.

links = Array.new

loop do
    # Read the RSS feed.

    rss_xml = conn.get(rss_slug).to_s

    # Parse the XML.

    feed = Oga.parse_xml(rss_xml)

    # Extract the URL and date for each item.

    feed.css("item").each do |item|
        link = Hash.new
        link["href"] = item.css("link").text
        link["description"] = item.css("title").text
        link["extended"] = item.css("description").text
        link["time"] =  DateTime.parse(item.css("pubDate").text).strftime("%Y-%m-%dT%H:%M:%SZ")
        link["shared"] = (public_status) ? "yes" : "no"
        link["toread"] = (unread_status) ? "yes" : "no"
        links.push(link)
    end

    # Read the archive page.

    source_html = conn.get(source_slug).to_s

    # Parse the HTML.

    page = Oga.parse_xml(source_html)

    # Extract the ID for each item.

    ids = Array.new
    page.css("div#article_list section.articles article").each do |item|
        id = item.get("data-article-id")
        ids.push(id)
        break if ids.length == 10
    end

    # Move the first 10 links to the destination folder.

    ids.each do |link_id|
        conn.get('/move/' + link_id + '/to/' + destination_id.to_s).flush
    end

    break if ids.length < 10
end

# Close the connection.

conn.close

# Export the links as a JSON file.

File.open("articles.json", "a") do |f|
    f.write(links.to_json)
end
