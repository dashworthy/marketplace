# engineering

A single-plugin software-development pipeline for the `dashworthy` marketplace.

Two entrances open the work — `/signal` (discovery, for a feature or vague ask) and
`/triage` (problem isolation, for a reported defect). Both pass through a design-dialogue
approval gate and produce one spec, then flow through planning, TDD build, test hardening,
and documentation hardening. All artifacts are files; there is no issue-tracker integration.

<!-- Pipeline diagram, phase table, and non-guarantees are filled in at the cutover plan,
     mirroring the spec's End-to-end flow section. -->

## Install

```
/plugin marketplace add https://github.com/dashworthy/development-skills
/plugin install engineering@dashworthy
```

## License

MIT. See [LICENSE](../LICENSE).
