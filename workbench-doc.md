In this document we describe our plans to develop a next-generation
mathematical workbench for the Lean theorem prover. It will enable
mathematicians to work and collaborate in an environment that
seamlessly combines familiar, informal mathematical writing with the
correctness assurances of Lean.

# Background

In this section we describe existing projects relevant to the aims of
the Workbench.

## Verso
## Lean4Web ("Live-Lean")

TODO: Discuss client-server architecture.

## Lean4VSCode
## Natural Numbers Game

TODO: Discuss client-server architecture.

## Widgets Framework
## Blueprint

TODO: Discuss role of python scripts checking consistency.

### Zhu's Blueprint Metaprogramming

# Goals

- Installation
  - Zero-install experience for the average user
  - Easy installation experience for institutional user
- Notion of Identity/accounts
  - Administration features
  - Permissions
- Multi-file workspaces
  - UI to assist lakefile construction, dependency management
- Version control integration
- Multiplayer live editing
- Convenient preview of documents
  - Requirements around how fast this is?
    - https://typst.app/play/ sets a high bar for speed
- Inline non-textual elements
  - This constrains implementation choices
- Security
  - Sandboxing
- Mobile experience
- Interactivity
  - Links between documents
  - Transclusions from other documents
  - Diagrams that can be manipulated/rotated/explored by the reader
  - Multiple-choice comprehension-checking quiz questions
  - Exercises that are solved by the reader supplying more lean proof
  - Exercises that are solved by the reader interacting NNG-style
  - Attractively rendered mathematical expressions derived from document content

# Non-Goals

- It is a non-goal to completely replace the ability to install and using Lean normally.

# Design

## Document Structure

- Notebook cells?
- Verso document?

## Extensible Interactivity

We want users to
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
