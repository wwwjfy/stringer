class Favicon < ActiveRecord::Base
  has_many :feeds

  def as_fever_json
    {
      id: id,
      data: data
    }
  end
end
