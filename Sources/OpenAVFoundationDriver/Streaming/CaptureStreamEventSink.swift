public protocol CaptureStreamEventSink:
    AnyObject,
    CapturePlatformConcurrencyContract
{
    /// Receives ordered source events without taking ownership of media bytes.
    ///
    /// A terminal failure is the last event. Providers must not invoke this
    /// method while holding a provider state lock.
    func offer(
        _ event: CaptureStreamEvent
    ) -> CaptureStreamEventDisposition
}
