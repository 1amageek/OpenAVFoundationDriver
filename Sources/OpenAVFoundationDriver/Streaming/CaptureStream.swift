public protocol CaptureStream:
    AnyObject,
    CapturePlatformConcurrencyContract
{
    var deviceID: CaptureDeviceID { get }

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
