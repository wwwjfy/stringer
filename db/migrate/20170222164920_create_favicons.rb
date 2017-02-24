class CreateFavicons < ActiveRecord::Migration
  def up
    create_table :favicons do |t|
      t.text :data
    end
    add_column :feeds, :favicon_id, :integer
  end

  def down
    drop_table :favicons
    remove_column :feeds, :favicon_id
  end
end
