public struct CaptureStreamSinkBinding: CapturePlatformConcurrencyContract {
    public let streamID: CaptureStreamID
    public let sink: any CaptureSampleSink

    public init(
        streamID: CaptureStreamID,
        sink: any CaptureSampleSink
    ) {
        self.streamID = streamID
        self.sink = sink
    }
}
