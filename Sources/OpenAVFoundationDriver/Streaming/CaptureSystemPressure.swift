public struct CaptureSystemPressure: Sendable, Equatable {
    public let level: CaptureSystemPressureLevel
    public let factors: CaptureSystemPressureFactors

    public init(
        level: CaptureSystemPressureLevel,
        factors: CaptureSystemPressureFactors = []
    ) {
        self.level = level
        self.factors = factors
    }
}
