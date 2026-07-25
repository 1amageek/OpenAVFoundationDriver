public protocol CaptureSampleSink:
    AnyObject,
    CapturePlatformConcurrencyContract
{
    /// Offers an existing sample-buffer lease without materializing media bytes.
    func offer(
        _ sampleBuffer: any CMSampleBuffer
    ) -> CaptureSampleDisposition
}
