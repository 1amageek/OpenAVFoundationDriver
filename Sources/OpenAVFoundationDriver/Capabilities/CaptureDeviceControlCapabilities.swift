public struct CaptureDeviceControlCapabilities: Sendable, Hashable {
    public let focus: CaptureFocusCapabilities?
    public let exposure: CaptureExposureCapabilities?
    public let whiteBalance: CaptureWhiteBalanceCapabilities?
    public let zoom: CaptureZoomCapabilities?
    public let deviceSpecific: [CaptureDeviceControlDescriptor]

    public init(
        focus: CaptureFocusCapabilities? = nil,
        exposure: CaptureExposureCapabilities? = nil,
        whiteBalance: CaptureWhiteBalanceCapabilities? = nil,
        zoom: CaptureZoomCapabilities? = nil,
        deviceSpecific: [CaptureDeviceControlDescriptor] = []
    ) throws(CaptureContractError) {
        var observedControlIDs: Set<CaptureDeviceControlID> = [
            .focus,
            .exposure,
            .whiteBalance,
            .zoom
        ]
        for descriptor in deviceSpecific {
            guard observedControlIDs.insert(descriptor.controlID).inserted else {
                throw .duplicateDeviceControlID(descriptor.controlID)
            }
        }

        self.focus = focus
        self.exposure = exposure
        self.whiteBalance = whiteBalance
        self.zoom = zoom
        self.deviceSpecific = deviceSpecific
    }

    private init() {
        focus = nil
        exposure = nil
        whiteBalance = nil
        zoom = nil
        deviceSpecific = []
    }

    public static let none = Self()
}
