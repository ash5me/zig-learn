# Zig Learn

A small Zig learning repository focused on beginner-friendly examples, language fundamentals, and unit tests.

This project is organized around a single `01-basics` folder containing short programs that demonstrate core Zig concepts such as:

- basic printing and value types
- arrays and slices
- structs, enums, and unions
- functions and control flow
- error handling
- allocation and ownership basics
- strings and testing

## Project structure

```text
zig-learn/
├── README.md
├── 01-basics/
│   ├── allocator.zig
│   ├── array.zig
│   ├── error.zig
│   ├── hello.zig
│   ├── sample_test.zig
│   ├── string.zig
│   ├── struct.zig
│   ├── test_fail.zig
│   └── test_pass.zig
└── dist/
```

## Prerequisites

- Zig 0.16 or newer

## Running examples

Run a program directly with Zig:

```bash
zig run 01-basics/hello.zig
```

Example commands for the rest of the learning files:

```bash
zig run 01-basics/array.zig
zig run 01-basics/error.zig
zig run 01-basics/struct.zig
```

## Running tests

This repo includes both passing and failing sample tests to practice Zig test patterns:

```bash
zig test 01-basics/sample_test.zig
zig test 01-basics/test_pass.zig
zig test 01-basics/test_fail.zig
```

You can also run the allocator and other concept files as test targets:

```bash
zig test 01-basics/allocator.zig
```

## Notes

- Most files are intentionally small and focused on one topic.
- Several examples contain commented-out alternatives or exercises so they can be used as learning prompts.
- The goal is to explore Zig syntax and idioms in a straightforward, hands-on way.

## Learning path

Start with these files in order:

1. `01-basics/hello.zig` — basic syntax and printing
2. `01-basics/array.zig` — arrays, slices, and iteration
3. `01-basics/struct.zig` — structs, enums, and methods
4. `01-basics/error.zig` — error handling
5. `01-basics/allocator.zig` — memory allocation concepts
6. `01-basics/sample_test.zig` — Zig test examples
