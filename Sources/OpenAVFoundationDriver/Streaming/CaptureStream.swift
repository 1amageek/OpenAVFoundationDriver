public protocol CaptureStream:
    AnyObject,
    CapturePlatformConcurrencyContract
{
    var deviceID: CaptureDeviceID { get }
    var eventCapabilities: CaptureStreamEventCapabilities { get }

    /// Installs or clears the event sink while the stream is stopped.
    ///
    /// Implementations that advertise event capabilities must retain the sink
    /// until shutdown and invoke it only outside provider state locks.
    func setEventSink(
        _ sink: (any CaptureStreamEventSink)?
    ) throws(CaptureDriverError)

#if hasFeature(Embedded)
    func start() throws(CaptureDriverError)
#else
    func start() async throws(CaptureDriverError)
#endif

    /// Stops delivery and releases stream resources. Repeated calls are idempotent.
#if hasFeature(Embedded)
    func shutdown() throws(CaptureDriverError)
#else
    func shutdown() async throws(CaptureDriverError)
#endif
}

public extension CaptureStream {
    var eventCapabilities: CaptureStreamEventCapabilities {
        []
    }

    func setEventSink(
        _ sink: (any CaptureStreamEventSink)?
    ) throws(CaptureDriverError) {
        guard sink == nil else {
            throw .unsupportedStreamEvents(deviceID)
        }
    }
}
