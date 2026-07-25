public struct CaptureVideoConnectionConfiguration: Sendable, Hashable {
    public let orientation: CaptureVideoOrientation?
    public let stabilizationMode: CaptureVideoStabilizationMode?
    public let mirroringMode: CaptureVideoMirroringMode?

    public init(
        orientation: CaptureVideoOrientation? = nil,
        stabilizationMode: CaptureVideoStabilizationMode? = nil,
        mirroringMode: CaptureVideoMirroringMode? = nil
    ) {
        self.orientation = orientation
        self.stabilizationMode = stabilizationMode
        self.mirroringMode = mirroringMode
    }

    public static let unchanged = Self()
}
