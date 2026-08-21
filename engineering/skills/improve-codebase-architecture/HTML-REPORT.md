# HTML Report Format

`improve-codebase-architecture` renders exactly one report per pass, to a single `.html`
file in the OS temp directory. Self-contained means self-contained: nothing in the file
reaches outside it except the two CDN scripts named below, and nothing in it points back
into the repository the pass ran against — a file that only makes sense sitting next to the
codebase that produced it hasn't done its job. Someone should be able to send this file
anywhere, or open it years later on a machine with no copy of the repo, and still read every
finding in it.

## Filename

`<tmp>/improve-codebase-architecture-<YYYY-MM-DD-HHMMSS>.html` — `<tmp>` is whatever the
running OS reports as its temp directory (`$TMPDIR`, or the platform-conventional path when
that's unset). The timestamp is when the Report step started, not when Scan started, so two
passes run back to back never collide on a filename.

## What it loads

Two CDN scripts, nothing else external:

- Tailwind's CDN build, for layout and styling — `https://cdn.tailwindcss.com`.
- Mermaid's CDN build, for the module map — pin a specific version rather than floating on
  `@latest`, so the same report file renders the same way if it's reopened a year from now.

Everything else — every finding, every before/after snippet, every diagram node and edge —
is written inline into the one file: no separate CSS file, no separate JSON, no image asset
sitting next to it that the HTML merely references.

## Shape

```html
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <title>Codebase architecture report — <repo name>, <date></title>
  <script src="https://cdn.tailwindcss.com"></script>
  <script type="module">
    import mermaid from "https://cdn.jsdelivr.net/npm/mermaid@<pinned-version>/dist/mermaid.esm.min.js";
    mermaid.initialize({ startOnLoad: true });
  </script>
</head>
<body>
  <!-- 1. Header -->
  <!-- 2. Module map -->
  <!-- 3. Findings -->
  <!-- 4. Before / after -->
</body>
</html>
```

Four sections, in this order, on one scrolling page — no client-side routing, no tabs that
hide a section behind a click a reader has to know to make.

### 1. Header

The repository name, or the target path when the pass was scoped narrower than the whole
repository; the date and time the pass ran; and the two summary counts — total findings, and
how many of those were deepened versus declined. This is the only place summary numbers
appear on their own. Every count anywhere else in the report is attached to the list of
things it's counting, not a figure a reader has to take on faith.

### 2. Module map

One Mermaid diagram — a `graph` or `flowchart` — with one node per module the scan touched,
including modules with no findings against them; the map shows the codebase's shape, not
just its problems. Draw an edge for every dependency Scan found between two modules, and
mark the edges that cross a boundary this pass flagged distinctly from the ones it didn't —
the map itself should show where the tangling was without a reader cross-referencing the
findings list to see it.

### 3. Findings

One entry per item from the Scan step's finding list, in the same fixed order the list
closed in. Each entry states the module or boundary, which depth failure or leak shape it
matched, and its outcome — deepened or declined, with a one-line reason either way. A
deepened finding names the shape `codebase-design` chose for it and links down to its
before/after entry; a declined finding stops here, since there's no edit to show for it.

### 4. Before / after

For each deepened finding: the interface as it read before the edit, and as it reads after,
side by side, in plain `<pre>` blocks — not a diff library, not a syntax highlighter pulled
in from another CDN, just the two states written out in monospace. Underneath, one or two
sentences on what moved: which cost came out of the caller and went into the module. A
reader who has never opened the repository should be able to tell, from this section alone,
what actually changed and why it was worth changing.

## What this file is not

Not a build artifact, not something committed to the repository, not something this skill
reopens or reads back on a later run. It is written once, at the end of one pass, and its
only job after that is to be readable by whoever opens it. If a later pass wants to compare
against an earlier one, that comparison happens by a person reading two report files side by
side — this format carries no machine-readable state for a future pass to consume.
