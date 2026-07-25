public struct CaptureDeviceControls: Sendable, Hashable {
    public let focus: CaptureFocusConfiguration?
    public let exposure: CaptureExposureConfiguration?
    public let whiteBalance: CaptureWhiteBalanceConfiguration?
    public let zoom: CaptureZoomConfiguration?
    public let deviceSpecific: [CaptureDeviceControlSetting]

    public init(
        focus: CaptureFocusConfiguration? = nil,
        exposure: CaptureExposureConfiguration? = nil,
        whiteBalance: CaptureWhiteBalanceConfiguration? = nil,
        zoom: CaptureZoomConfiguration? = nil,
        deviceSpecific: [CaptureDeviceControlSetting] = []
    ) throws(CaptureContractError) {
        var observedControlIDs: Set<CaptureDeviceControlID> = []
        for setting in deviceSpecific {
            guard observedControlIDs.insert(setting.controlID).inserted else {
                throw .duplicateDeviceControlSetting(setting.controlID)
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
