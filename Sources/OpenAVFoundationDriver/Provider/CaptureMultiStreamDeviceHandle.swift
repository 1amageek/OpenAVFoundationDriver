/// An opened handle that can negotiate and start streams as one atomic group.
public protocol CaptureMultiStreamDeviceHandle: CaptureDeviceHandle {
#if hasFeature(Embedded)
    func streamGroup(
        for request: CaptureStreamGroupRequest,
        sinks: [CaptureStreamSinkBinding]
    ) throws(CaptureDriverError) -> any CaptureStreamGroup
#else
    func streamGroup(
        for request: CaptureStreamGroupRequest,
        sinks: [CaptureStreamSinkBinding]
    ) async throws(CaptureDriverError) -> any CaptureStreamGroup
#endif
}
