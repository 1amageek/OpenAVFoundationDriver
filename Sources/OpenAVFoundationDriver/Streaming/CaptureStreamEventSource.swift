public protocol CaptureStreamEventSource: CaptureStream {
    var eventCapabilities: CaptureStreamEventCapabilities { get }

    /// Installs or clears the event sink while the stream is stopped.
    ///
    /// A provider that cannot replace the sink in its current state throws a
    /// typed driver error. Shutdown clears the sink and prevents later events.
    func setEventSink(
        _ sink: (any CaptureStreamEventSink)?
    ) throws(CaptureDriverError)
}
