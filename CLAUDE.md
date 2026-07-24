# OpenAVFoundationDriver implementation rules

Read `DESIGN.md` completely before changing this package.

- This package owns platform-neutral driver values and protocols only.
- OpenAVFoundationDriver depends on OpenCoreMedia and OpenCoreVideo. It must not
  depend on OpenAVFoundation or a concrete driver.
- Keep protocols small and existential-friendly. Do not use associated types on
  contracts that the heterogeneous provider registry must store.
- Descriptor discovery does not open hardware. Opening, configuration, streaming,
  and shutdown are separate lifecycle boundaries.
- The package does not own the provider registry implementation, Apple-compatible
  facade classes, session graph, output routing, or backpressure queues.
- Keep shared code free of Foundation, Objective-C, Dispatch, JavaScriptKit,
  Darwin, Glibc, camera SDKs, and GPU SDKs.
- Device identity is stable and driver-namespaced. Discovery and configuration
  are capability-based, not camera-model branches.
- Stream payloads use OpenCoreMedia and OpenCoreVideo ownership contracts. Do not
  create a competing sample-buffer or pixel-buffer abstraction.
- Errors are typed and propagated. Do not install a fake provider or silently
  substitute replay data.
- Tests use Swift Testing. Run focused `xcodebuild test` commands with a timeout,
  plus WASM and Embedded builds for shared-source changes.
