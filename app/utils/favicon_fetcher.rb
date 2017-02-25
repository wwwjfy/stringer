require "base64"
require "uri"
require "nokogiri"
require "open-uri"
require_relative "../models/favicon"

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
  return
end

class FaviconFetcher
  def self.fetch_favicon(url)
    doc = Nokogiri::HTML(open(URI.escape(url)))
    favicon_url = get_favicon(url, doc.xpath('/html/head/link[@rel="shortcut icon" or @rel="icon"]'))
    data = nil
    if !favicon_url.nil?
      data = "image/gif;base64," + Base64.strict_encode64(open(favicon_url).read)
      Favicon.create(data: data)
    else
      Favicon.create()
    end
  end
end
