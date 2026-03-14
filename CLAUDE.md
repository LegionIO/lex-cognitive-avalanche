# lex-cognitive-avalanche

**Level 3 Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`
- **Grandparent**: `/Users/miverso2/rubymine/legion/CLAUDE.md`

## Purpose

Cascading thought-chain model for LegionIO. Models how small perturbations become massive cognitive avalanches: snowpack stability, trigger events, cascade propagation, and debris fields. Used to detect and model runaway thought cascades — both creative (productive cascades) and chaotic (destructive spirals).

## Gem Info

- **Gem name**: `lex-cognitive-avalanche`
- **Version**: `0.1.0`
- **Module**: `Legion::Extensions::CognitiveAvalanche`
- **Ruby**: `>= 3.4`
- **License**: MIT

## File Structure

```
lib/legion/extensions/cognitive_avalanche/
  cognitive_avalanche.rb
  version.rb
  client.rb
  helpers/
    constants.rb
    avalanche_engine.rb
    snowpack.rb
    cascade.rb
  runners/
    cognitive_avalanche.rb
```

## Key Constants

From `helpers/constants.rb`:

- `SNOWPACK_TYPES` — `%i[ideas emotions memories associations impulses]`
- `CASCADE_TYPES` — `%i[creative emotional analytical chaotic convergent]`
- `MAX_SNOWPACKS` = `100`, `MAX_CASCADE_HISTORY` = `500`
- `TRIGGER_THRESHOLD` = `0.75` (depth >= this makes snowpack trigger-ready)
- `ACCUMULATION_RATE` = `0.06`, `MELT_RATE` = `0.02`
- `STABILITY_LABELS` — `0.8+` = `:bedrock`, `0.6` = `:moderate`, `0.4` = `:unstable`, `0.2` = `:critical`, below = `:catastrophic`
- `MAGNITUDE_LABELS` — `0.8+` = `:devastating`, `0.6` = `:major`, `0.4` = `:significant`, `0.2` = `:moderate`, below = `:minor`

## Runners

All methods in `Runners::CognitiveAvalanche` (`extend self`):

- `create_snowpack(snowpack_type:, domain:, content:, depth: 0.0, stability: 1.0)` — creates a new accumulating snowpack; `snowpack_type`, `domain`, and `content` are required
- `trigger(snowpack_id:, force: 0.5, cascade_type: :chaotic)` — triggers an avalanche from a snowpack if depth is sufficient; produces a cascade record
- `accumulate(rate: ACCUMULATION_RATE)` — applies accumulation to all snowpacks (depth increases)
- `list_snowpacks` — returns all snowpacks with their current state
- `terrain_status` — returns terrain report: total snowpacks, stability averages, recent cascade history

## Helpers

- `AvalancheEngine` — manages snowpacks and cascade history. `trigger` produces `Cascade` objects when depth >= threshold.
- `Snowpack` — accumulating thought store with `depth`, `stability`, `snowpack_type`, `domain`. Stability degrades under accumulation and recovers during melt. `trigger_ready?` checks depth vs `TRIGGER_THRESHOLD`.
- `Cascade` — records a triggered avalanche: `cascade_type`, `magnitude`, `source_snowpack_id`, `debris` (residual fragments from the cascade).

## Integration Points

- `lex-cognitive-dwell` and `lex-cognitive-echo` both model persistence of cognitive content; avalanche models the threshold crossing where that persistence becomes runaway.
- `lex-tick` can call `accumulate` on each tick to model slow pressure buildup, with `trigger` called when external force is applied (e.g., a high-intensity signal).
- `cascade_type: :creative` and `:analytical` are positive cascades; `:chaotic` and `:emotional` represent instability.

## Development Notes

- `create_snowpack` requires all three arguments (`snowpack_type`, `domain`, `content`) — missing any raises `ArgumentError`.
- `AvalancheEngine` state is in-memory only; history cap enforced via `MAX_CASCADE_HISTORY`.
- `accumulate_all!` is the periodic maintenance runner — intended to be called every tick or at set intervals.
- Cascade debris represents unprocessed fragments after the avalanche — callers can read these as input for downstream extensions (e.g., feed debris into memory traces).
