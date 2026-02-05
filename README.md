# Feature Flag Engine (Rails API)

A database-backed feature flag engine that supports global defaults and scoped overrides (user, group, region) with predictable runtime evaluation.

---

## Tech Stack

- Ruby 3.x
- Rails 7.x (API-only)
- PostgreSQL
- RSpec
- SimpleCov (test coverage)

---

## Setup Instructions

### Prerequisites

Ensure the following are installed and running locally:

- Ruby 3.x
- PostgreSQL
- Bundler

---

### Clone the repository

```
git clone <your-repo-url>
cd feature-flag-engine
```

---

### Install dependencies

```
bundle install
```

---

### Database setup

```
rails db:create
rails db:migrate
rails db:seed
```

The seed file creates sample feature flags and overrides used for testing and demonstration.

---

## Seeded Sample Data

### event_tracking
- Default: disabled
- User override: enabled for user `1`
- Group override: enabled for group `beta`

### enhanced_search
- Default: enabled
- Region override: disabled for region `IN`

---

## Manual Testing (Rails Console)

```
rails console
```

### User override

```
FeatureFlags::FeaturePolicy.new(
  feature_key: "event_tracking",
  user_id: 1,
  group_id: "beta"
).enabled?
```

Expected result:
```
true
```

---

### Group override

```
FeatureFlags::FeaturePolicy.new(
  feature_key: "event_tracking",
  group_id: "beta"
).enabled?
```

Expected result:
```
true
```

---

### Region override

```
FeatureFlags::FeaturePolicy.new(
  feature_key: "enhanced_search",
  region: "IN"
).enabled?
```

Expected result:
```
false
```

---

### Global default fallback

```
FeatureFlags::FeaturePolicy.new(
  feature_key: "enhanced_search"
).enabled?
```

Expected result:
```
true
```

---

## Running Automated Tests

```
bundle exec rspec
```

---

## Test Coverage

```
bundle exec rspec
open coverage/index.html
```

Expected coverage: **~85–90%**

---

## Design Notes

- Core logic is encapsulated in `FeatureFlags::FeaturePolicy`
- No business logic in controllers or views
- Single overrides table for simplicity and predictability