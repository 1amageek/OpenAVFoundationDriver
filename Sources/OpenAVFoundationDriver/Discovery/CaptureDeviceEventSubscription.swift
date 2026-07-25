public protocol CaptureDeviceEventSubscription:
    AnyObject,
    CapturePlatformConcurrencyContract
{
    var driverID: CaptureDriverID { get }

    /// Starts observation and emits exactly one initial snapshot before deltas.
#if hasFeature(Embedded)
    func start() throws(CaptureDriverError)
#else
    func start() async throws(CaptureDriverError)
#endif

    /// Stops observation. Repeated calls succeed without additional side effects.
#if hasFeature(Embedded)
    func shutdown() throws(CaptureDriverError)
#else
    func shutdown() async throws(CaptureDriverError)
#endif
}
