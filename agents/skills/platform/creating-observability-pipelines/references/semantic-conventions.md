# Semantic conventions and compatibility

For newly authored neutral contracts use `deployment.environment.name`, the stable replacement for deprecated `deployment.environment`. Confirm the selected instrumentation's supported conventions version and maturity before changing emitters. Record the version, schema URL when available, and any opt-in/development conventions in the generated manifest.

For existing data, inventory emitted names and backend-specific field/tag mappings first. Preserve working queries until an explicit migration is planned and verified. A skill/example update does not migrate live telemetry. If both names are emitted during migration, define precedence and deduplication; do not double-count them. Preserve legacy name mappings only where the target instrumentation/backend requires them and state the retirement condition.

`service.owner` is an organization extension in these examples, not a claim of an upstream standard attribute. Record its purpose, owner, allowed values, cardinality and enforcement. Verify required conventions against official documentation and the installed provider schema; do not infer resource support from example prose.

Sources: [Deployment registry](https://opentelemetry.io/docs/specs/semconv/registry/attributes/deployment/) and [version selection](https://opentelemetry.io/docs/specs/semconv/configuration/version-selection/), checked 2026-10-06.
