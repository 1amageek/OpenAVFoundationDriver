import OpenAVFoundationDriver
import Synchronization

public final class CaptureStreamEventRecorder:
    CaptureStreamEventSink,
    Sendable
{
    private let disposition: CaptureStreamEventDisposition
    private let storage = Mutex<[CaptureStreamEvent]>([])

    public init(
        disposition: CaptureStreamEventDisposition = .continueStreaming
    ) {
        self.disposition = disposition
    }

    public var events: [CaptureStreamEvent] {
        storage.withLock { events in events }
    }

    public func offer(
        _ event: CaptureStreamEvent
    ) -> CaptureStreamEventDisposition {
        storage.withLock { events in
            events.append(event)
        }
        return disposition
    }
}
