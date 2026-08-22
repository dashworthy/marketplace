---
name: writing-skills
description: "[Foundation] Author, edit, and verify plugin skills — frontmatter shape, narrow-guarantee house style, group tags, and companion files. Use when adding or revising a skill in this plugin. Keeps the plugin self-extending. Model-invoked; no command."
---

# Writing Skills

Say this first, plainly: `Using the writing-skills skill to author or edit a skill in this
plugin.`

## What this guarantees

One thing: a skill authored or edited under this skill's discipline has frontmatter that is
mechanically correct — `name:` equal, literally, to its own directory; `description:` quoted
and either opening with a real `[Group]` tag or deliberately carrying none — and a body that
states exactly one narrow guarantee followed by an explicit, named list of what it does not do.
Both halves get checked before the skill counts as finished: the frontmatter by running
`tests/frontmatter.sh` against it, the body by reading it against the shape this document lays
out.

Nothing else is guaranteed. Read `## What this does not do` below before assuming this skill
judges more than that.

## Where a skill lives

Flat under `engineering/skills/<name>/SKILL.md`. This plugin's loader scans that directory
exactly one level deep — a `SKILL.md` sitting two levels down is invisible to it, not merely
disorganized, so there is no such thing as a nested skill directory here. Every skill gets its
own directory named for itself, and no two skills share one.

A skill that needs supporting material beyond its one file keeps that material inside its own
directory, never off in some shared or top-level location. A single companion document sits
right beside `SKILL.md` — `to-spec` keeps `SPEC-FORMAT.md` there, next to its own `SKILL.md`.
Several companion documents belong in a `references/` subdirectory of that same skill's
directory — `triage/references/`, `conducting-test-hardening/references/`, and
`clarifying-docblocks/references/` are the existing shapes to match. Either way, the material
stays one level of nesting under the skill's own directory; it is never promoted to a second
skill of its own, and it is never shared across two skills' directories.

## Frontmatter: exactly two keys

Every `SKILL.md` opens with a YAML frontmatter block holding exactly two keys — `name:` and
`description:` — and nothing else. No `tags:`, no `version:`, no license block; whatever a skill
needs to say beyond routing metadata belongs in its body, not bolted onto the frontmatter.

- `name:` MUST equal the directory the skill lives in, literally — not a close paraphrase, not a
  friendlier rewording. `tests/frontmatter.sh` reads the directory's basename and fails anything
  short of an exact match.
- `description:` opens with a `[Group]` tag when the skill is **process-tied** — it plugs into a
  named stage of one of this plugin's own processes. The group tags in use across the plugin
  today: `[Discovery]`, `[Triage]`, `[Design]`, `[Planning]`, `[Build]`, `[Test hardening]`,
  `[Docs]`, `[Foundation]` — this skill carries the last of those, since authoring skills
  underpins every process here rather than owning a stage of any single one. A
  **cross-cutting** skill — one that composes into whichever phase needs it instead of owning a
  stage of its own, the way `wizard`, `research`, and `resolving-merge-conflicts` do — carries no
  tag at all, and its description must not start with `[`.
- A description opening with `[Group]` MUST be wrapped in double quotes. An unquoted YAML value
  starting with `[` parses as a flow sequence, not a string — the tag would silently turn the
  whole description into a one-item list, and nothing about that failure looks like an error
  until something downstream tries to read the field as text. An untagged description doesn't
  strictly need the quotes for that reason, but wrapping it anyway costs nothing and keeps every
  skill's frontmatter block uniform to read.

## Deciding the group, and recording it twice

Which tag a new process-tied skill gets is a judgment about where in the plugin's real
processes it actually plugs in — not a lookup this skill or `tests/frontmatter.sh` performs for
you. Once it's decided, it belongs in two places, not one: the `[Group]` tag inside the skill's
own frontmatter, and a new entry in the matching row of the table in
`engineering/skills/README.md`. Those are two independent records of the same fact. A skill
added to its own frontmatter without a matching README row leaves the human index wrong; a row
added to the README without the frontmatter tag to match leaves the claim unchecked. Neither
record updates the other automatically — update both, every time.

## Body shape: the house style

Every skill's body opens with one line, spoken before any explanation of what follows: `Say this
first, plainly:` followed by an inline-code span reading `Using the <name> skill to <purpose>.`
It exists so whoever is watching a session unfold knows which skill is driving before anything
else happens — not throat-clearing to skip past.

Right after it, `## What this guarantees` states the one thing this skill promises will be true
once it finishes — one thing, not a list dressed up as one. If the honest answer to "what does
this skill guarantee" takes three sentences naming three different outcomes, that's a sign the
skill is doing three skills' worth of work, not a sign the section needs to say more.

Somewhere in the body — most of this plugin's skills put it last, and following that placement
keeps skills easy to compare at a glance — `## What this does not do` lists, by name, the
adjacent things a reader might reasonably assume this skill also covers because they sit close
to what it actually does, and says which other skill owns each one instead. A guarantee written
without its neighboring non-guarantees invites scope creep on its own: whoever reads only the
guarantee assumes silence means "handled here too."

Sibling skills get named with the plugin's own prefix, `engineering:<skill-name>` — never
`superpowers:<skill-name>`, even where a similarly named skill exists in that other plugin. This
plugin's skills reference each other as what they are here, not as aliases of something else.

## Validating a skill

```
sh engineering/tests/frontmatter.sh <skill-dir> [group-tag]
```

This checks: the directory has a `SKILL.md`; its `name:` equals the directory's own basename;
its `description:` is present and non-empty; and, when a group-tag argument is given, the
description opens with exactly that tag. Run it with the tag for every process-tied skill, and
with no tag at all for every cross-cutting one — passing a tag against an untagged skill fails
on purpose, the same way an untagged process-tied skill fails; a cross-cutting skill picking up
a tag by mistake is the identical defect running the other direction.

This check is mechanical, not a review of whether the skill is any good. It confirms the
frontmatter parses into the shape this document describes — nothing about whether the one
guarantee inside is drawn narrowly enough, or the non-guarantee list is actually complete. That
judgment stays a careful read against the house style above; no script performs it.

## Skills are living works

Every skill in this plugin is this plugin's own prose, describing this plugin's own conventions
as they actually stand today — not a fixed text written once and left alone. A skill's process
is expected to be re-learned as the plugin gets used: a guarantee that turns out drawn too
broad gets narrowed; a non-guarantee that turns out to matter after all gets folded in properly,
with its own reasoning, not bolted on as an afterthought; a whole section gets rewritten once
the way the plugin actually works has moved past what an earlier version of the skill said.
Treat every `SKILL.md` as this plugin's current-best understanding of its own process, not as
settled text — and when editing one, write the change in the plugin's own voice, the way its
sibling skills are written, not by carrying language over from somewhere else.

## What this does not do

- It does not **design a skill's process.** Working out what the process actually should be —
  what stage it owns, what it hands off and to whom — is `engineering:brainstorming` and the
  domain judgment behind it; this skill only shapes how that decision gets written down once
  it's made.
- It does not **judge a skill's guarantee beyond the mechanical check.** A skill can pass
  `tests/frontmatter.sh` cleanly while its guarantee is still too broad, or its non-guarantee
  list is still missing something a reader would reasonably assume. Catching that is a careful
  read against the house style above; this skill describes that read, it does not automate it.
- It does not **wire a skill into a slash command or the plugin's command surface.** A
  model-invoked skill's `SKILL.md` is its whole integration; anything that also needs a
  `/command` is separate plumbing under `engineering/commands/`, untouched by this skill.
- It does not **decide which group a new skill belongs to.** That's a judgment about the
  plugin's real process boundaries, made by whoever is authoring the skill against how the
  plugin actually works — not a lookup this skill performs on their behalf.
- It does not **rewrite a skill just because its prose could read tighter.** The living-works
  point above is about correcting drift from how the plugin actually behaves, not a license for
  unprompted polish; edit a skill because something about it stopped being true, not because it
  could be phrased more elegantly.
