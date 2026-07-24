public protocol CaptureDeviceHandle:
    AnyObject,
    CapturePlatformConcurrencyContract
{
    /// Returns a descriptor and capability pair validated as one snapshot.
#if hasFeature(Embedded)
    func snapshot() throws(CaptureDriverError) -> CaptureDeviceSnapshot
#else
    func snapshot() async throws(CaptureDriverError) -> CaptureDeviceSnapshot
#endif

    /// Applies a revision-bound configuration and returns the resulting snapshot.
#if hasFeature(Embedded)
    func configure(
        _ configuration: CaptureDeviceConfiguration
    ) throws(CaptureDriverError) -> CaptureDeviceSnapshot
#else
    func configure(
        _ configuration: CaptureDeviceConfiguration
    ) async throws(CaptureDriverError) -> CaptureDeviceSnapshot
#endif

    /// Creates a stopped stream that retains the supplied sink.
#if hasFeature(Embedded)
    func stream(
        for request: CaptureStreamRequest,
        sink: any CaptureSampleSink
    ) throws(CaptureDriverError) -> any CaptureStream
#else
    func stream(
        for request: CaptureStreamRequest,
        sink: any CaptureSampleSink
    ) async throws(CaptureDriverError) -> any CaptureStream
#endif

    /// Releases the opened device. Repeated calls must succeed without side effects.
#if hasFeature(Embedded)
    func shutdown() throws(CaptureDriverError)
#else
    func shutdown() async throws(CaptureDriverError)
#endif
}
