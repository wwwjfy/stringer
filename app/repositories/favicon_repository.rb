require_relative "../models/favicon"

class FaviconRepository
  def self.list
    Favicon.order("id")
  end
end
