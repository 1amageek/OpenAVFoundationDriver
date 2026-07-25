public struct CaptureVideoConnectionCapabilities: Sendable, Hashable {
    public let supportedOrientations: [CaptureVideoOrientation]
    public let supportedStabilizationModes: [CaptureVideoStabilizationMode]
    public let supportedMirroringModes: [CaptureVideoMirroringMode]

    public init(
        supportedOrientations: [CaptureVideoOrientation] = [],
        supportedStabilizationModes: [CaptureVideoStabilizationMode] = [],
        supportedMirroringModes: [CaptureVideoMirroringMode] = []
    ) throws(CaptureContractError) {
        try Self.validateUnique(
            supportedOrientations,
            error: .duplicateVideoOrientation
        )
        try Self.validateUnique(
            supportedStabilizationModes,
            error: .duplicateVideoStabilizationMode
        )
        try Self.validateUnique(
            supportedMirroringModes,
            error: .duplicateVideoMirroringMode
        )
        self.supportedOrientations = supportedOrientations
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
