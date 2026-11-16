---
name: bump-qiskit-version
description: Bump Qiskit.jl to a new Qiskit_jll version — regenerate the C bindings, move the compat bounds, and assess what broke. Use when upgrading or bumping Qiskit, picking up a new Qiskit release, regenerating the bindings, or evaluating the risk of a Qiskit version change.
---

# Bumping Qiskit.jl to a new Qiskit version

Start by deciding which track the bump is on. The tracks differ in how
much risk assessment the bump needs and in how many PRs it takes.

## Step 0: can this release break the C API?

The C API is stable as of Qiskit 2.7. From that point breaking changes are
confined to major releases. Before 2.7 every minor release could break it,
and did.

So:

- **Target is 2.6 or earlier** → breaking track.
- **Target is a new major version** (3.0, 4.0) → breaking track.
- **Target is 2.7 or a later minor in the same major series** → stable
  track.

`docs/devguide/deprecation.md`, section "Deprecations in the C API", states
the policy. Read it at the target tag rather than trusting this paragraph.
If it still disclaims stability there, take the breaking track whatever the
version number says.

---

# Stable track

Goal: **one PR** that raises the minimum version and exposes the new
functionality that minimum makes available — or, often, no PR at all. See
"When to bump at all".

A stable C API means the new library is a superset of the old one. There is
no layout change to guard against and no old version to keep working, so
the staging that the breaking track needs buys nothing.

**Prerequisite: the version must be in Yggdrasil.** `Qiskit_jll` lags
Qiskit itself, and nothing here can proceed until the JLL builds. See
"Checking availability".

Then:

1. `gen/Project.toml` — set `[compat] Qiskit_jll = "~X.Y"`, naming only the
   new version. This one stays pinned to a single minor: the generator must
   resolve the exact library the bindings will mirror.
2. `cd gen && julia --project=. -e 'using Pkg; Pkg.update()'`.
3. `cd gen && julia --project=. generator.jl`.
4. Root `Project.toml` — set `[compat] Qiskit_jll = "X.Y"`, with no tilde.
   See "The root bound floats".
5. Expose what the new minimum makes available. See "When to bump at all".
6. `julia --project=. -e 'using Pkg; Pkg.test()'` from the root.

Add a release note for the user-visible half of step 5, not for the
regeneration.

## The root bound floats

On the stable track the root bound is a floor, written as `"X.Y"` rather
than `"~X.Y"`. Julia reads a bare `"2.7"` as `>=2.7.0, <3.0.0`, so every
later minor in the series resolves with no change to this repo. Breaking
changes are confined to majors, and 3.0 is outside the bound.

That is the point of the stable guarantee: users pick up 2.8 and 2.9 on
their own, and the repo sees no churn to enable it. Do not enumerate minors
as `"~2.7, ~2.8"` — that is the breaking-track form, and on this track it
creates work for releases that cannot break anything.

`gen/` is the exception. It keeps the `~` pin because the bindings are a
snapshot of one library version, and generating them against whatever `Pkg`
happens to resolve would make the checked-in `lib/LibQiskit.jl`
irreproducible.

## When to bump at all

Most minor releases need no work here. With the root bound floating, a new
minor is already supported the moment its JLL is published, and bindings
generated against the older library stay correct because a stable API only
adds.

So the question that justifies a PR is step 5: what does 2.8 let us do that
2.7 did not? `features_c` in the release notes is where the answer lives.

- **Nothing worth exposing** → no PR. Users get the new version anyway.
- **Something worth exposing** → one PR. Raising the floor to `"2.8"` is
  what lets the bindings name 2.8 symbols, and it costs downstream users
  the older versions, so the new functionality is what pays for it.

## What still needs checking

Less than the breaking track, but not nothing.

- Read `features_c` at the target tag. On this track it is the list of
  candidates for step 5 rather than a hazard check.
- Read `deprecations_c`. Deprecations are permitted in minor releases and
  signal what will break at the next major version. Anything in `src/`
  calling a newly deprecated function is worth migrating now, while both
  spellings work.
- Skim `upgrade_c`. On a stable release this should be empty or
  clarifying. **An entry here that reads as a genuine breaking change means
  the stability assumption is wrong for this release** — stop and switch to
  the breaking track.
- Enum variants returned from C. Additive in principle, but a variant the
  `@cenum` cannot name is still a latent bug. `QkExitCode` gains variants
  most releases and is already handled: `check_exit_code` in
  `src/c_exit_code.jl` falls through to a generic message.

Skip the signature and layout diffing. That work exists to find breaking
changes, which the upstream guarantee now covers. If the guarantee turns
out to be wrong, the release notes and a failing test are what catch it.

---

# Breaking track

For a target that may change the C API: anything 2.6 or earlier, any new
major version, or any release whose notes contradict the stability
guarantee.

Four edits, in this order.

1. `gen/Project.toml` — set `[compat] Qiskit_jll = "~X.Y"`, naming only
   the new version so the generator resolves the library it must match.
2. `cd gen && julia --project=. -e 'using Pkg; Pkg.update()'` — writes the
   tracked `gen/Manifest.toml`. Use bare `Pkg.update()`, not
   `Pkg.update("Qiskit_jll")`: with a package named positionally, `Pkg`
   defaults to `PRESERVE_ALL` and allows only that package to move, which
   fails to resolve when the new JLL requires a different `Python_jll`.
3. `cd gen && julia --project=. generator.jl` — rewrites `lib/LibQiskit.jl`.
4. Root `Project.toml` — the bound chosen under "Choosing the compat
   bound", which may be wider than the one in `gen/`.

Then `julia --project=. -e 'using Pkg; Pkg.test()'` from the root.

## Assessing the risk

Two halves, and neither substitutes for the other. Diffing signatures and
type layouts catches changes of shape. Reading the release notes catches
changes of meaning — a field, argument or return value that kept its type
and changed what it signifies. No diff can show that, so skipping the notes
means shipping it silently.

Compare the two release tags (e.g. `2.5.0` vs `2.6.1`) in a clone of
https://github.com/Qiskit/qiskit — not `main`, which carries unreleased work.
`git archive <tag> crates/cext | tar -x -C <dir>` gets one tag's sources out
without disturbing the checkout.

Read `releasenotes/notes/` at the new tag; the directory is the whole set.
Notes are YAML keyed by section, and three mark the C API directly:
`features_c`, `upgrade_c` and `deprecations_c`. Grep for those first.

Do not stop there. The 2.6 notes carried one `upgrade_c` entry against
several under `upgrade_circuits` and `upgrade_qpy`, and a change described
only for Python often reflects the same Rust code the C API calls.
`releasenotes/config.yaml` lists every section name.

Treat the diff as triage, not as the answer. Large internal refactors show
up as huge diffs that change no interface, and a real ABI change may go
unmentioned in the notes.

- Signatures: `grep` the `pub extern "C" fn` definitions under
  `crates/cext/`. Classify each change — a `*mut`→`*const` relaxation or an
  added `mut` binding is ABI-neutral; a changed arity or type is not.
- Layouts: compare `#[repr(C)]` struct and enum bodies, then intersect
  against the `Qk*` types in `lib/LibQiskit.jl`. An appended struct field is
  the dangerous case.
- Confirm against the shipped artifact once the JLL resolves. The headers at
  `Qiskit_jll.artifact_dir/include/qiskit/` (`types.h`, `funcs.h`;
  `qiskit.h` is just an umbrella) are ground truth; the header checked into
  the Qiskit repo is only a fragment, since cbindgen generates the rest.

New enum variants are additive, but check which direction they travel. A
variant *returned* from C that the `@cenum` cannot name is a latent bug.
`QkExitCode` gains variants most releases and is already handled —
`check_exit_code` in `src/c_exit_code.jl` falls through to a generic message
for codes it does not name.

Weight everything by what the porcelain actually uses. `src/` and `ext/`
call on the order of 50 of the ~300 bound functions, so that is the set
where a semantic change becomes a behavior change for users:

```
grep -ohE 'qk_[a-z0-9_]+' src/*.jl ext/*.jl | sort -u
```

Cross-reference that list against the notes, and read the surrounding Julia
for each function the notes mention. A changed meaning matters where `src/`
relies on the old one.

A function that exists only as a raw binding, with nothing in `src/` calling
it, is a hazard for the `Qiskit.C` escape hatch rather than a package bug.

## Choosing the compat bound

Decide this from the risk assessment above, not by default.

A range like `"~2.5, ~2.6"` is correct when the regenerated bindings stay
layout-compatible with the older library, which is the common case for a
release that only adds functions. Bindings are `@ccall`, so a binding to a
symbol the older library lacks is inert until something calls it.

Narrow to `"~2.6"` when a type the bindings mirror changed layout — a struct
that gained a field, or a field whose type changed size. Those are passed or
returned by value, so the mismatch reads garbage rather than failing
cleanly. One such change is enough to rule out the range. This is what
forced the single-version pin in 2.6, where `QkCircuitDrawerConfig` gained a
fourth field.

## One PR or two

When the bound can stay wide, prefer two PRs. The first adds the new
version to the compat bound and leaves the bindings alone. The second drops
the old version and regenerates. That ordering keeps the bound honest at
every commit: nobody on the old library gets bindings for symbols it does
not export, and the regenerated surface arrives together with the pin that
guarantees it resolves.

A narrow bound removes the choice: with no intermediate state that
supports the old version, the compat bump, the regeneration and the drop
have to land together.

---

# Checking availability

Both tracks need the JLL published before anything resolves.

- `Qiskit_jll` lags Qiskit itself. A version that is not in the registry
  needs a Yggdrasil build first. Either bound form picks up later releases
  within its range with no further change here.
- Registry metadata can be stale. `~/.julia/registries/General.tar.zst` is
  the current one; a leftover `.tar.gz` may be months old and silently
  missing the version you are looking for. Check mtimes before concluding a
  release is unpublished.

On the stable track this is a hard gate: the PR raises the minimum, so it
cannot even be tested until the JLL exists. Confirm availability before
starting rather than discovering it at step 2.

# Notes

- The `Downgrade` job in `.github/workflows/CI.yml` resolves the lowest
  version the bound allows, so the floor is tested rather than merely
  asserted. On the stable track that makes it the job that would catch a
  binding referring to a symbol the floor version lacks. With a
  single-version bound it tests the same version as the main matrix.
- `gen/stub_cxx/` is generator scratch and stays untracked.
- Commit `gen/Manifest.toml` with the rest; it is tracked. The root
  `Manifest.toml` is not.
