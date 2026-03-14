# lex-cognitive-avalanche

Cascading thought-chain model for LegionIO. Models how small perturbations become massive cognitive avalanches through snowpack accumulation, trigger events, and cascade propagation.

## What It Does

Thoughts accumulate like snow: slow buildup increases depth, reducing stability over time. When depth crosses a threshold and external force is applied, an avalanche triggers. The cascade type determines the character of the runaway — creative cascades are productive bursts of association, chaotic cascades are destabilizing spirals.

The extension tracks snowpacks by type (ideas, emotions, memories, associations, impulses) and domain, records cascade history with magnitude scores, and provides terrain stability reports.

## Usage

```ruby
client = Legion::Extensions::CognitiveAvalanche::Client.new

pack = client.create_snowpack(
  snowpack_type: :ideas,
  domain: :problem_solving,
  content: 'unprocessed ideas about the architecture',
  stability: 0.8
)

client.accumulate(rate: 0.06)   # call periodically to build depth

cascade = client.trigger(
  snowpack_id: pack[:snowpack][:id],
  force: 0.6,
  cascade_type: :creative
)

client.terrain_status
```

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
