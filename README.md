# Dashworthy Development Skills

A Claude Code **plugin marketplace** published from this one repo. It now carries a
single plugin: **engineering**, a complete software-development pipeline that takes a
request from a vague ask through to a green, documented branch.

## Add the marketplace

```
/plugin marketplace add https://github.com/dashworthy/marketplace
```

## Install

```
/plugin install engineering@dashworthy
```

That's the only install command this marketplace needs — engineering carries
everything, so there's nothing else to add on top of it.

## Pipeline overview

Work enters through one of two doors. A feature or a vague request starts at
**discover**; a reported defect starts at **triage**, which isolates the problem before
deciding how far it needs to go. Both doors open onto the same **design dialogue**
(`brainstorming`): a forced comparison of two or three approaches, worked through
section by section, that will not let anything downstream start until you've
explicitly approved a direction. Approval hands off to **`to-spec`**, a single writer
that turns the approved design into one spec document.

From the spec, the rest of the pipeline runs in a fixed order: **plan** the work,
**build** it test-first, **harden** the tests against the gaps a first pass tends to
leave behind, and **document** whatever prose the branch touched. Each phase reads what
the phase before it produced; none of them re-decide what an earlier phase already
settled.

### What it doesn't do

- **No issue tracker.** Every artifact is a file. Even triage, which exists specifically
  to isolate a reported problem, logs its findings to a disposable run directory rather
  than opening a ticket anywhere.
- **CONTEXT.md and ADRs are optional.** The design and build phases read them when
  they exist and carry on fine when they don't. Nothing in the pipeline demands you
  maintain either.
- **Scratch output is disposable.** Everything a run produces along the way lives under
  a gitignored, per-run scratch directory. It's safe to delete; nothing durable depends
  on it surviving.
- **Skills stay flat.** The plugin doesn't nest its skills into subdirectories to show
  relatedness — grouping comes from naming and a README index, not folders.

## Deprecation

`signal`, `verity`, and `vernacular` haven't disappeared — they're now phases inside
`engineering` rather than plugins you install on their own: discovery, test hardening,
and documentation hardening, in that order. The three separate install commands are
deprecated:

```
/plugin install signal@dashworthy
/plugin install verity@dashworthy
/plugin install vernacular@dashworthy
```

Use `/plugin install engineering@dashworthy` instead. If you already have one of the
three installed, it keeps running exactly as before — nothing breaks underfoot. The old
name simply stops being the way forward the next time you reinstall or update it; at
that point, reach for `engineering@dashworthy`.

## Transition note

For as long as `superpowers` is also installed alongside this marketplace, a handful of
`engineering` skill names will look like they shadow a `superpowers` skill of the same
short name — `engineering:tdd` next to `superpowers:tdd`, `engineering:brainstorming`
next to `superpowers:brainstorming`, and a few others. They aren't the same skill; each
`engineering` one is written and maintained independently. Every skill reference is
namespaced by its plugin, so the two families never actually collide — the apparent
overlap is cosmetic, and it goes away entirely once `superpowers` is removed.

## License

MIT. See [LICENSE](LICENSE).
