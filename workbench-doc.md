In this document we describe our plans to develop a next-generation
mathematical workbench for the Lean theorem prover ("The Lean
Workbench", "the workbench"). It will enable mathematicians to work
and collaborate in an environment that seamlessly combines familiar,
informal mathematical writing with the correctness assurances of Lean.

# Background

## Terminology

A person using the Lean Workbench may use it in different ways, so we
choose some terms to distinguish those roles. An **author** is someone
making some piece of mathematics content: a formalized theorem,
research paper, tutorial, textbook, blog post, etc. A **reader** is
someone consuming any of these. This includes reading it in the
workbench itself, or reading some exported artifact that it produces.

This distinction is relevant when discussing some design choices. For
example, giving the author full control over a document's color
scheme, font size, etc. is in tension with giving the reader that same
control.

We still refer to the **user** to mean someone interacting with the
workbench in a way that is independent of their relationship towards
the documents involved. For example, a user of the workbench may have
some account settings, and this is true regardless of whether they
spend most of their time authoring or reading documents.

An **institutional user** is for example, a university that wants to
run a course using the workbench. An **administrator** is someone who
an institutional user entrusts with the power to install, configure,
and maintain the institution's instance of the workbench.

## Verso

[Verso](https://github.com/leanprover/verso) is a collection of
libraries for representing documents in Lean paired with an
alternative concrete syntax that allows them to be written in
something very much like Markdown. Documents written in Verso can make
full use of the Lean metaprogramming API to create arbitrary new
features, and these features can be made portable between genres.

## Lean4Web ("Live-Lean")

[Lean4Web](https://github.com/leanprover-community/lean4web) is a web
application that allows editing a single Lean file from in the browser
and accessing the info-view for it. Its interface strongly resembles
VSCode with the Lean4 extension installed, and supports most of the
normal operations supported in that environment to the extent that
they make sense, such as jump-to-definition, (with links to external
documentation sites when the code is not part of the single file being
edited) code completion, quick fixes, etc.

An instance of Lean4web is hosted at
[https://live.lean-lang.org/](https://live.lean-lang.org/).

Lean4web uses a server-client architecture, in contrast to earlier web
interfaces made for e.g. Lean3. The server process, which is
responsible for actually running the lean binary and compiling and
typechecking user code, is sandboxed using
[Bubblewrap](https://github.com/containers/bubblewrap). The client
relies on the monaco text editor component from vscode.

## Lean4VSCode

The [existing vscode extension for lean4](https://github.com/leanprover/vscode-lean4)
has extensive ide feature support, including
- document highlights
- hovers
- folding ranges
- semantic tokens
- inlay hints
- completions
- diagnostics
- signature help
- code actions

Moreover, it makes use of various lean-specific extensions to the LSP protocol.
A significant example is that semantic highlighting is done incrementally rather than
all at once, which is the only thing the standard LSP protocol supports. Incremental
highlighting is important in practice for the user experience of editing Lean files
in which the full computation can be expensive.
[More details are explained here](https://leanprover.zulipchat.com/#narrow/channel/113488-general/topic/Lean.20.2B.20Zed.20integration/near/505671509).

## Natural Numbers Game

The natural numbers game, and more generally current iteration of the
[lean game server](https://adam.math.hhu.de/), presents an alternative
interface for constructing lean proofs that is suitable for people
learning about mechanized proofs for the first time, as well as people with
some degree of familiarity with proof assistants who nonetheless want an introduction
to tactic-based proving.

The differences from the standard lean environment which have pedagogical value include:
- explanatory narrative text to the learner is provided in a sidebar
- hints can be provided that are conditioned on what steps the learner has already taken in the proof
- specific proof goals are provided as exercises, and are partially ordered to ensure the learner first understands concepts that are prerequisites for other learning goals
- the authoring of a proof is (by default) constrained to adding steps one after another to the growing script. A free-text-entry mode is also provided.
- the tactics available are constrained to a limited "vocabulary" which expands as the game proceeds

Games are authored by writing lean code in a DSL that allows adding
metadata for narrative text, custom learner-oriented tactic
documentation, and intra-proof hints.

Like lean4web, the lean game server does in fact rely on a server
running the lean process. Communication between the client and the
server is mediated to accomplish the interface differences described above.

## Widgets Framework

[Documented here](https://lean-lang.org/examples/1900-1-1-widgets/)

## Blueprint

Patrick Massot's [blueprint tool](https://github.com/PatrickMassot/leanblueprint) allows
writing a LaTeX document with annotations on theorems and definitions that specify
- which lean identifiers they are intended to correspond to in a lean development
- whether the statement and/or proof of an informal theorem is believed to have a complete,
correct formalization on the lean side
- which other theorems and/or definitions it depends on
and will then generate html and pdf output and a dependency graph, decorated with the
inferred status of various elements of the planned work. For example, it will
communicate whether an theorem that hasn't been formalized yet is <i>ready</i> to be
formalized, in the sense that all of the definitions and statements of lemmas it
depends on have been formalized.

### Zhu's Blueprint Metaprogramming

Thomas Zhu has a prototype of generating blueprints from annotations directly on lean
code. It would be useful to fold this into verso, and/or have some first-class way of
viewing and navigating these online.

https://github.com/hanwenzhu/blueprint-gen

https://github.com/hanwenzhu/blueprint-gen-example

## Visual Design

Examples of other language sandboxes include

- Elm: https://ellie-app.com/new
- Rocq: https://jscoq.github.io/scratchpad.html
- Racket: https://onecompiler.com/racket
- Typst: https://typst.app/play/
- Twelf: https://twelf.org/twelf-wasm/
- Dusa: https://dusa.rocks/
- Compiler Explorer: https://godbolt.org/
- GraphQL: https://studio.apollographql.com/sandbox/explorer/
- JSFiddle: https://jsfiddle.net/
- Codepen: https://codepen.io/
- Egglog: https://egraphs-good.github.io/egglog-demo/
- p5: https://editor.p5js.org/
- Github vscode wrapper: https://github.dev/github/dev

# Goals

## Installation

All features of the workbench should be available to the user without
installing any software on their own computer other than a modern web
browser. The workbench's primary interface is as a web application.

Institutional users will, however, need to install and maintain the
server software that supports the workbench's interface. This
installation process should be simple and reliable.

## Identity

Within one workbench server, there is a notion of identity, that is,
"user accounts" in some sense.

This notion should mostly rely on external identity providers, such as
github, google, or a university's preferred SSO system. We should, as
much as possible, avoid reinventing wheels in this design space.

The workbench should have a portion of its functionality available
*without* creating an account, to the
extent that it makes sense. The
[live.lean-lang.org](https://live.lean-lang.org) service demonstrates
that this mode of use is extraordinarily useful for sharing minimal
working examples, and testing out small ideas. We anticipate it being
important for adoption that potential new users have a low-overhead
way of reading (and perhaps modifying without saving) existing
mathematical projects in the workbench.

The onramp from this state to creating an account should be
low-friction.

## Permissions

There should be a notion of associating permissions with accounts, to
control access to administrative features (e.g. moderation, account
creation/deletion)

There should be a notion of associating permissions with documents, to
control various capabilities, among them familiar things like reading,
writing, commenting. For example an author of the solutions to some
exercises might want students to not be able to view it, and most
documents probably shouldn't be world-writable.

## Data Organization

The workbench should support persistent storage of user content. This
includes lean files, as well as relevant metadata and user settings.
For example, users may wish to save their progress through interactive
games.

The workbench should make it easy to backup all such persistent
content.

The workbench's conception of "what a Lean project is" should be as
close as possible to what it is when someone uses Lean normally on
their own computer. It is organized as directories and files. A
project has a toplevel directory with a `lakefile.toml` or
`lakefile.lean`, with subdirectories that constitute modules, etc. We
should aim to provide, when useful, alternate *presentations* of this
data, and/or alternate ways to edit it.

To that point, the workbench should support editing of Lean
projects that span multiple files.

The workbench should provide conveniences and good defaults for
starting new projects, catering to users that are not familiar already
with lakefiles.

It should be easy for an institutional user to backup and restore the
entire data store of their workbench installation. It is acceptable if
this is through commandline tools, rather than through the web interface.

## Collaboration

The workbench should support integration with version control.

The workbench should support multiple users being able to make changes
to the same Lean project, including near-real-time editing of the same
document.

The workbench should support communicating
[awareness](https://docs.yjs.dev/getting-started/adding-awareness)
data: which collaborators are currently actively viewing the document,
and which part of the document they are viewing or editing.

The workbench should support exporting a project to a gzipped tar or
zip archive. The workbench should support import of these archive
formats, as well as git remotes.

## Document Authoring

The workbench should provide ways of exporting documents as finished
artefacts, as PDF, HTML, or other formats as appropriate. We expect
this to be done by relying on Verso.

The workbench should provide rapid feedback for how documents will
look. For example,
[Typst](https://typst.app/play/) sets a very high bar for speed.

Authors should be able to include non-textual elements inline in their documents.
Examples include but are not limited to:
  - Links to other workbench documents
  - Transclusions from other documents
  - Diagrams that can be manipulated/rotated/explored by the reader
  - Multiple-choice comprehension-checking quiz questions
  - Exercises that are solved by the reader supplying more lean proof
  - Exercises that are solved by the reader interacting NNG-style
  - Attractively rendered mathematical expressions derived from document content

## Security

The workbench should prevent uncontrolled access to the underlying
resources of the server. Because Lean can be used a general-purpose
programming language, this requires sandboxing at the operating system
level.

## Mobile

It should be possible to *view* workbench content from a mobile device. It is not
necessarily a goal that interactive features work the same way, nor is it a goal
that the editing experience on mobile is at parity with a normal desktop browser.

# Non-Goals

It is a non-goal for the workbench to completely replace the ability
to install and use Lean normally.

It is a non-goal to run the entirety of the lean kernel, compiler,
type-checker, Mathlib etc. inside the web browser. It is acceptable to
maintain a client-server arrangement where the more memory- and
computation-intensive parts of type-checking Lean take place on the
server.

It is a non-goal for the Lean FRO to maintain a single workbench
server that is meant to accommodate all usage globally. The FRO may
choose to maintain a server with a deliberately conservative set of
expectations of usage. For example, the amount of compute or disk
storage might be limited, or saved files, if any, might have a limited
lifetime before being garbage-collected. We expect institutional users
to install and maintain their own copies of the service if they want
the members of their institution to have a full-featured version of
the workbench experience.

Although it is desirable, all else equal, for the workbench to be as
easy to use for as many users as possible, it is a non-goal for the
workbench to work on literally every web browser: it is acceptable to
make some compromises in browser coverage if browsers lack features
necessary for other goals of the project to be achieved.

# Data Design

## Per User Data

For a given instance of the workbench, there is a set of users.
Each user has data that they own. This includes a set of *projects*
(see below) and other metadata.

TODO: more details

## Projects Structure

Each project conceptually consists of a directory which may
recursively contain other directories and files. The structure of
these directories and files follows the same conventions and
requirements of a lean project. For example, there must be a
`lakefile.toml` or `lakefile.lean`, a `lean-toolchain` file, etc.
There may be additional files in a project directory that contain
per-project metadata.

TODO: more details

## Permissions

Information about access control for a project can be stored as a
`.json` file in the top-level directory.

TODO: more details

# Architecture Design

TODO: architecture diagram here

## Interface Organization

A central decision point is whether to present to the user what is
fundamentally "VSCode on the web" (similar to https://vscode.dev/ or
https://github.dev/ or https://gitpod.io/) or something else. This
question does not address whether we reuse the monaco text editing
component (which is discussed below) or whether we intend to reuse a
substantial amount of functionality from the Lean VSCode plugin, LSP
client, etc. (which we intend to do). It is concerned with the user
interface affordances that are outside the scope of a single file, for
example:

- file management: choosing files to edit, moving files around, modifying their attributes
- selecting a project/workspace to work on
- searching across an entire project

### The case for "Basically VSCode"

- More reuse, less time spent coding up file browser widgets
- Easier transfer of skills from workbench to local installation

### The case for Custom UX

- More freedom to find solutions that make sense for specifically the online case,
  such as affordinaces for collaborative editing, sharing, linking that may not
  fit well in VCSode's current model.
- More ability to design for domain-specific ways of focusing readers' attention.
  This is especially relevant for inexperienced readers whom we want to avoid
  overwhelming with advanced features.

### Decision

For the first stage of development, we intend to pursue a "Basically
VSCode" interface. [Gitpod's opensourced version of their
vscode-server](https://github.com/gitpod-io/openvscode-server) appears
promising as a base for development. As the project evolves, we will
be able to experiment with other UX experiences that are based on
underlying lean code, but we consider it important to establish a
working baseline system that allows authors to work on real Lean
projects, and sticking to known mechanisms reduces development risk.

Furthermore, the other UX experiences we plan to offer can benefit
from this grounding in a basic and familiar mode of editing. If there
are any gaps during early development of some new mode, as long as it
is a "turn-over" experience of an underlying lean project, then we can
always use the basic mode as a fallback for editing.

## Text Editing Component

We discuss here decisions about what core text editing component we plan to rely on.

### Monaco

[Monaco](https://github.com/microsoft/monaco-editor) is the text editing component developed for VSCode.
It is what lean4web currently uses.

**Pro**

- Actively developed, institutional support from Microsoft
- Already extremely well tested in its use in lean4web
- Extensive LSP support (document highlights, hovers, folding ranges,
  semantic tokens, inlay hints, completions, diagnostics, signature
  help, code actions, code formatting and extending the protocol with
  custom fields, capabilities, requests and notifications. )
- Lean-specific extensions already implemented in lean4web
- Has [plugin support](https://github.com/yjs/y-monaco/) for collaborative editing
  via a well-known javascript CRDT library.

**Con**

- Disclaims support for mobile, although in practice it's not clear what functionality is missing. We have a "backup" instance of codemirror in lean4web.
- Doesn't allow inline DOM elements. [Although this PR](https://github.com/microsoft/vscode/pull/66418) has landed,
there is no officially supported API for it, and it appears to have languished for years in this state.

### Codemirror

[Codemirror](https://github.com/codemirror/dev/) is another generally
popular text editing component in the open-source ecosystem. For
example, Jupyter uses it.

The main reason for even considering it is that it does support
injecting arbitrary DOM elements into the flow of code, (see [examples
here](https://codemirror.net/examples/decoration/)) subject to some
constraints to make vertical layout predictable.

**Pro**

- Deliberate support for mobile
- Good accessibility story
- Has first-party support for [collaborative editing](https://codemirror.net/examples/collab/)

**Con**

- Much less mature LSP support
- Less actively developed, although has been developed since 2007; primarily solo dev

### Decision

We plan to stay with Monaco for the forseeable future, and try to find
workarounds for mixing text and nontextual elements.

## Extensible Interactivity

Authors should be able to create their own interactive visualizations
of mathematical content. We want to draw as much inspiration and reuse
from the existing Widgets framework as feasible.

We assume some kind of Elm/React-like architecture. The author needs
to express state update somehow. An important design decision is how
they express state update. Alternatives include the following:

One possibility we might imagine is to **write state update in lean, and it executes on the server**.
This is pretty much untenable. Latency would be too high.
Another possibility is to **write state update in javascript**.
This is what Widgets does today. The main downside is that this creates an adoption barrier: with lean and javascript
there there are two languages to learn, two build systems to learn.

### Write state update in Lean

It would be desirable if authors could write widgets and their state update in lean, and have this somehow execute in the browser.
Within this space, there are various possibilities.

  - Compile a special-purpose Lean-embedded DSL. <br>
    **Con**: like writing javascript, user has to learn other language <br>
    **Pro**: could produce idiomatic javascript
  - Elaborate lean to Expr, and then custom compilation Expr to js. <br>
    **Pro**: tree-shaking happens naturally. Idiomatic mapping of high-level operations to javascript operations. <br>
    **Con**: Expr has tons of equality reasoning type of stuff (e.g. proof witnesses) in it that is proof-irrelevantly erased by IR time
  - Compile lean to LLVM to wasm. (probably emscripten)
  - Compile lean to C to wasm. (probably emscripten)
  - Compile lean to IR to wasm directly.<br>
    Extra work here is: understanding wasm format, relearn how C compilation works but do it by hand
  - Compile lean to something earlier than IR, then compile to idiomatic javascript.
  - Compile lean to IR to javascript.<br>
    Analyze the IR of reasonably well-behaved pure functions and produce idiomatic state-update javascript functions. <br>
    **Con**: might require a lot of work. IR maybe doesn’t have enough type information. <br>
    **Pro**: direct FFI arbitrary javascript. More inspectable/debuggable. <br>
    +/-: performance. Javascript slower than wasm for inner loop, but less overhead passing between js/dom manipulations and wasm.

## Collaborative Editing

In order for collaborative editing to work, we need some solution to reconcile divergent edits.
The [YATA algorithm](https://www.researchgate.net/publication/310212186_Near_Real-Time_Peer-to-Peer_Shared_Editing_on_Extensible_Data_Types),
as realized in the javascript library [Yjs](https://github.com/yjs/yjs), seems like a good choice in this space.

**Pro**:

- Mature project, has been in development for 11 years, with recent updates.
- Supports session-bounded awareness data
- Optimized for performance
- Confirmed to work with monaco specifically
- Underlying algorithm [https://github.com/iasakura/lean-yjs](has been recently verified in lean)
- CDRT as opposed to OT means it is more 'local-first', users can edit during
  server outages and have a good chance of reconciling edits afterwards.

**Con**:

- Still mostly in javascript, not typescript, though some api types available

## Identity

As a first pass, the workbench will rely on the GitHub OAuth Apps API
for managing user identities. This requires the user to share their
email address as provided to GitHub and no other permissions. Giving
permissions to take actions on behalf of the user (e.g. making
commits) is a separate, optional choice if the user wishes to use the
github version control integration features of the workbench.

## Lean Games

We aim to make the next generation of pedagogical experiences for
learning the Lean language, building on the success of the current
Lean Game Server and its predecessors.

First we mention the aspects of the system we intend to retain.

- The architecture is still server-client. It is a non-goal to do run a lean process in the browser.
- Lean game content is still structured as a simple, fixed-depth hierarchy of "worlds" and "levels".
- Per-level game content still consists of progressively revealed,
  narrative text, a single proof goal, hints, and specifying the "inventory" of allowed tactics.

We have the following goals for improvments:

### Workbench & Lean Ecosystem Integration

- Previewing a game whose underlying source is edited in the workbench
  should be an easy, one-click "turn-over" experience for the author.
  It should be possible to simply give a link to someone else to allow
  them to play the game.

- Authors can write games as Verso documents.

- Authors can easily convert existing games to this Verso format.

### Legibility

- We plan to push the capabilities of the game interface more in the direction of learners
  that are less familiar with theorem proving. This means providing an experience that
  deliberately restricts the available operations the player can perform with the aim
  of making it easier to perceive what the correct operation is at any given time.

- In practice we expect this to mean offering a "direct manipulation"-style interface,
  taking influence from Sketch, Blockly, Actema, Paperproof, etc.

### Transferrability

- Despite the above goal, we wish to nonetheless not stray too far from the value of lean
  games serving as an *onramp to proving and programming in Lean for real*. No matter
  what drag-and-drop functionality is offered, it must produce (and must be judged valid
  or invalid consistent with the production of) textual Lean proofs. This is "behind the scenes"
  by default, but users absolutely should be able to inspect it and see how it reacts to the
  operations they have become familiar with. This is analogous to the current Lean Game Server
  offering "text" vs. "typewriter" mode.

### Extensibility

- It is a goal to be able to support appropriate interface affordances
for arbitrary Lean tactics.

- Specifically, incrementally drilling into expressions for targeted
rewrites with something like `conv` should be possible, and the
various choices should be directly visible as affordances to the user,
without having to know ahead of time that, e.g. `lhs` is how they are
meant to select the left side of an expression.

- Similarly, we intend to support `calc` proofs.

### Measurability

- Progress through games should be stored server-side when users have accounts.

- With users' consent, at least in the context of a controlled study,
  the workbench should be able to collect metrics so that we can
  measure the effectiveness of interventions and interface design
  choices.

# User Stories

In this section we imagine some use-cases how the workbench could be used.

## Researcher

A person who wants to write a research paper for publication,
including its formalization. They can, using the Workbench's online
interface

- Create an account on a Workbench instance
- Create a new "research paper" project
- Edit their paper as lean code and human-readable text
- Preview it as rendered PDF
- Send an invite link to collaborators, who can then view and (if they
  also make an account) edit the same project
- Export the paper as LaTeX and PDF, suitable for publication on the
  ArXiv, or a journal or conference

## Professor

A person who wants to teach mathematics, using Lean to make the
relevant definitions and proofs formally verified. They can,
using the Workbench's online interface

- Create an account on a Workbench instance
- Create a new "course" project
- Create modules within the course that combine lean code and human-readable text
- Create exercises that consist of lean files with sorrys to be filled in by students

## Polymath

The term 'polymath' is used in the sense of [Tim Gowers's
Project](https://en.wikipedia.org/wiki/Polymath_Project). A person who
wants to achieve a large-scale collaboration among many people doing
mechanized mathematical work, many of whom may not know each other
well. Any of them can:

- Create an account on a Workbench instance
- Navigate the blueprint of a particular project to find out what work needs to be done.
- TODO: fill this idea out more? Is it really that distinct from "Researcher"?

## Blogger

A person who wants to publish many article-length narratives about formalized mathematics.
They can

- Create an account on a Workbench instance
- Create a new "research paper" project
- Compose their articles as lean code and human-readable text
- Preview it as rendered HTML
- Obtain a link to a rendered version of their post served by the Workbench instance

## Milestones

These are drawn from the [original proposal
document](https://docs.google.com/document/d/1VTcJsIgrp1R28HkFPJdyw7RaELwYFN2Ko3x990psCIk/edit?tab=t.0#heading=h.q6ejnzk07inl).

- Ability to edit multiple-file Lean projects
- Live collaborative editing
- Github integration
- AI interface
- NNG ported
- New games written
- Usability study
- Metrics dashboard
- Textbook/resources authored
- Papers published written with workbench
- Adoption by university courses
