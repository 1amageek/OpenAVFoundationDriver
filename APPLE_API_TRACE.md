# Apple AVFoundation Driver Semantic Trace

## Baseline

`OpenAVFoundationDriver` is not an Apple API compatibility module. It is the
portable service-provider interface behind the compatibility module. This trace
records which Apple capture semantics each driver contract must preserve.

- Review date: 2026-07-24
- SDK: macOS 27.0 from the active Xcode beta
- Apple evidence: `AVCaptureDevice.h`, `AVCaptureInput.h`,
  `AVCaptureOutputBase.h`, `AVCaptureSession.h`, and
  `AVCaptureVideoDataOutput.h`

## Semantic trace

| Apple capture responsibility | Driver contract | Status | Remaining contract work |
|---|---|---|---|
| Authorization | Provider status and request operations | Implemented | Platform adapters |
| Device discovery | Typed discovery request and immutable descriptor | Implemented | Hot-plug event contract |
| Stable device identity | Driver namespace plus local device ID | Implemented | None in the shared SPI |
| Format discovery | Revisioned capability snapshot | Implemented | Control capability expansion |
| Device configuration | Revision-bound format and frame-rate request | Implemented | Focus, exposure, zoom, and orientation values |
| Device open/shutdown | Ordered handle lifecycle | Implemented | Interruption/recovery events |
| Sample production | `CMSampleBuffer` sink offer | Implemented | Sequence metadata and observable drops |
| Backpressure | Synchronous disposition value | Partial | Bounded framework fan-out policy belongs in OpenAVFoundation |
| Runtime failure | Typed operation and driver errors | Implemented | Asynchronous event channel |

## Boundary

The SPI does not own Apple-named facade types, graph policy, output fan-out, or a
concrete driver. Concrete Apple, browser, Embedded, V4L2, and Jetson packages
must implement these contracts without introducing another pixel-buffer or
sample-buffer abstraction.
