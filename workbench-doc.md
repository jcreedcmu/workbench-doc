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

TODO: Discuss client-server architecture.

## Lean4VSCode

TODO: Discuss existing LSP extensions.
[Marc explains a lot of useful details here](https://leanprover.zulipchat.com/#narrow/channel/113488-general/topic/Lean.20.2B.20Zed.20integration/near/505671509).

## Natural Numbers Game

TODO: Discuss client-server architecture.

## Widgets Framework

[Documented here](https://lean-lang.org/examples/1900-1-1-widgets/)

## Blueprint

TODO: Discuss role of python scripts checking consistency.

### Zhu's Blueprint Metaprogramming

Thomas Zhu has a prototype of generating blueprints from annotations directly on lean
code. It would be nice to fold this into verso, and/or have some first-class way of
viewing and navigating these online.

https://github.com/hanwenzhu/blueprint-gen

https://github.com/hanwenzhu/blueprint-gen-example

# Goals

## Installation

All features of the workbench should be usable without installing any
software on their own computer other than a modern web browser. The
workbench's primary interface is as a web application.

Institutional users will, however, need to install and
maintain the server software that supports the workbench's interface.
This installation process should be simple and reliable.

## Identity

Within one workbench server, there is a notion of identity, that is,
"user accounts" in some sense.

This notion should mostly rely on external identity providers, such as
github, google, or a university's preferred SSO system. We should, as
much as possible, avoid reinventing wheels in this design space.

The workbench should support a significant fraction
of its features being used *without* creating an account, to the
extent that it makes sense. The
[live.lean-lang.org](https://live.lean-lang.org) service demonstrates
that this mode of use is extraordinarily useful for sharing minimal
working examples, and testing out small ideas. We anticipate it being
important for adoption that potential new users have a low-overhead
way of reading (and perhaps modifying without saving) existing
mathematical projects in the workbench.

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

The workbench should support persistent storage of user content.

The workbench's conception of "what a Lean project is" should be
as close as possible to what it is when someone uses Lean normally on
their own computer. It consists of a directory with a `lakefile.toml`
or `lakefile.lean`, organized in directories that constitute modules,
etc. We should aim to provide, when useful, alternate *presentations*
of this data, and/or alternate ways to edit it.

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
to the same Lean project.

## Document Authoring

The workbench should provide ways of exporting documents as finished
artefacts, as PDF, HTML, or other formats as appropriate. We expect
this to be done by relying on Verso.

The workbench should provide rapid feedback for how documents will
look. TODO: How rapid is rapid? For example,
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

The workbench should prevent uncontrolled access to the underlying resources of the server.

## Mobile

It should be possible to *view* workbench content from a mobile device. It is not
necessarily a goal that interactive features work the same way, nor is it a goal
that the editing experience on mobile is at parity with a normal desktop browser.


# Non-Goals

It is a non-goal for the workbench to completely replace the ability
to install and use Lean normally.

It is a non-goal to run the entirety of the lean kernel, compiler,
type-checker, Mathlib etc. inside the web browser. It is acceptable to
maintain a client-server arrangement where the more memory and
computation intensive parts of type-checking Lean take place on the
server.

It is a non-goal for the Lean FRO to maintain a single workbench
server that is meant to accommodate all usage globally. The FRO may
choose to maintain a server with a deliberately conservative set of
expectations of usage. For example, the amount of compute or disk
storage might be limited, or saved files, if any, might have a short
lifetime before being garbage-collected. We expect institutional users
to install and maintain their own copies of the service if they want
a full-featured version of the workbench experience.

# Data Design

## Document Structure

- Notebook cells?
- Verso document?

# Architecture Design

## Text Editing Component

We discuss here decisions about what core text editing component we plan to rely on.

### Monaco

[Monaco](https://github.com/microsoft/monaco-editor) is the text editing component developed for VSCode.
It is what lean4web currently uses.

**Advantages**

- Actively developed, institutional support from Microsoft
- Already extremely well tested in its use in lean4web
- Extensive LSP support (document highlights, hovers, folding ranges,
  semantic tokens, inlay hints, completions, diagnostics, signature
  help, code actions, code formatting and extending the protocol with
  custom fields, capabilities, requests and notifications. )
- Lean-specific extensions already implemented in lean4web
- Has [plugin support](https://github.com/yjs/y-monaco/) for collaborative editing
  via a well-known javascript CRDT library.

**Disadvantages**
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

**Other advantages**

- Deliberate support for mobile
- Good accessibility story
- Has first-party support for [collaborative editing](https://codemirror.net/examples/collab/)

**Disadvantages**

- Much less mature LSP support
- Less actively developed, although has been developed since 2007; primarily solo dev


### Decision

We plan to stay with Monaco for the forseeable future, and try to find
workarounds for mixing text and nontextual elements.

## Extensible Interactivity

We want authors to be able to
We assume some kind of Elm/React-like architecture. The author needs to express state update somehow.

- Write state update in lean. It executes on server.
  This is pretty much unworkable. Latency would be too high.
- Write state update in javascript.
  This is what Widgets does today. Downsides: two languages to learn, two build systems to learn.
- Write state update in lean. It executes in the browser…
  - …via compiling a special-purpose DSL.
    This has some of the same disadvantages to writing in javascript, user has to learn other language
    Advantage: could produce idiomatic javascript
  - …via elaborating lean to Expr, and then custom compilation Expr to js
Advantages: tree-shaking happens naturally. Idiomatic mapping of high-level operations to javascript operations.
Disadvantages: Expr has tons of equality reasoning type of stuff (e.g. proof witnesses) in it that is proof-irrelevantly erased by IR time
  - …via compiling lean to LLVM to wasm. (probably emscripten)
  - …via compiling lean to C to wasm. (probably emscripten)
  - …via compile lean to IR to wasm directly
    Extra work here is: understanding wasm format, relearn how C compilation works but do it by hand
  - …via compile lean to something earlier than IR, then compile to idiomatic javascript.
  - …via compiling lean to IR to javascript
    Analyze the IR of reasonably well-behaved pure functions and produce idiomatic state-update javascript functions.
    Disadvantages: might require a lot of work. IR maybe doesn’t have enough type information.
    Advantages: direct FFI arbitrary javascript. More inspectable/debuggable.
    +/-: performance. Javascript slower than wasm for inner loop, but less overhead passing between js/dom manipulations and wasm.


# Evaluation

## Audience
- Developer of verso who already know its internals intimately
- Lean expert
- Mathematician with some lean experience
- Mathematician with no prior lean experience
- Grad student
- Undergrad student
- High school student

## Artifact
- Something that looks like a paper without any real results
- Something that looks like a paper with some stub results
- Something that looks like a paper with some substantial results, maybe some sorrys
- Something that looks like a polished, complete paper with a previously known result
- Something that looks like a polished, complete paper with a new research result

## Milestones

- Github integration
- AI interface
- NNG ported
- New games written
- Usability study
- Metrics dashboard
- Live collaborative editing
- Textbook/resources authored
- Papers published
- Adoption
