require_relative "./feed"

class Story < ActiveRecord::Base
  belongs_to :feed

  validates_uniqueness_of :permalink, :scope => :feed_id

  UNTITLED = "[untitled]"

  def headline
    self.title.nil? ? UNTITLED : self.title[0, 50]
  end

  def lead
    Loofah.fragment(self.body).text[0,100]
  end

  def source
    self.feed.name
  end

  def pretty_date
    I18n.l(self.published)
  end

  def as_json(options = {})
    super(methods: [:headline, :lead, :source, :pretty_date])
  end

  def as_fever_json
    {
      id: self.id,
      feed_id: self.feed.id,
      title: headline,
      author: source,
      html: body,
      url: self.permalink,
      is_saved: 0,
      is_read: self.is_read ? 1 : 0,
      created_on_time: self.published.to_i
    }
  end
end