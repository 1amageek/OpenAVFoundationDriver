public protocol CaptureDeviceProvider: CapturePlatformConcurrencyContract {
    var driverID: CaptureDriverID { get }

    /// Returns the current authorization state without prompting the user.
#if hasFeature(Embedded)
    func authorizationStatus(
        for mediaType: CaptureMediaTypeID
    ) -> CaptureAuthorizationStatus
#else
    func authorizationStatus(
        for mediaType: CaptureMediaTypeID
    ) async -> CaptureAuthorizationStatus
#endif

    /// Requests access and returns the resulting authorization state.
    ///
    /// Denied and restricted authorization are returned as values. Implementations
    /// throw only when the provider cannot complete the authorization operation.
#if hasFeature(Embedded)
    func requestAccess(
        for mediaType: CaptureMediaTypeID
    ) throws(CaptureDriverError) -> CaptureAuthorizationStatus
#else
    func requestAccess(
        for mediaType: CaptureMediaTypeID
    ) async throws(CaptureDriverError) -> CaptureAuthorizationStatus
#endif

    /// Discovers matching descriptors without opening their hardware resources.
#if hasFeature(Embedded)
    func devices(
        matching request: CaptureDiscoveryRequest
    ) throws(CaptureDriverError) -> [CaptureDeviceDescriptor]
#else
    func devices(
        matching request: CaptureDiscoveryRequest
    ) async throws(CaptureDriverError) -> [CaptureDeviceDescriptor]
#endif

    /// Opens the selected device and returns its ordered lifecycle handle.
#if hasFeature(Embedded)
    func deviceHandle(
        for deviceID: CaptureDeviceID
    ) throws(CaptureDriverError) -> any CaptureDeviceHandle
#else
    func deviceHandle(
        for deviceID: CaptureDeviceID
    ) async throws(CaptureDriverError) -> any CaptureDeviceHandle
#endif
}
