public struct CaptureVideoConnectionConfiguration: Sendable, Hashable {
    public let rotationAngle: CaptureVideoRotationAngle?
    public let stabilizationMode: CaptureVideoStabilizationMode?
    public let mirroringMode: CaptureVideoMirroringMode?

    public init(
        rotationAngle: CaptureVideoRotationAngle? = nil,
        stabilizationMode: CaptureVideoStabilizationMode? = nil,
        mirroringMode: CaptureVideoMirroringMode? = nil
    ) {
        self.rotationAngle = rotationAngle
        self.stabilizationMode = stabilizationMode
        self.mirroringMode = mirroringMode
    }

    public static let unchanged = Self()
}
