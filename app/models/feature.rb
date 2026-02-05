class Feature < ApplicationRecord
  has_many :feature_overrides, dependent: :destroy

  validates :key, presence: true, uniqueness: true
  validates :default_enabled, inclusion: { in: [true, false] }
end
