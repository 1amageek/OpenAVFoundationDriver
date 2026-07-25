public struct CaptureNormalizedPoint: Sendable, Hashable {
    public let x: Double
    public let y: Double

    public init(
        x: Double,
        y: Double
    ) throws(CaptureContractError) {
        guard x.isFinite,
              y.isFinite,
              (0 ... 1).contains(x),
              (0 ... 1).contains(y) else {
            throw .invalidNormalizedPoint(x: x, y: y)
        }

        self.x = x
        self.y = y
    }
}
