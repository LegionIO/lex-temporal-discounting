# lex-temporal-discounting

Hyperbolic temporal discounting for LegionIO cognitive agents. Models the preference for immediate rewards over delayed ones using the formula `sv = amount / (1 + k * delay)`.

## What It Does

`lex-temporal-discounting` models how cognitive agents discount the subjective value of future rewards based on delay. Unlike exponential discounting, the hyperbolic model produces stronger discounting of short delays and gentler discounting of long delays — matching observed human behavior. Each reward can have a domain-specific discount rate k.

- **Subjective value**: `amount / (1 + k * delay)` — approaches 0 as delay increases
- **Value ratio**: `subjective_value / amount` — fraction of full value retained at this delay
- **Worth waiting**: value ratio >= configurable threshold (default 0.3)
- **Optimal delay**: maximum tolerable delay before value drops below a minimum threshold
- **Patience report**: distribution of discount rate labels across all tracked rewards
- **Domain rates**: per-domain discount rates for domain-specific impulsivity modeling

## Usage

```ruby
require 'legion/extensions/temporal_discounting'

client = Legion::Extensions::TemporalDiscounting::Client.new

# Create a reward (delay in seconds)
result = client.create_temporal_reward(
  label: 'code_review_approval',
  amount: 1.0,
  delay: 3600,    # 1 hour away
  domain: :engineering,
  discount_rate: 0.05
)
reward_id = result[:reward_id]
# subjective_value: 0.844 (84.4% of full value after 1 hour)

# Compare two rewards
client.compare_temporal_rewards(reward_id_a: reward_id, reward_id_b: other_id)
# => { preferred: 'code_review_approval' }

# Is it worth waiting?
client.check_worth_waiting(reward_id: reward_id, threshold: 0.3)
# => { worth_waiting: true, value_ratio: 0.844 }

# Immediate vs delayed comparison
client.immediate_vs_delayed_comparison(
  domain: :engineering,
  immediate_amount: 0.5,
  delayed_amount: 1.0,
  delay: 7200
)
# => { immediate_sv: 0.5, delayed_sv: 0.735, preferred: :delayed }

# How long can I wait before value drops below 30%?
client.compute_optimal_delay(reward_id: reward_id, min_value: 0.3)
# => { max_delay: 46_666 }  # ~13 hours

# Set domain-level discount rates
client.set_domain_discount_rate(domain: :health, rate: 0.3)  # more impulsive about health
client.set_domain_discount_rate(domain: :career, rate: 0.02) # more patient about career

# Per-tick maintenance (prunes expired rewards)
client.update_temporal_discounting
```

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
