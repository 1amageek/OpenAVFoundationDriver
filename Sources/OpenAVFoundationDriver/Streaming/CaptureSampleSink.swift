public protocol CaptureSampleSink:
    AnyObject,
    CapturePlatformConcurrencyContract
{
    /// Offers an existing sample-buffer lease synchronously without
    /// materializing media bytes.
    ///
    /// The call includes the sink's processing time. Implementations must
    /// return promptly and must not perform unbounded I/O on the capture path.
    func offer(
        _ sampleBuffer: any CMSampleBuffer
    ) -> CaptureSampleDisposition
}
