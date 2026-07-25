public protocol CaptureStreamGroup:
    AnyObject,
    CapturePlatformConcurrencyContract
{
    var deviceID: CaptureDeviceID { get }
    var streamIDs: [CaptureStreamID] { get }

#if hasFeature(Embedded)
    func start() throws(CaptureDriverError)
    func shutdown() throws(CaptureDriverError)
#else
    func start() async throws(CaptureDriverError)
    func shutdown() async throws(CaptureDriverError)
#endif
}
