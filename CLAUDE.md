# lex-temporal-discounting

**Level 3 Leaf Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`
- **Gem**: `lex-temporal-discounting`
- **Version**: `0.1.0`
- **Namespace**: `Legion::Extensions::TemporalDiscounting`

## Purpose

Models hyperbolic temporal discounting — the cognitive tendency to prefer immediate rewards over delayed ones, with diminishing marginal discounting at longer delays (unlike exponential discounting). Each reward has an amount, a delay, and a domain-specific discount rate. The subjective value formula is `sv = amount / (1 + k * delay)`. Supports comparison of rewards, patience profiling, and optimal delay calculation.

## Gem Info

- **Gem name**: `lex-temporal-discounting`
- **License**: MIT
- **Ruby**: >= 3.4
- **No runtime dependencies** beyond the Legion framework

## File Structure

```
lib/legion/extensions/temporal_discounting/
  version.rb                               # VERSION = '0.1.0'
  helpers/
    constants.rb                           # rates, limits, labels — defined directly in module (not Constants submodule)
    reward.rb                              # Reward class — single reward with hyperbolic discounting
    discounting_engine.rb                  # DiscountingEngine class — reward store with comparison and patience analysis
  runners/
    temporal_discounting.rb                # Runners::TemporalDiscounting module — all public runner methods
  client.rb                                # Client class including Runners::TemporalDiscounting
```

## Key Constants

Note: constants are defined directly in the `Legion::Extensions::TemporalDiscounting` module namespace (not a nested `Constants` module).

| Constant | Value | Purpose |
|---|---|---|
| `DEFAULT_DISCOUNT_RATE` | 0.1 | Default k value for hyperbolic discounting |
| `MIN_DISCOUNT_RATE` | 0.01 | Floor for discount rate |
| `MAX_DISCOUNT_RATE` | 1.0 | Ceiling for discount rate |
| `MAX_REWARDS` | 500 | Maximum rewards stored |
| `IMPULSIVITY_LABELS` | hash | Named tiers from `very_patient` to `very_impulsive` based on discount rate |
| `VALUE_LABELS` | hash | Named tiers for subjective value ratio |

## Helpers

### `Helpers::Reward`

Single reward with hyperbolic discounting.

- `initialize(id:, label:, amount:, delay:, domain: :general, discount_rate: DEFAULT_DISCOUNT_RATE)` — clamps discount_rate to MIN/MAX bounds
- `subjective_value` — `amount / (1.0 + discount_rate * delay)`
- `value_ratio` — `subjective_value / [amount, 0.001].max`
- `value_label` — maps value_ratio to VALUE_LABELS
- `impulsivity_label` — maps discount_rate to IMPULSIVITY_LABELS
- `worth_waiting?(threshold: 0.3)` — `value_ratio >= threshold`
- `adjust_delay!(new_delay)` — updates delay
- `adjust_discount_rate!(new_rate)` — updates rate, clamps to bounds

### `Helpers::DiscountingEngine`

Reward store with comparison and patience profiling.

- `initialize` — rewards hash keyed by id, domain_rates hash
- `create_reward(label:, amount:, delay:, domain: :general, discount_rate: nil)` — uses `domain_rates[domain] || DEFAULT_DISCOUNT_RATE` if no rate given; returns nil if at MAX_REWARDS
- `compare_rewards(reward_id_a, reward_id_b)` — returns hash with both subjective values and which is preferred
- `worth_waiting_for?(reward_id, threshold: 0.3)` — delegates to `reward.worth_waiting?`
- `set_domain_rate(domain, rate)` — stores domain-specific discount rate
- `get_domain_rate(domain)` — returns domain rate or DEFAULT_DISCOUNT_RATE
- `immediate_vs_delayed(domain:, immediate_amount:, delayed_amount:, delay:)` — computes sv for both; returns comparison hash
- `optimal_delay(reward_id, min_value: 0.3)` — solves `min_value = amount / (1 + k * max_delay)` for max_delay: `(amount / min_value - 1) / k`
- `patience_report` — impulsivity distribution across all rewards
- `rewards_by_domain(domain)` — filter by domain
- `most_valuable(limit: 5)` — sorted by subjective_value descending
- `prune_expired` — removes rewards with delay <= 0

## Runners

All runners are in `Runners::TemporalDiscounting`. The `Client` includes this module and owns a `DiscountingEngine` instance.

| Runner | Parameters | Returns |
|---|---|---|
| `create_temporal_reward` | `label:, amount:, delay:, domain: :general, discount_rate: nil` | `{ success:, reward_id:, label:, subjective_value:, value_ratio: }` |
| `compare_temporal_rewards` | `reward_id_a:, reward_id_b:` | `{ success:, reward_a:, reward_b:, preferred: }` |
| `check_worth_waiting` | `reward_id:, threshold: 0.3` | `{ success:, reward_id:, worth_waiting:, value_ratio: }` |
| `immediate_vs_delayed_comparison` | `domain:, immediate_amount:, delayed_amount:, delay:` | `{ success:, immediate_sv:, delayed_sv:, preferred: }` |
| `compute_optimal_delay` | `reward_id:, min_value: 0.3` | `{ success:, reward_id:, max_delay: }` |
| `temporal_patience_report` | (none) | Impulsivity distribution from `DiscountingEngine#patience_report` |
| `set_domain_discount_rate` | `domain:, rate:` | `{ success:, domain:, rate: }` |
| `most_valuable_rewards` | `limit: 5` | `{ success:, rewards:, count: }` |
| `update_temporal_discounting` | (none) | `{ success:, rewards: }` — calls `prune_expired` |
| `temporal_discounting_stats` | (none) | Total rewards, mean discount rate, mean subjective value, domain rate map |

## Integration Points

- **lex-tick / lex-cortex**: `update_temporal_discounting` wired as a tick handler prunes expired rewards each cycle
- **lex-volition**: DriveSynthesizer uses prediction confidence; temporal discounting of reward value can modulate the urgency drive — high-discount-rate domains produce stronger urgency for immediate action
- **lex-temporal**: objective delay values from lex-temporal's elapsed time tracking feed into `adjust_delay!` calls to keep delay values current
- **lex-prediction**: predicted future rewards can be evaluated for subjective value before being added to the intention stack via lex-volition
- **lex-somatic-marker**: somatic markers associated with waiting vs. acting now can be paired with temporal discounting signals for integrated decision-making

## Development Notes

- Constants are in the top-level module namespace (`Legion::Extensions::TemporalDiscounting::DEFAULT_DISCOUNT_RATE`), not a nested `Constants` module — this is an exception to the usual pattern in this codebase
- Hyperbolic formula `sv = amount / (1 + k * delay)` produces slower discounting at long delays compared to exponential — this matches empirical human discounting behavior
- `optimal_delay` solves the formula algebraically: given `min_value = amount / (1 + k * d)`, the max tolerable delay is `(amount / min_value - 1) / k`
- `prune_expired` removes rewards where `delay <= 0` — callers are responsible for updating delays before calling `update_temporal_discounting`
- `immediate_vs_delayed` creates temporary Reward objects (not persisted) for the comparison — only `create_temporal_reward` persists rewards
