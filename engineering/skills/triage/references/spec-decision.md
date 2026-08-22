# Spec decision

`triage`'s routing step reads this once verification and isolation are done. Given what
was found, this is the row it belongs in — the route to take, and whether that route
needs a written spec before anyone builds against it.

| Case | Route | Spec? |
|---|---|---|
| Cause obvious, fix small and localized, low risk | quick fix → `diagnosing-bugs` | **No** |
| Not reproducible, already implemented, or out of scope | record disposition + close | **No** |
| Under-specified, or really a feature request in disguise | grill → `signal` → `brainstorming` → `to-spec` | **Yes** (feature path) |
| Real fix but non-trivial — several sites, a design choice, risky/cross-cutting, needs sequencing, or handed to an AFK agent | `brainstorming` → `to-spec` → `writing-plans` | **Yes** |

**Rule of thumb:** *spec when the fix needs a plan or another party will execute it; skip
the spec when a single obvious change closes it.*

A row is picked once — by the isolation step, from what it actually found — not
reasoned toward from a preferred outcome. If two rows both seem to fit, the row asking
for more (a spec, a grill) is the safer read: it costs a conversation, where the cheaper
row costs a wrong route discovered downstream, after work has already started on it.
