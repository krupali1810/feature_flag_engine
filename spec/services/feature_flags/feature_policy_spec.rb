require "rails_helper"

RSpec.describe FeatureFlags::FeaturePolicy do
  describe "#enabled?" do
    let!(:feature) do
      Feature.create!(
        key: "event_tracking",
        default_enabled: false,
        description: "Tracks user events"
      )
    end

    context "when feature does not exist" do
      it "raises FeatureNotFound error" do
        policy = described_class.new(feature_key: "unknown_feature")

        expect { policy.enabled? }
          .to raise_error(FeatureFlags::FeaturePolicy::FeatureNotFound)
      end
    end

    context "when no overrides exist" do
      it "falls back to the global default" do
        policy = described_class.new(feature_key: "event_tracking")

        expect(policy.enabled?).to eq(false)
      end
    end

    context "with a user-level override" do
      before do
        FeatureOverride.create!(
          feature: feature,
          level: "user",
          level_key: "1",
          enabled: true
        )
      end

      it "returns the user override value" do
        policy = described_class.new(
          feature_key: "event_tracking",
          user_id: 1
        )

        expect(policy.enabled?).to eq(true)
      end
    end

    context "with group and user overrides" do
      before do
        FeatureOverride.create!(
          feature: feature,
          level: "group",
          level_key: "beta",
          enabled: false
        )

        FeatureOverride.create!(
          feature: feature,
          level: "user",
          level_key: "1",
          enabled: true
        )
      end

      it "prefers user override over group override" do
        policy = described_class.new(
          feature_key: "event_tracking",
          user_id: 1,
          group_id: "beta"
        )

        expect(policy.enabled?).to eq(true)
      end
    end

    context "with group override only" do
      before do
        FeatureOverride.create!(
          feature: feature,
          level: "group",
          level_key: "beta",
          enabled: true
        )
      end

      it "uses the group override" do
        policy = described_class.new(
          feature_key: "event_tracking",
          group_id: "beta"
        )

        expect(policy.enabled?).to eq(true)
      end
    end

    context "with region override" do
      let!(:search_feature) do
        Feature.create!(
          key: "enhanced_search",
          default_enabled: true,
          description: "Improved search relevance"
        )
      end

      before do
        FeatureOverride.create!(
          feature: search_feature,
          level: "region",
          level_key: "IN",
          enabled: false
        )
      end

      it "uses region override when no higher precedence exists" do
        policy = described_class.new(
          feature_key: "enhanced_search",
          region: "IN"
        )

        expect(policy.enabled?).to eq(false)
      end
    end

    context "when multiple overrides exist" do
      before do
        FeatureOverride.create!(
          feature: feature,
          level: "region",
          level_key: "IN",
          enabled: false
        )

        FeatureOverride.create!(
          feature: feature,
          level: "group",
          level_key: "beta",
          enabled: false
        )

        FeatureOverride.create!(
          feature: feature,
          level: "user",
          level_key: "1",
          enabled: true
        )
      end

      it "applies precedence user → group → region → default" do
        policy = described_class.new(
          feature_key: "event_tracking",
          user_id: 1,
          group_id: "beta",
          region: "IN"
        )

        expect(policy.enabled?).to eq(true)
      end
    end
  end
end
