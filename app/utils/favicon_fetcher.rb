require "base64"
require "uri"
require "nokogiri"
require "open-uri"
require_relative "../models/favicon"
require "pry"

def get_favicon(url, entries)
  entries.each do |entry|
    if entry["href"]
      if entry["href"].start_with? "http"
        return entry["href"]
      else
        url = URI.parse(url)
        url.path = "/"
        url.query = ""
        url.fragment = ""
        url += entry["href"]
        return url.to_s
      end
    end
  end
end

class FaviconFetcher
  def self.fetch_favicon(url)
    doc = Nokogiri::HTML(open(url))
    favicon_url = get_favicon(url, doc.xpath('/html/head/link[@rel="shortcut icon" or @rel="icon"]'))
    data = nil
    if favicon_url
      data = "image/gif;base64," + Base64.strict_encode64(open(favicon_url).string)
    end
    Favicon.create(data: data)
  end
end
