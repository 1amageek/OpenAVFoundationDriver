public enum CaptureDriverOperation: Sendable, Equatable {
    case authorization
    case discovery
    case open
    case capabilities
    case configuration
    case controls
    case negotiation
    case observation
    case start
    case streaming
    case stop
    case shutdown
}
