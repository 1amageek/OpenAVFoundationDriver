/// A provider that can observe a filtered device topology without polling.
public protocol CaptureDeviceEventProvider: CaptureDeviceProvider {
#if hasFeature(Embedded)
    func deviceEventSubscription(
        matching request: CaptureDiscoveryRequest,
        sink: any CaptureDeviceEventSink
    ) throws(CaptureDriverError) -> any CaptureDeviceEventSubscription
#else
    func deviceEventSubscription(
        matching request: CaptureDiscoveryRequest,
        sink: any CaptureDeviceEventSink
    ) async throws(CaptureDriverError) -> any CaptureDeviceEventSubscription
#endif
}
