<!-- berrywiki
id: 0196a000-0000-7000-8000-000000000005
parent: 0196a000-0000-7000-8000-000000000001
position: 40
kind: page
tags:
  - setup
archived: false
-->

# Setup

Four approaches (full text in AsciiDoc `docs/onboarding/SETUP.adoc`):

1. **AI** — read `0-AI-MANIFEST.deed` then `STATE.deed`; Zig 0.15.1; no Core checker.
2. **Raw** — `zig build test` in `src/interface/ffi`.
3. **Just** — `just deps`, `just test-smoke`, `just spec-tests`.
4. **Launcher** — there is no desktop launcher; the CLI is `just`.
