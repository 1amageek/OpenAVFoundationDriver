public struct CaptureProviderOpenResult: CapturePlatformConcurrencyContract {
    public let handle: any CaptureDeviceHandle
    public let snapshot: CaptureDeviceSnapshot

    public init(
        handle: any CaptureDeviceHandle,
        snapshot: CaptureDeviceSnapshot
    ) {
        self.handle = handle
        self.snapshot = snapshot
    }
}
