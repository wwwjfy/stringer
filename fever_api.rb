require "sinatra/base"
require "sinatra/activerecord"

require_relative "app/models/story"
require_relative "app/models/feed"

class FeverAPI < Sinatra::Base
  configure do
    set :database_file, "config/database.yml"

    register Sinatra::ActiveRecordExtension
    ActiveRecord::Base.include_root_in_json = false
  end

  # !! TODO: Need to check auth !!

  get "/" do
    content_type :json
    get_response(params)
  end

  post "/" do
    content_type :json
    get_response(params)
  end

  def get_response(params)
    response = {}
    response[:api_version] = 3
    response[:auth] = 1
    response[:last_refreshed_on_time] = Time.now.to_i

    keys = params.keys.map{|k| k.to_sym}

    if keys.include?(:groups)
      response[:groups] = groups
      response[:feeds_groups] = feeds_groups
    end

    if keys.include?(:feeds)
      response[:feeds] = Feed.all.map{|f| f.as_fever_json}
      response[:feeds_groups] = feeds_groups
    end

    if keys.include?(:favicons)
      response[:favicons] = []
    end

    if keys.include?(:items)
      response[:items] = Story.last(10).map{|s| s.as_fever_json}
      response[:total_items] = 10
    end

    if keys.include?(:links)
      response[:links] = []
    end

    if keys.include?(:unread_item_ids)
      response[:unread_item_ids] = Story.last(10).map{|s| s.id}
    end

    if keys.include?(:saved_item_ids)
      response[:saved_item_ids] = []
    end

    response.to_json
  end

  def groups
    [
      {
        group_id: 1, 
        title: "All items"
      }
    ]
  end

  def feeds_groups
    [
      {
        group_id: 1,
        feed_ids: Feed.all.map{|f| f.id}.join(",")
      }
    ]
  end
end