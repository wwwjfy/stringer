require "feedjira"

require_relative "../repositories/story_repository"
require_relative "../repositories/feed_repository"
require_relative "../commands/feeds/find_new_stories"
require_relative "../utils/favicon_fetcher"

class FetchFeed
  def initialize(feed, parser: Feedjira::Feed, logger: nil)
    @feed = feed
    @parser = parser
    @logger = logger
  end

  def fetch
    raw_feed = fetch_raw_feed

    if raw_feed == 304
      feed_not_modified
    else
      feed_modified(raw_feed)
    end

    FeedRepository.set_status(:green, @feed)
  rescue => ex
    FeedRepository.set_status(:red, @feed)

    @logger.error "Something went wrong when parsing #{@feed.url}: #{ex}" if @logger
    @logger.error ex.backtrace if @logger
  end

  private

  def fetch_raw_feed
    @parser.fetch_and_parse(@feed.url)
  end

  def feed_not_modified
    @logger.info "#{@feed.url} has not been modified since last fetch" if @logger
  end

  def feed_modified(raw_feed)
    new_entries = new_entries_from(raw_feed)
    new_entries.each do |entry|
      StoryRepository.add(entry, @feed)
    end
    if @feed.favicon_id.nil? && new_entries.length > 0
      @feed.favicon_id = FaviconFetcher.fetch_favicon(new_entries[0].url).id
    end

    FeedRepository.update_last_fetched(@feed, raw_feed.last_modified)
  end

  def new_entries_from(raw_feed)
    finder = FindNewStories.new(raw_feed, @feed.id, @feed.last_fetched, latest_entry_id)
    finder.new_stories
  end

  def latest_entry_id
    return @feed.stories.first.entry_id unless @feed.stories.empty?
  end
end
