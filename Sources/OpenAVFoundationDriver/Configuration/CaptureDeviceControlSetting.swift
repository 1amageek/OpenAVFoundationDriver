public struct CaptureDeviceControlSetting: Sendable, Hashable {
    public let controlID: CaptureDeviceControlID
    public let value: CaptureDeviceControlValue

    public init(
        controlID: CaptureDeviceControlID,
        value: CaptureDeviceControlValue
    ) {
        self.controlID = controlID
        self.value = value
    }
}
