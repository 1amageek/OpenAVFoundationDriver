public enum CaptureDeviceEvent: Sendable, Hashable {
    /// The authoritative initial device set emitted once when observation starts.
    case snapshot([CaptureDeviceDescriptor])
    case connected(CaptureDeviceDescriptor)
    case updated(CaptureDeviceDescriptor)
    case disconnected(CaptureDeviceID)
}
