import Synchronization

/// A thread-safe provider-test sink for low-frequency device topology events.
public final class CaptureDeviceEventRecorder: CaptureDeviceEventSink {
    private let storage = Mutex<[CaptureDeviceEvent]>([])

    public init() {}

    public func offer(
        _ event: CaptureDeviceEvent
    ) -> CaptureDeviceEventDisposition {
        storage.withLock { events in
            events.append(event)
        }
        return .accepted
    }

    public var events: [CaptureDeviceEvent] {
        storage.withLock { $0 }
    }

    public var receivedInitialSnapshot: Bool {
        storage.withLock { events in
            guard let first = events.first else {
                return false
            }
            if case .snapshot = first {
                return true
            }
            return false
        }
    }
}
