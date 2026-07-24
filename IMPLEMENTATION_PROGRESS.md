# OpenAVFoundationDriver Implementation Progress

## Apple semantic trace

- [x] Portable SPI responsibilities are mapped to Apple capture semantics
- [x] Framework-owned graph policy is separated from driver-owned operations
- [x] Remaining event and control contracts are recorded

## Smoke definition

The package smoke path must execute discovery, device open, validated capability
snapshot access, configuration, one zero-copy `CMSampleBuffer` delivery, stream
shutdown, and device shutdown through protocol existentials. Expected failures
must remain typed and no concrete provider may be installed by the production
target.

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

- Native Swift and WASM providers, opened handles, streams, and sinks are
  `Sendable`; provider and lifecycle operations are asynchronous.
- Embedded Swift uses the same semantic operations through synchronous,
  owner-isolated protocol requirements. Its `CaptureSampleSink` inherits
  `AnyObject` directly. The fixed Swift 6.4 development snapshot and matching
  Embedded SDK compile the callable synchronous lifecycle path. Native Swift and
  WASM keep the `Sendable` marker. An asynchronous Embedded existential path is
  not part of the verified contract.
- The Embedded contract is not a fallback or simulated success path. Concrete
  drivers still perform discovery, configuration, delivery, and shutdown, and
  propagate the same typed driver failures.

## Required implementation

- [x] Validated driver-namespaced identity values
- [x] Explicit all-or-matching discovery selection
- [x] Authorization status and request contracts
- [x] Validated descriptor and capability snapshots
- [x] Explicit provider-preferred format and validated default configuration
- [x] Provider and opened-handle lifecycle contracts
- [x] Capability-revision-bound device configuration
- [x] `CMSampleBuffer` stream request and sink contracts
- [x] Explicit stream start and idempotent shutdown
- [x] Existential behavior smoke covering one delivered sample
- [x] Callable owner-isolated Embedded provider and lifecycle contracts
- [x] Native `xcodebuild` behavior tests
- [x] WASM build
- [x] Embedded WASM build

## Current work

The configuration and streaming contract slice is implemented. The behavior
smoke opens a device, validates and applies a revision-bound configuration,
starts a stream, delivers the same sample-buffer object to the sink, shuts down
the stream twice, and shuts down the device. Native behavior tests and clean
WASM and Embedded WASM builds complete the first smoke slice.

## Test evidence

- Native:
  `xcodebuild test -scheme OpenAVFoundationDriver -destination 'platform=macOS'
  -maximum-test-execution-time-allowance 30
  -only-testing:OpenAVFoundationDriverTests
  SWIFT_EXEC=~/Library/Developer/Toolchains/swift-latest.xctoolchain/usr/bin/swiftc`
  — passed 6 behavior tests with the Swift 6.4 development snapshot compiler on
  2026-07-25.
- WASM:
  `~/Library/Developer/Toolchains/swift-latest.xctoolchain/usr/bin/swift build
  --swift-sdks-path ~/Library/org.swift.swiftpm/swift-sdks
  --swift-sdk swift-6.4.x-DEVELOPMENT-SNAPSHOT-2026-07-17-a_wasm
  --target OpenAVFoundationDriver`
  — passed after `swift package clean` with the matching Swift 6.4 development
  snapshot compiler and SDK on 2026-07-25.
- Embedded WASM:
  `~/Library/Developer/Toolchains/swift-latest.xctoolchain/usr/bin/swift build
  --swift-sdks-path ~/Library/org.swift.swiftpm/swift-sdks
  --swift-sdk swift-6.4.x-DEVELOPMENT-SNAPSHOT-2026-07-17-a_wasm-embedded
  --target OpenAVFoundationDriver`
  — passed after `swift package clean` with the matching Swift 6.4 development
  snapshot compiler and SDK on 2026-07-25.

## Deferred after smoke

- Camera controls such as focus, exposure, white balance, and zoom
- Concrete replay, browser, V4L2, GStreamer, and Argus providers
- Multi-stream negotiation and device-specific controls
- Provider conformance suite distributed as a separate testing product
