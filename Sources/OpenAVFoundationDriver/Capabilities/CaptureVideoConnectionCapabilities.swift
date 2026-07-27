public struct CaptureVideoConnectionCapabilities: Sendable, Hashable {
    public let supportedRotationAngles: [CaptureVideoRotationAngle]
    public let supportedStabilizationModes: [CaptureVideoStabilizationMode]
    public let supportedMirroringModes: [CaptureVideoMirroringMode]

    public init(
        supportedRotationAngles: [CaptureVideoRotationAngle] = [],
        supportedStabilizationModes: [CaptureVideoStabilizationMode] = [],
        supportedMirroringModes: [CaptureVideoMirroringMode] = []
    ) throws(CaptureContractError) {
        try Self.validateUnique(
            supportedRotationAngles,
            error: .duplicateVideoRotationAngle
        )
        try Self.validateUnique(
            supportedStabilizationModes,
            error: .duplicateVideoStabilizationMode
        )
        try Self.validateUnique(
            supportedMirroringModes,
            error: .duplicateVideoMirroringMode
        )
        self.supportedRotationAngles = supportedRotationAngles
        self.supportedStabilizationModes = supportedStabilizationModes
        self.supportedMirroringModes = supportedMirroringModes
    }

    private static func validateUnique<Value: Equatable>(
        _ values: [Value],
        error: CaptureContractError
    ) throws(CaptureContractError) {
        for index in values.indices {
            guard !values[..<index].contains(values[index]) else {
                throw error
            }
        }
    }
}
