# Paperover

Paperover is a command line Ruby script that allows you to export the metadata for articles saved to Instapaper. The metadata is saved as a JSON file and includes the date that the articles were saved to Instapaper.

## Overview

Instapaper provides a minimal export facility that exports the URI, title and current folder. Separately, Instapaper provides an RSS feed for each folder that includes this metadata as well as the short description of the article and the time and the date that the article was saved to Instapaper. Unfortunately, each RSS feed contains, at most, 10 articles.

Paperover exports a JSON file for the designated folder that contains the following metadata:

* URI;
* title;
* description; and
* date and time saved to Instapaper.

In addition, Paperover allows the user to set for each export whether the links to be exported should be considered public or private and whether they should be marked read or unread.

Paperover works by:

1. logging into your account;
2. downloading the RSS feed for the folder you have specified;
3. exporting the information from this feed;
4. moving the articles in this feed to a destination folder you have specified;
5. repeating steps 2 to 4 until there are no more articles in the source folder.

To run Paperover you need to provide the following information:

* `username`: your Instapaper username;
* `password`: your Instapaper password;
* `rss_uri`: the RSS feed's URI for the folder you are exporting;
* `source_slug`: the path for the folder you are exporting (eg. `archive`);
* `destination_id`: the folder ID you will move the articles to after export (eg. `1234567`);
* `public_status`: whether the articles should be considered public or not;
* `unread_status`: whether the articles should be considered read or not.

*Please note that Paperover's export script is a __destructive__ operation. The articles in the target folder will be __moved__ to the folder you specify.*

## Requirements

Paperover requires [Ruby](http://ruby-lang.org) to be installed on your system.

## Installation

```bash
git clone git://github.com/pyrmont/paperover.git  # Warning: read-only.
cd paperover
bundle install
```

## Running

Once you have set up Paperover, you can run the script as follows.

### No Configuration

If you execute `ruby export.rb` with no arguments, Paperover will prompt you to enter the parameters it needs to log in to your account and back up your bookmarks.

### YAML Configuration

If you execute `ruby export.rb <config.yaml>`, Paperover will read the parameters it needs from the configuration file. An example of the necessary parameters is included in `config.yaml.example`.

### Command Line Configuration

If you execute `ruby export.rb <username> <password> <rss_uri> <source_slug> <destination_id> <public_status> <unread_status>`, Paperover will use the given arguments as its parameters.

## Frequently Asked Questions

**Q. How can I find the `source_slug` parameter?**  
The `source_slug` parameter is the part of the URI after `https://www.instapaper.com/`. For the Archive folder, it is `archive`. For other folders it will look something like `u/folder/<folder_id>/<folder_name>`.

**Q. What can I find the `destination_id` parameter?**  
The `destination_id` parameter is the number that is included in the URI of the folder (see the question above for an example).

**Q. Can I export all of the articles at once?**  
No, Paperover doesn't support exporting from multiple folders at the same time.


## Copyright

Original work is placed in the [public domain](http://creativecommons.org/publicdomain/zero/1.0/).
