# app/services/feature_flags/feature_policy.rb
module FeatureFlags
  class FeaturePolicy
    class FeatureNotFound < StandardError; end

    PRECEDENCE = %i[user group region].freeze

    def initialize(feature_key:, user_id: nil, group_id: nil, region: nil)
      @feature_key = feature_key
      @context = {
        user: user_id,
        group: group_id,
        region: region
      }.compact
    end

    def enabled?
      feature = Feature.find_by(key: @feature_key)
      raise FeatureNotFound, "Feature #{@feature_key} not found" unless feature

      override = resolve_override(feature)
      override ? override.enabled : feature.default_enabled
    end

    private

    def resolve_override(feature)
      PRECEDENCE.each do |level|
        key = @context[level]
        next unless key

        override = fetch_override(feature, level, key)
        return override if override
      end

      nil
    end

    def fetch_override(feature, level, key)
      FeatureOverride.find_by(
        feature: feature,
        level: level.to_s,
        level_key: key.to_s
      )
    end
  end
end
