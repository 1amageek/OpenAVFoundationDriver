# OpenAVFoundationDriver Design

## Status

This document is the normative design for the package. The first implementation
slice now provides validated identity, discovery, authorization, format
capability, capability-snapshot, typed-error, provider, and opened-handle
contracts. Revision-bound configuration and zero-copy sample-stream contracts
are also implemented. It does not provide a concrete provider, registry, capture
session, or hardware adapter. Contract tests are not evidence of hardware
capture support.

## Implementation status

| Area | Status |
|---|---|
| Typed identifiers | Implemented |
| Device descriptors and explicit device-type selection | Implemented |
| Authorization values | Implemented |
| Format, capability, and validated device snapshots | Implemented |
| Explicit provider-preferred format selection | Implemented |
| Typed contract and driver errors | Implemented |
| Provider discovery and open protocol | Implemented |
| Opened-device capability and shutdown protocol | Implemented |
| Revision-bound format and frame-rate configuration | Implemented |
| Zero-copy sample streaming contract | Implemented |
| Concrete providers and registry | Outside this package |

## Purpose

OpenAVFoundationDriver is the dependency-inversion boundary between the
Apple-compatible capture graph and platform-specific capture mechanisms.

```text
OpenAVFoundation
        │ depends on contracts
        ▼
OpenAVFoundationDriver
        ▲
        │ implemented by
Browser / Embedded board / V4L2 / Argus / Replay packages
```

The package lets OpenAVFoundation discover and operate devices without importing
browser globals, operating-system APIs, vendor SDKs, or camera-model logic.

## Responsibility

OpenAVFoundationDriver owns:

- driver, device, media-type, and format identifiers;
- immutable device descriptors and capability revisions;
- discovery request values;
- device open and configuration request values;
- stream request and delivery disposition values;
- typed driver errors;
- provider, opened-device, stream, and sample-sink protocols;
- explicit shutdown contracts for opened resources.

OpenAVFoundationDriver does not own:

- the provider registry implementation;
- `AVCaptureDevice`, `AVCaptureSession`, or other Apple-compatible facade types;
- input, output, connection, or session graph policy;
- output fan-out or output-specific backpressure queues;
- `CMTime`, `CMSampleBuffer`, or their readiness semantics;
- `CVPixelBuffer`, plane layout, or storage ownership;
- concrete browser, Linux, Jetson, replay, or board drivers;
- recognition, inference, Manas, or actuator control.

## Dependency direction

```text
OpenCoreVideo
      ▲
      │
OpenCoreMedia
      ▲
      │
OpenAVFoundationDriver
      ▲
      ├── OpenAVFoundation
      ├── OpenAVFoundationBrowser
      ├── OpenAVFoundationV4L2
      ├── OpenAVFoundationArgus
      └── OpenAVFoundationReplay
```

OpenAVFoundationDriver may depend on OpenCoreMedia and OpenCoreVideo.
OpenCoreMedia and OpenCoreVideo must never depend on this package.
OpenAVFoundationDriver must never depend on OpenAVFoundation.

## Planned contract groups

### Identity and discovery

The first group contains:

- `CaptureDriverID`;
- `CaptureDeviceID`;
- `CaptureMediaTypeID`;
- `CaptureDeviceTypeID`;
- `CaptureDevicePosition`;
- `CaptureDeviceDescriptor`;
- `CaptureDiscoveryRequest`;
- `CaptureDeviceProvider`.

A descriptor is an immutable value. Discovery returns descriptors and never opens
hardware. A device ID is semantically the combination of a driver namespace and a
stable driver-local identifier.

`CaptureDeviceTypeSelection.all` explicitly requests every device type.
`CaptureDeviceTypeSelection(matching:)` requires at least one unique device type.
Providers use `includes(_:)` rather than assigning their own meaning to an empty
array. The OpenAVFoundation facade maps Apple's nonempty DiscoverySession device
type list to the matching selection.

Authorization requests return the resulting `CaptureAuthorizationStatus`.
Denied and restricted outcomes are values. A provider throws only when it cannot
complete the authorization operation. Authorization errors remain available for
later open, configuration, and start operations that require granted access.

The provider protocol remains existential-friendly so a registry can store
heterogeneous providers without backend-specific type erasure.

### Capabilities and configuration

The second group contains:

- dimensions and frame-rate values;
- device format descriptors;
- control capability values;
- `CaptureDeviceCapabilities`;
- `CaptureDeviceSnapshot`;
- `CaptureDeviceConfiguration`;
- `CaptureDeviceHandle`.

The opened handle has reference identity and an ordered lifecycle. Concrete
implementations normally use an actor because open, configuration, and shutdown
may perform I/O and their order matters.

An opened handle returns a validated `CaptureDeviceSnapshot`, not independent
descriptor and capability values. Snapshot construction rejects mismatched device
identity and capability revision before the pair crosses the driver boundary.

Configuration is validated against a capability revision. A stale configuration,
unsupported control, disconnected device, or backend application failure is a
typed failure rather than a no-op.

Capabilities identify one preferred format explicitly. The framework may use
`preferredConfiguration()` for its initial Apple-style session negotiation
without treating array order as an undocumented fallback. The preferred format
must exist in the same validated capability snapshot.

### Streaming

The third group contains:

- `CaptureStreamRequest`;
- `CaptureSampleDisposition`;
- `CaptureSampleSink`;
- `CaptureStream`.

A stream delivers leased `CMSampleBuffer` values. Image samples retain their
`CVPixelBuffer` storage lease. The driver does not copy or convert payloads merely
to cross the contract boundary.

The sample sink is a nonblocking offer boundary suitable for capture threads and
Embedded systems. It returns whether the sample was accepted, dropped, or the
stream should stop. OpenAVFoundation owns the bounded queues and downstream
fan-out policy.

These streaming declarations use OpenCoreMedia's reviewed `CMSampleBuffer`
ownership surface. The driver package does not introduce a competing sample
type.

### Shutdown

Opened handles and streams expose explicit shutdown. Shutdown is idempotent at the
framework boundary, releases every retained lease, finishes delivery, and
propagates backend failure. Deinitialization is not the primary shutdown path.
Contract tests call shutdown repeatedly and require subsequent resource access to
fail explicitly.

## Ownership

```text
OpenAVFoundation registry
    └── retains providers

AVCaptureDevice facade
    └── retains descriptor + provider reference
        └── does not retain an opened hardware handle

AVCaptureSession while running
    ├── owns opened CaptureDeviceHandle
    ├── owns CaptureStream
    └── owns output routing and bounded queues

CMSampleBuffer
    └── retains payload lease
        └── CVPixelBuffer retains storage lease
```

The provider does not transfer a process-global running stream into a session.
OpenAVFoundation opens the selected source through the provider when the session
starts and shuts it down when the session stops or fails.

## Concurrency

- Registry membership is short in-memory state and belongs to OpenAVFoundation.
- Provider discovery and open operations may suspend.
- Opened handle and stream lifecycle is ordered and may suspend.
- Sample offer is synchronous, bounded, and nonblocking.
- No event is emitted while holding a mutex.
- No `await` occurs inside `withLock`.
- Protocols and shared values are `Sendable`.
- `@unchecked Sendable` is not permitted.

The preceding asynchronous model applies to Native Swift and WASM. Embedded
Swift 6.3.1 cannot currently lower calls to asynchronous typed-throwing protocol
requirements. Under `hasFeature(Embedded)`, providers, opened handles, and
streams therefore expose synchronous owner-isolated forms of the same semantic
operations, and the concurrency marker does not require `Sendable`.
`CaptureSampleSink` inherits `AnyObject` directly on Embedded because the
Swift 6.3.1 Embedded compiler cannot pass its existential through the otherwise
empty `CapturePlatformConcurrencyContract` inheritance boundary. Native Swift
and WASM retain the `Sendable` marker. This is a platform execution contract,
not a success fallback: concrete implementations must perform the operation and
preserve every typed failure.

## Platform model

The shared package depends only on the Swift standard library, OpenCoreMedia, and
OpenCoreVideo.

| Platform | Composition |
|---|---|
| Browser WASM | Browser provider installed during application startup |
| Non-browser WASM | Host-import or explicit replay provider |
| Embedded Swift | Statically linked board or sensor provider |
| Linux | V4L2 or GStreamer provider |
| Jetson | libargus or GStreamer provider |
| Tests | Explicit replay provider |

Dynamic plugin loading is not required. Embedded firmware can construct a fixed
provider set at startup.

## Error contract

The typed error surface distinguishes:

- provider unavailable;
- authorization denied or restricted;
- unknown, disconnected, suspended, or busy device;
- stale capability revision;
- unsupported format or control;
- configuration failure;
- open or start failure;
- stream failure;
- buffer exhaustion;
- stop or shutdown failure;
- contract violation.

Errors retain driver and device identity where applicable. No error path returns a
synthetic descriptor, empty successful sample, or replay fallback.

## Planned source layout

```text
Sources/OpenAVFoundationDriver/
├── Identity/
├── Discovery/
├── Capabilities/
├── Configuration/
├── Streaming/
├── Errors/
└── OpenAVFoundationDriver.swift
```

Each file contains one primary public type where practical.

## Implementation sequence

1. Implement typed identifiers, positions, descriptors, and discovery requests.
   **Complete.**
2. Implement typed driver errors. **Complete.**
3. Implement the provider discovery and open protocol. **Complete.**
4. Implement format, capability, snapshot, and configuration values.
   **Complete for format and frame-rate selection.**
5. Implement the opened-device lifecycle protocol. **Capability access and
   shutdown complete; revision-bound configuration complete.**
6. After `CMSampleBuffer` exists, implement stream request, sink, stream, and
   delivery disposition contracts.
7. Implement a separate replay driver package for behavioral contract tests.
8. Validate native, WASM, and Embedded builds and integrate with
   OpenAVFoundation discovery.

Declaration presence, import tests, or a replay-only path are not driver
completion.
