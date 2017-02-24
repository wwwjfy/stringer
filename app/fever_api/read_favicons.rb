require_relative "../repositories/favicon_repository"

module FeverAPI
  class ReadFavicons
    def initialize(options = {})
      @favicon_repository = options.fetch(:favicon_repository) { FaviconRepository }
    end

    def call(params = {})
      if params.keys.include?("favicons")
        { favicons: favicons }
      else
        {}
      end
    end

    private

    def favicons
      @favicon_repository.list.map(&:as_fever_json)
    end
  end
end
