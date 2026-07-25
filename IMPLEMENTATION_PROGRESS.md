# OpenAVFoundationDriver Implementation Progress

## Apple semantic trace

- [x] Portable SPI responsibilities are mapped to Apple capture semantics
- [x] Framework-owned graph policy is separated from driver-owned operations
- [x] Remaining event and control contracts are recorded

## Smoke definition

The package smoke path must execute discovery, initial device-event snapshot,
subscription shutdown, device open, validated capability snapshot access,
configuration, one zero-copy `CMSampleBuffer` delivery, stream shutdown, and
device shutdown through protocol existentials. Expected failures must remain
typed and no concrete provider may be installed by the production target.

## Zero-copy invariant

- The driver transfers sample-buffer ownership without materializing payload
  bytes.
- A `CMSampleBuffer` retains its existing `CVPixelBuffer` or block-buffer lease.
- Sink acceptance may retain the sample object but must not duplicate its media
  storage.
- `Array`, `Data`, `String`, per-frame format conversion, and intermediate byte
  collections are not part of the stream contract.
- Any future operation that intentionally copies media must be named as a copy,
  document the allocation boundary, and have an allocation/copy-count test.

## Platform concurrency contract

- Providers, opened handles, streams, event sinks, and sample sinks are
  `Sendable` on Native Swift, WASM, and Embedded Swift.
- Embedded Swift uses synchronous forms of the same semantic operations. This
  execution-shape difference does not imply single-threaded execution and does
  not remove synchronization, ownership, or data-race safety requirements.
- The fixed Swift 6.4 development snapshot and matching Embedded SDK compile the
  callable synchronous lifecycle path with the same `Sendable` boundary.
- The Embedded contract is not a fallback or simulated success path. Concrete
  drivers still perform discovery, configuration, delivery, and shutdown, and
  propagate the same typed driver failures.

## Required implementation

- [x] Validated driver-namespaced identity values
- [x] Explicit all-or-matching discovery selection
- [x] Authorization status and request contracts
- [x] Typed hot-plug initial-snapshot and delta event contract
- [x] Non-dropping event sink and idempotent subscription shutdown
- [x] Validated descriptor and capability snapshots
- [x] Explicit provider-preferred format and validated default configuration
- [x] Provider and opened-handle lifecycle contracts
- [x] Capability-revision-bound device configuration
- [x] `CMSampleBuffer` stream request and sink contracts
- [x] Focus, exposure, white-balance, and zoom capability contracts
- [x] Standard control configurations validated against the same revision
- [x] Namespaced, constrained device-specific control extension
- [x] Explicit stream endpoints and supported concurrent combinations
- [x] Atomic multi-stream handle and stream-group lifecycle contracts
- [x] One-to-one multi-stream sink binding validation
- [x] Explicit stream start and idempotent shutdown
- [x] Existential behavior smoke covering one delivered sample
- [x] Separate `OpenAVFoundationDriverTesting` product
- [x] Reusable discovery/open/configure/lifecycle conformance suite
- [x] Reusable atomic multi-stream group lifecycle conformance
- [x] Reusable event recorder and subscription lifecycle conformance
- [x] Reusable same-`CMSampleBuffer` identity sink
- [x] Callable synchronous Embedded provider and lifecycle contracts
- [x] Identical `Sendable` boundary across Native, WASM, and Embedded
- [x] Native `xcodebuild` behavior tests
- [x] WASM build
- [x] Embedded WASM build
- [x] Cross-target bounded metadata validation without `Set` runtime dependence
- [x] Capability-declared interruption, resume, source-drop, pressure, and
      terminal-failure event contract
- [x] Typed video orientation, stabilization, and mirroring configuration
- [x] Stream-specific validation for video connection policy
- [x] Reusable synchronized stream-event recorder and declared-capability
      conformance validation

## Current work

The shared provider boundary is implemented. A configuration now carries
revision-bound standard and device-specific controls. Capabilities describe
explicit stream endpoints and exact supported concurrent combinations. Group
validation rejects mismatched devices, revisions, formats, combinations, and
sink identities before provider allocation. The separately consumable testing
product exercises discovery, open, configuration, zero-copy delivery, repeated
stream, atomic stream-group, event-subscription, and handle shutdown, and typed
failures.

All duplicate and unordered-equality checks over bounded descriptor, capability,
control, topology, and conformance-suite metadata use ordered array membership
on every target. This preserves typed validation semantics and avoids the fixed
regular WASM SDK's runtime `Set.insert` trap without adding a target-specific
branch.

Stream descriptors now declare the exact runtime event families and video
connection policies that a provider supports. Event-capable streams refine
`CaptureStream` through `CaptureStreamEventSource`; providers that do not
implement this refinement cannot claim event capability. Event sinks receive
ordered typed values outside provider locks, and stream shutdown must clear the
sink before returning. Video orientation, stabilization, and mirroring remain
part of the stream request and fail with field-specific typed errors when the
selected stream does not advertise the requested value.

## Test evidence

- Native:
  `xcodebuild test -scheme OpenAVFoundationDriver-Package
  -destination 'platform=macOS'
  -maximum-test-execution-time-allowance 30
  -only-testing:OpenAVFoundationDriverTests
  SWIFT_EXEC=~/Library/Developer/Toolchains/
  swift-6.4.x-DEVELOPMENT-SNAPSHOT-2026-07-17-a.xctoolchain/usr/bin/swiftc`
  — passed 14 behavior tests with the Swift 6.4 development snapshot compiler on
  2026-07-25 against OpenCoreMedia `07bd447` and OpenCoreVideo `2d528af`.
- Native Thread Sanitizer:
  the same 14 behavior tests passed with `-enableThreadSanitizer YES` and the
  fixed Swift 6.4 development snapshot on 2026-07-25.
- WASM:
  `~/Library/Developer/Toolchains/
  swift-6.4.x-DEVELOPMENT-SNAPSHOT-2026-07-17-a.xctoolchain/usr/bin/swift build
  --swift-sdks-path ~/Library/org.swift.swiftpm/swift-sdks
  --swift-sdk swift-6.4.x-DEVELOPMENT-SNAPSHOT-2026-07-17-a_wasm
  --target OpenAVFoundationDriver`
  and the same command with `--target OpenAVFoundationDriverTesting`
  — both products passed with isolated scratch directories and the matching
  Swift 6.4 development snapshot compiler and SDK on 2026-07-25.
- Embedded WASM:
  `~/Library/Developer/Toolchains/
  swift-6.4.x-DEVELOPMENT-SNAPSHOT-2026-07-17-a.xctoolchain/usr/bin/swift build
  --swift-sdks-path ~/Library/org.swift.swiftpm/swift-sdks
  --swift-sdk swift-6.4.x-DEVELOPMENT-SNAPSHOT-2026-07-17-a_wasm-embedded
  --target OpenAVFoundationDriver`
  and the same command with `--target OpenAVFoundationDriverTesting`
  — both products passed with isolated scratch directories and the matching
  Swift 6.4 development snapshot compiler and SDK on 2026-07-25.
- Embedded callable lifecycle:
  a temporary external WASI executable exercised discovery, the initial topology
  snapshot, open, configuration, one same-identity `CMSampleBuffer` delivery,
  stream shutdown, and handle shutdown through protocol existentials, then
  exited successfully under Node 24 on 2026-07-25. The executable resolved
  OpenCoreMedia `07bd447` and OpenCoreVideo `2d528af`.

## Concrete provider work outside this package

- Concrete replay, browser, V4L2, GStreamer, and Argus providers
- Platform mappings for the implemented control and multi-stream contracts
- Platform mappings for the implemented topology event contract
- Platform mappings for runtime interruption, source-drop, pressure, and video
  connection policy contracts
