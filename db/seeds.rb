# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
puts "Seeding feature flags..."

# Clear existing data (safe for local/testing)
FeatureOverride.delete_all
Feature.delete_all

# ---- Features ----
checkout = Feature.create!(
  key: "event_tracking",
  default_enabled: false,
  description: "Tracks user interaction events for analytics"
)

search = Feature.create!(
  key: "enhanced_search",
  default_enabled: true,
  description: "Improved search ranking"
)

# ---- Overrides ----
FeatureOverride.create!(
  feature: checkout,
  level: "user",
  level_key: "1",
  enabled: true
)

FeatureOverride.create!(
  feature: checkout,
  level: "group",
  level_key: "beta",
  enabled: true
)

FeatureOverride.create!(
  feature: search,
  level: "region",
  level_key: "IN",
  enabled: false
)

puts "Seeding completed..."
