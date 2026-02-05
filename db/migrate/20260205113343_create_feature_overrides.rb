class CreateFeatureOverrides < ActiveRecord::Migration[7.1]
  def change
    create_table :feature_overrides do |t|
      t.references :feature, null: false, foreign_key: true
      t.string  :level, null: false # values: user, group, region
      t.string  :level_key, null: false #values: user_id / group_id / region_code
      t.boolean :enabled, null: false

      t.timestamps
    end
    add_index :feature_overrides,
              [:feature_id, :level, :level_key],
              unique: true,
              name: "index_feature_overrides_on_feature_and_level"
  end
end
