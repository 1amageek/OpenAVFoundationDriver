# Apple AVFoundation Driver Semantic Trace

## Baseline

`OpenAVFoundationDriver` is not an Apple API compatibility module. It is the
portable service-provider interface behind the compatibility module. This trace
records which Apple capture semantics each driver contract must preserve.

- Review date: 2026-07-25
- SDK: macOS 27.0 from the active Xcode beta
- Apple evidence: `AVCaptureDevice.h`, `AVCaptureInput.h`,
  `AVCaptureOutputBase.h`, `AVCaptureSession.h`, and
  `AVCaptureVideoDataOutput.h`

## Semantic trace

| Apple capture responsibility | Driver contract | Status | Remaining contract work |
|---|---|---|---|
| Authorization | Provider status and request operations | Implemented | Platform adapters |
| Device discovery | Typed discovery request and immutable descriptor | Implemented | Platform adapters |
| Hot-plug observation | Initial snapshot plus connected/updated/disconnected deltas | Implemented | Platform adapters |
| Stable device identity | Driver namespace plus local device ID | Implemented | None in the shared SPI |
| Format discovery | Revisioned capability snapshot | Implemented | Platform adapters |
| Device configuration | Revision-bound format, frame-rate, and control request | Implemented | Platform adapters |
| Focus | Mode, normalized lens position, normalized point | Implemented | Platform adapters |
| Exposure | Mode, `CMTime` duration, ISO, normalized point | Implemented | Platform adapters |
| White balance | Mode and RGB device gains | Implemented | Platform adapters |
| Zoom | Capability-bounded zoom factor | Implemented | Platform adapters |
| Device-specific configuration | Namespaced constrained scalar values | Implemented | Provider-owned mappings |
| Multiple media streams | Explicit endpoints and supported combinations | Implemented | Concrete multi-stream providers |
| Device open/shutdown | Ordered handle lifecycle | Implemented | Platform interruption adapters |
| Sample production | `CMSampleBuffer` sink offer | Implemented | Sequence metadata and observable drops |
| Backpressure | Synchronous disposition value | Implemented | Bounded framework fan-out policy belongs in OpenAVFoundation |
| Runtime failure | Typed operation and driver errors | Implemented | Platform adapters |

## Reviewed Apple behavior

Apple documents that a device may provide one or more streams and that callers
must query control support before setting focus, exposure, white balance, or
zoom. Apple focus modes are locked, one-shot auto, and continuous auto; exposure
adds custom duration and ISO; white balance provides locked, automatic, and
continuous automatic modes. Apple virtual devices expose constituent devices
and ordered zoom switch-over factors.

The portable SPI preserves those capability and setting semantics without
copying Objective-C locking, notifications, `CGPoint`, `NSNumber`, or native
device objects into WASM and Embedded targets. Multi-stream endpoints are
provider-defined rather than assuming Apple's virtual-camera topology.

## Boundary

The SPI does not own Apple-named facade types, graph policy, output fan-out, or a
concrete driver. Concrete Apple, browser, Embedded, V4L2, and Jetson packages
must implement these contracts without introducing another pixel-buffer or
sample-buffer abstraction.
