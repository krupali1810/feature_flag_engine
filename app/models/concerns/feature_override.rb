class FeatureOverride < ApplicationRecord
  belongs_to :feature

  # Region is included for Phase 2 extensibility.
  LEVELS = %w[user group region].freeze

  validates :level,
            presence: true,
            inclusion: { in: LEVELS }
  validates :level_key, presence: true
  validates :enabled,
            inclusion: { in: [true, false] }

  # Ensures a single override per feature per scope
  validates :feature_id,
            uniqueness: {
              scope: [:level, :level_key],
              message: "override already exists for this feature"
            }
end
