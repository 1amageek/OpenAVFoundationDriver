import Synchronization

/// A reusable replay-provider probe that checks sample-object identity.
public final class CaptureSampleIdentitySink: CaptureSampleSink {
    private struct State: Sendable {
        var receivedSampleCount = 0
        var receivedExpectedSample = false
    }

    private let expectedSample: any CMSampleBuffer & Sendable
    private let state = Mutex(State())

    public init(expectedSample: any CMSampleBuffer & Sendable) {
        self.expectedSample = expectedSample
    }

    public func offer(
        _ sampleBuffer: any CMSampleBuffer
    ) -> CaptureSampleDisposition {
        let isExpectedSample = sampleBuffer === expectedSample
        state.withLock { state in
            state.receivedSampleCount += 1
            state.receivedExpectedSample =
                state.receivedExpectedSample || isExpectedSample
        }
        return .accepted
    }

    public var receivedSampleCount: Int {
        state.withLock { $0.receivedSampleCount }
    }

    public var receivedExpectedSample: Bool {
        state.withLock { $0.receivedExpectedSample }
    }
}
