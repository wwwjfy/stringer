require_relative "../../repositories/story_repository"

class FindNewStories
  STORY_AGE_THRESHOLD_DAYS = 3

  def initialize(raw_feed, feed_id, last_fetched)
    @raw_feed = raw_feed
    @feed_id = feed_id
    @last_fetched = last_fetched
  end

  def new_stories
    stories = []

    @raw_feed.entries.each do |story|
      next if story_age_exceeds_threshold?(story) || StoryRepository.exists?(story.id, @feed_id)
      stories << story
    end

    stories
  end

  private

  def story_age_exceeds_threshold?(story)
    max_age = Time.now - STORY_AGE_THRESHOLD_DAYS.days
    story.published && story.published < max_age
  end
end
