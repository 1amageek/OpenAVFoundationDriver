#if hasFeature(Embedded)
public protocol CaptureDeviceEventSink: AnyObject {
    /// Offers a topology event synchronously without blocking provider I/O.
    func offer(_ event: CaptureDeviceEvent) -> CaptureDeviceEventDisposition
}
#else
public protocol CaptureDeviceEventSink:
    AnyObject,
    CapturePlatformConcurrencyContract
{
    /// Offers a topology event synchronously without blocking provider I/O.
    func offer(_ event: CaptureDeviceEvent) -> CaptureDeviceEventDisposition
}
#endif
