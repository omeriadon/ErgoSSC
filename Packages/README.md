# Open source packages

Copied into the project so the app builds with no network, as the challenge is judged offline. Each keeps its own licence file.

| Package | By | Licence | From |
|---|---|---|---|
| [Defaults](https://github.com/sindresorhus/Defaults) | Sindre Sorhus | MIT | 9.0.9 (`00a7465`) |
| [FuzzyMatch](https://github.com/ordo-one/FuzzyMatch) | Ordo One | Apache 2.0 | 1.4.0 (`ea09aa7`) |

## Changes from the originals

- **Defaults:** the macros (`DefaultsMacros`, `DefaultsMacrosDeclarations`) and their tests are removed, along with the swift-syntax dependency they needed. The app doesn't use them.
- **FuzzyMatch:** the benchmark data, benchmarks, comparisons, examples and documentation are removed. The library's sources are unchanged.
