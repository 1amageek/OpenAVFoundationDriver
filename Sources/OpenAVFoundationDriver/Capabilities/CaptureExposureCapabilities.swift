public struct CaptureExposureCapabilities: Sendable, Hashable {
    public let supportedModes: [CaptureExposureMode]
    public let durationRange: CaptureExposureDurationRange?
    public let isoRange: CaptureScalarRange?
    public let supportsPointOfInterest: Bool

    public init(
        supportedModes: [CaptureExposureMode],
        durationRange: CaptureExposureDurationRange? = nil,
        isoRange: CaptureScalarRange? = nil,
        supportsPointOfInterest: Bool = false
    ) throws(CaptureContractError) {
        guard !supportedModes.isEmpty else {
            throw .missingControlModes(.exposure)
        }

        var observedModes: Set<CaptureExposureMode> = []
        for mode in supportedModes {
            guard observedModes.insert(mode).inserted else {
                throw .duplicateControlMode(.exposure)
            }
        }

        self.supportedModes = supportedModes
        self.durationRange = durationRange
        self.isoRange = isoRange
        self.supportsPointOfInterest = supportsPointOfInterest
    }
}
