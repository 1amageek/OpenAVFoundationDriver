# OpenAVFoundationDriver

OpenAVFoundationDriver defines the platform-neutral contracts that connect
OpenAVFoundation to separately packaged capture implementations.

The initial contract implementation provides:

- validated driver, device, device-type, media-type, and format identifiers;
- immutable device descriptors and explicit all-or-matching discovery requests;
- authorization results with one status-value representation and typed driver
  operation errors;
- validated dimensions, frame-rate ranges, format descriptors, and capability
  snapshots;
- validated device snapshots that bind descriptors to matching capabilities;
- explicit provider-preferred format selection and validated default
  configuration;
- revision-bound format and frame-rate configuration;
- revision-bound focus, exposure, white-balance, zoom, and device-specific
  control configuration;
- explicit stream endpoints and validated atomic multi-stream groups;
- typed device-topology snapshot and delta events;
- existential-friendly provider and opened-device handle protocols;
- zero-copy `CMSampleBuffer` sink and stream lifecycle contracts;
- a separately consumable provider-conformance testing product;
- `Sendable` provider, handle, stream, and sink contracts on every target;
  operations are asynchronous on Native Swift/WASM and synchronous on Embedded
  Swift without weakening synchronization requirements.

The package does not contain a concrete provider, provider registry, capture
session, or camera-control facade. It defines the extension boundary used by
those separately packaged implementations.

Concrete implementations will live in packages such as:

- `OpenAVFoundationBrowser`
- `OpenAVFoundationV4L2`
- `OpenAVFoundationArgus`
- `OpenAVFoundationReplay`

OpenAVFoundationDriver never contains a default device, synthetic fallback, or
camera-model branch.

## Design

Read [DESIGN.md](DESIGN.md) before adding a public value or protocol.
Use [APPLE_API_TRACE.md](APPLE_API_TRACE.md) to trace each portable driver
responsibility back to Apple capture semantics.

## Build

```bash
xcodebuild test \
  -scheme OpenAVFoundationDriver-Package \
  -destination 'platform=macOS' \
  -maximum-test-execution-time-allowance 30 \
  -only-testing:OpenAVFoundationDriverTests \
  SWIFT_EXEC="$HOME/Library/Developer/Toolchains/swift-6.4.x-DEVELOPMENT-SNAPSHOT-2026-07-17-a.xctoolchain/usr/bin/swiftc"
"$HOME/Library/Developer/Toolchains/swift-6.4.x-DEVELOPMENT-SNAPSHOT-2026-07-17-a.xctoolchain/usr/bin/swift" build \
  --swift-sdks-path "$HOME/Library/org.swift.swiftpm/swift-sdks" \
  --swift-sdk swift-6.4.x-DEVELOPMENT-SNAPSHOT-2026-07-17-a_wasm \
  --target OpenAVFoundationDriver
"$HOME/Library/Developer/Toolchains/swift-6.4.x-DEVELOPMENT-SNAPSHOT-2026-07-17-a.xctoolchain/usr/bin/swift" build \
  --swift-sdks-path "$HOME/Library/org.swift.swiftpm/swift-sdks" \
  --swift-sdk swift-6.4.x-DEVELOPMENT-SNAPSHOT-2026-07-17-a_wasm \
  --target OpenAVFoundationDriverTesting
"$HOME/Library/Developer/Toolchains/swift-6.4.x-DEVELOPMENT-SNAPSHOT-2026-07-17-a.xctoolchain/usr/bin/swift" build \
  --swift-sdks-path "$HOME/Library/org.swift.swiftpm/swift-sdks" \
  --swift-sdk swift-6.4.x-DEVELOPMENT-SNAPSHOT-2026-07-17-a_wasm-embedded \
  --target OpenAVFoundationDriver
"$HOME/Library/Developer/Toolchains/swift-6.4.x-DEVELOPMENT-SNAPSHOT-2026-07-17-a.xctoolchain/usr/bin/swift" build \
  --swift-sdks-path "$HOME/Library/org.swift.swiftpm/swift-sdks" \
  --swift-sdk swift-6.4.x-DEVELOPMENT-SNAPSHOT-2026-07-17-a_wasm-embedded \
  --target OpenAVFoundationDriverTesting
```
