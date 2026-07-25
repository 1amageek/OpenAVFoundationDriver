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
        var observedControlIDs: [CaptureDeviceControlID] = []
        observedControlIDs.reserveCapacity(deviceSpecific.count)
        for setting in deviceSpecific {
            guard !observedControlIDs.contains(setting.controlID) else {
                throw .duplicateDeviceControlSetting(setting.controlID)
            }
            observedControlIDs.append(setting.controlID)
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
