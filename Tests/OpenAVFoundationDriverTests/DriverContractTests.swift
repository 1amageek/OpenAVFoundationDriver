import OpenAVFoundationDriver
import OpenAVFoundationDriverTesting
import Synchronization
import Testing

@Test("Identifiers reject empty values and preserve driver namespaces")
func identifierContracts() throws {
    do {
        _ = try CaptureDriverID("")
        Issue.record("An empty driver identifier must fail")
    } catch {
        #expect(error == .emptyIdentifier(.driver))
    }

    let firstDriverID = try CaptureDriverID("first")
    let secondDriverID = try CaptureDriverID("second")
    let firstDeviceID = try CaptureDeviceID(
        driverID: firstDriverID,
        localID: "camera"
    )
    let secondDeviceID = try CaptureDeviceID(
        driverID: secondDriverID,
        localID: "camera"
    )

    #expect(firstDeviceID != secondDeviceID)
}

@Test("Device type selection distinguishes all devices from validated matches")
func deviceTypeSelectionContracts() throws {
    let cameraType = try CaptureDeviceTypeID("camera")

    #expect(CaptureDeviceTypeSelection.all.requestedDeviceTypeIDs == nil)
    #expect(CaptureDeviceTypeSelection.all.includes(cameraType))

    do {
        _ = try CaptureDeviceTypeSelection(matching: [])
        Issue.record("An empty matching selection must fail")
    } catch {
        #expect(error == .missingDeviceTypes)
    }

    do {
        _ = try CaptureDeviceTypeSelection(
            matching: [cameraType, cameraType]
        )
        Issue.record("Duplicate device types must fail")
    } catch {
        #expect(error == .duplicateDeviceType(cameraType))
    }

    let selection = try CaptureDeviceTypeSelection(matching: [cameraType])
    #expect(selection.requestedDeviceTypeIDs == [cameraType])
    #expect(selection.includes(cameraType))
    #expect(!selection.includes(try CaptureDeviceTypeID("microphone")))
}

@Test("Descriptors reject absent and duplicate media types")
func descriptorContracts() throws {
    let driverID = try CaptureDriverID("driver")
    let deviceID = try CaptureDeviceID(
        driverID: driverID,
        localID: "camera"
    )
    let deviceTypeID = try CaptureDeviceTypeID("camera")

    do {
        _ = try CaptureDeviceDescriptor(
            deviceID: deviceID,
            deviceTypeID: deviceTypeID,
            localizedName: "Camera",
            manufacturer: "Manufacturer",
            modelID: "Model",
            position: .external,
            mediaTypes: [],
            capabilityRevision: 1
        )
        Issue.record("A descriptor without media types must fail")
    } catch {
        #expect(error == .missingMediaTypes)
    }

    do {
        _ = try CaptureDeviceDescriptor(
            deviceID: deviceID,
            deviceTypeID: deviceTypeID,
            localizedName: "Camera",
            manufacturer: "Manufacturer",
            modelID: "Model",
            position: .external,
            mediaTypes: [.video, .video],
            capabilityRevision: 1
        )
        Issue.record("Duplicate media types must fail")
    } catch {
        #expect(error == .duplicateMediaType(.video))
    }
}

@Test("Dimensions, frame rates, and capability format IDs are validated")
func capabilityContracts() throws {
    do {
        _ = try CaptureDimensions(width: 0, height: 1080)
        Issue.record("Nonpositive dimensions must fail")
    } catch {
        #expect(error == .invalidDimensions(width: 0, height: 1080))
    }

    do {
        _ = try CaptureFrameRateRange(minimum: 60, maximum: 30)
        Issue.record("A descending frame-rate range must fail")
    } catch {
        #expect(
            error == .invalidFrameRateRange(minimum: 60, maximum: 30)
        )
    }

    let driverID = try CaptureDriverID("driver")
    let deviceID = try CaptureDeviceID(
        driverID: driverID,
        localID: "camera"
    )
    let formatID = try CaptureDeviceFormatID("1080p")
    let format = CaptureDeviceFormatDescriptor(
        formatID: formatID,
        mediaType: .video,
        mediaSubtype: CaptureMediaSubtype(rawValue: 0),
        dimensions: try CaptureDimensions(width: 1920, height: 1080),
        frameRateRanges: [
            try CaptureFrameRateRange(minimum: 30, maximum: 60)
        ]
    )

    do {
        _ = try CaptureDeviceConfiguration(
            deviceID: deviceID,
            capabilityRevision: 1,
            formatID: formatID,
            frameRate: .infinity
        )
        Issue.record("A nonfinite requested frame rate must fail")
    } catch {
        #expect(error == .invalidFrameRate(.infinity))
    }

    do {
        _ = try CaptureDeviceCapabilities(
            deviceID: deviceID,
            revision: 1,
            formats: [format, format],
            preferredFormatID: formatID
        )
        Issue.record("Duplicate format IDs must fail")
    } catch {
        #expect(error == .duplicateFormatID(formatID))
    }

    let missingFormatID = try CaptureDeviceFormatID("missing")
    do {
        _ = try CaptureDeviceCapabilities(
            deviceID: deviceID,
            revision: 1,
            formats: [format],
            preferredFormatID: missingFormatID
        )
        Issue.record("A missing preferred format must fail")
    } catch {
        #expect(
            error == .preferredFormatNotFound(
                deviceID: deviceID,
                formatID: missingFormatID
            )
        )
    }

    let capabilities = try CaptureDeviceCapabilities(
        deviceID: deviceID,
        revision: 7,
        formats: [format],
        preferredFormatID: formatID
    )
    #expect(
        try capabilities.preferredConfiguration()
            == CaptureDeviceConfiguration(
                deviceID: deviceID,
                capabilityRevision: 7,
                formatID: formatID
            )
    )
}

@Test("Device snapshots reject mismatched identity and capability revisions")
func deviceSnapshotContracts() throws {
    let driverID = try CaptureDriverID("driver")
    let firstDeviceID = try CaptureDeviceID(
        driverID: driverID,
        localID: "first"
    )
    let secondDeviceID = try CaptureDeviceID(
        driverID: driverID,
        localID: "second"
    )
    let deviceTypeID = try CaptureDeviceTypeID("camera")
    let descriptor = try CaptureDeviceDescriptor(
        deviceID: firstDeviceID,
        deviceTypeID: deviceTypeID,
        localizedName: "Camera",
        manufacturer: "Manufacturer",
        modelID: "Model",
        position: .external,
        mediaTypes: [.video],
        capabilityRevision: 1
    )
    let format = CaptureDeviceFormatDescriptor(
        formatID: try CaptureDeviceFormatID("1080p"),
        mediaType: .video,
        mediaSubtype: CaptureMediaSubtype(rawValue: 0)
    )
    let otherDeviceCapabilities = try CaptureDeviceCapabilities(
        deviceID: secondDeviceID,
        revision: 1,
        formats: [format],
        preferredFormatID: format.formatID
    )

    do {
        _ = try CaptureDeviceSnapshot(
            descriptor: descriptor,
            capabilities: otherDeviceCapabilities
        )
        Issue.record("A snapshot must reject another device's capabilities")
    } catch {
        #expect(
            error == .capabilityDeviceMismatch(
                descriptorDeviceID: firstDeviceID,
                capabilitiesDeviceID: secondDeviceID
            )
        )
    }

    let staleCapabilities = try CaptureDeviceCapabilities(
        deviceID: firstDeviceID,
        revision: 2,
        formats: [format],
        preferredFormatID: format.formatID
    )

    do {
        _ = try CaptureDeviceSnapshot(
            descriptor: descriptor,
            capabilities: staleCapabilities
        )
        Issue.record("A snapshot must reject a capability revision mismatch")
    } catch {
        #expect(
            error == .capabilityRevisionMismatch(
                deviceID: firstDeviceID,
                descriptorRevision: 1,
                capabilitiesRevision: 2
            )
        )
    }
}

@Test("Provider discovery and opened-handle failures cross existential boundaries")
func providerContracts() async throws {
    let fixture = try DriverFixture()
    let provider: any CaptureDeviceProvider = fixture.provider

    #expect(
        await provider.authorizationStatus(for: .video) == .authorized
    )
    #expect(
        try await provider.requestAccess(for: .video) == .authorized
    )
    #expect(
        try await provider.requestAccess(for: .audio) == .denied
    )

    let discoveryRequest = CaptureDiscoveryRequest(
        deviceTypeSelection: try CaptureDeviceTypeSelection(
            matching: [fixture.descriptor.deviceTypeID]
        ),
        mediaType: .video,
        position: .external
    )
    let devices = try await CaptureProviderConformanceSuite.discoveredDevices(
        from: provider,
        matching: discoveryRequest
    )
    #expect(devices == [fixture.descriptor])

    let eventRecorder = CaptureDeviceEventRecorder()
    try await CaptureProviderConformanceSuite.exerciseDeviceEventLifecycle(
        from: fixture.provider,
        matching: discoveryRequest,
        sink: eventRecorder
    )
    try CaptureProviderConformanceSuite.validateInitialSnapshot(
        in: eventRecorder,
        driverID: fixture.provider.driverID
    )
    #expect(eventRecorder.events == [.snapshot([fixture.descriptor])])

    let openResult = try await CaptureProviderConformanceSuite.openedDevice(
        from: provider,
        descriptor: fixture.descriptor
    )
    let handle = openResult.handle
    let snapshot = try await handle.snapshot()
    #expect(snapshot.descriptor == fixture.descriptor)
    #expect(snapshot.capabilities == fixture.capabilities)

    let configuration = try CaptureDeviceConfiguration(
        deviceID: fixture.descriptor.deviceID,
        capabilityRevision: fixture.descriptor.capabilityRevision,
        formatID: fixture.capabilities.formats[0].formatID,
        frameRate: 30
    )
    #expect(
        try await CaptureProviderConformanceSuite.configuredSnapshot(
            from: handle,
            configuration: configuration
        ) == snapshot
    )
    #expect(
        await fixture.provider.handle.currentConfiguration() == configuration
    )

    let identitySink = CaptureSampleIdentitySink(
        expectedSample: fixture.sampleBuffer
    )
    try await CaptureProviderConformanceSuite.exerciseStreamLifecycle(
        on: handle,
        request: CaptureStreamRequest(configuration: configuration),
        sink: identitySink
    )
    #expect(identitySink.receivedSampleCount == 1)
    #expect(identitySink.receivedExpectedSample)

    let sink = TestCaptureSampleSink()
    let stream = try await handle.stream(
        for: CaptureStreamRequest(configuration: configuration),
        sink: sink
    )
    try await stream.start()
    let receivedSample = sink.receivedSample()
    #expect(receivedSample != nil)
    if let receivedSample {
        #expect(receivedSample === fixture.sampleBuffer)
    }
    try await stream.shutdown()
    try await stream.shutdown()

    let staleConfiguration = try CaptureDeviceConfiguration(
        deviceID: fixture.descriptor.deviceID,
        capabilityRevision: fixture.descriptor.capabilityRevision + 1,
        formatID: fixture.capabilities.formats[0].formatID
    )
    do {
        _ = try await handle.configure(staleConfiguration)
        Issue.record("A stale configuration must fail")
    } catch {
        #expect(
            error == .staleCapabilities(
                deviceID: fixture.descriptor.deviceID,
                expectedRevision: staleConfiguration.capabilityRevision,
                actualRevision: fixture.descriptor.capabilityRevision
            )
        )
    }

    let unsupportedFrameRate = try CaptureDeviceConfiguration(
        deviceID: fixture.descriptor.deviceID,
        capabilityRevision: fixture.descriptor.capabilityRevision,
        formatID: fixture.capabilities.formats[0].formatID,
        frameRate: 120
    )
    do {
        _ = try await handle.configure(unsupportedFrameRate)
        Issue.record("An unsupported frame rate must fail")
    } catch {
        #expect(
            error == .unsupportedFrameRate(
                deviceID: fixture.descriptor.deviceID,
                formatID: unsupportedFrameRate.formatID,
                frameRate: 120
            )
        )
    }

    try await CaptureProviderConformanceSuite.exerciseHandleShutdown(
        handle,
        deviceID: fixture.descriptor.deviceID
    )

    do {
        _ = try await handle.snapshot()
        Issue.record("A shut down handle must not return a snapshot")
    } catch {
        #expect(
            error == .deviceDisconnected(fixture.descriptor.deviceID)
        )
    }
}

@Test("Base streams reject unsupported runtime event sinks")
func baseStreamEventContract() throws {
    let fixture = try DriverFixture()
    let stream: any CaptureStream = TestCaptureStream(
        deviceID: fixture.descriptor.deviceID,
        sampleBuffer: fixture.sampleBuffer,
        sink: TestCaptureSampleSink()
    )
    let recorder = CaptureStreamEventRecorder()

    #expect(stream.eventCapabilities.isEmpty)

    do {
        try stream.setEventSink(recorder)
        Issue.record("A base stream must reject a non-nil event sink")
    } catch {
        #expect(
            error == .unsupportedStreamEvents(
                fixture.descriptor.deviceID
            )
        )
    }

    try stream.setEventSink(nil)
}

private struct DriverFixture: Sendable {
    let descriptor: CaptureDeviceDescriptor
    let capabilities: CaptureDeviceCapabilities
    let sampleBuffer: any CMSampleBuffer
    let provider: TestCaptureDeviceProvider

    init() throws {
        let driverID = try CaptureDriverID("test")
        let deviceID = try CaptureDeviceID(
            driverID: driverID,
            localID: "camera"
        )
        let deviceTypeID = try CaptureDeviceTypeID("camera")
        let descriptor = try CaptureDeviceDescriptor(
            deviceID: deviceID,
            deviceTypeID: deviceTypeID,
            localizedName: "Test Camera",
            manufacturer: "Test",
            modelID: "Fixture",
            position: .external,
            mediaTypes: [.video],
            capabilityRevision: 1
        )
        let format = CaptureDeviceFormatDescriptor(
            formatID: try CaptureDeviceFormatID("1080p"),
            mediaType: .video,
            mediaSubtype: CaptureMediaSubtype(rawValue: 0),
            dimensions: try CaptureDimensions(width: 1920, height: 1080),
            frameRateRanges: [
                try CaptureFrameRateRange(minimum: 30, maximum: 60)
            ]
        )
        let capabilities = try CaptureDeviceCapabilities(
            deviceID: deviceID,
            revision: descriptor.capabilityRevision,
            formats: [format],
            preferredFormatID: format.formatID
        )
        let snapshot = try CaptureDeviceSnapshot(
            descriptor: descriptor,
            capabilities: capabilities
        )
        let imageDimensions = try CVPixelDimensions(width: 2, height: 1)
        let imageBuffer = try CVPackedPixelBuffer(
            dimensions: imageDimensions,
            pixelFormat: .bgra32,
            bytesPerPixel: 4,
            bytesPerRow: 8
        )
        let formatDescription = CMImmutableVideoFormatDescription(
            dimensions: imageDimensions,
            pixelFormat: .bgra32
        )
        let sampleBuffer = try CMImageSampleBuffer(
            imageBuffer: imageBuffer,
            formatDescription: formatDescription,
            timing: [
                CMSampleTimingInfo(
                    duration: CMTime(value: 1, timescale: 30),
                    presentationTimeStamp: .zero,
                    decodeTimeStamp: .invalid
                )
            ]
        )
        let handle = TestCaptureDeviceHandle(
            snapshot: snapshot,
            sampleBuffer: sampleBuffer
        )

        self.descriptor = descriptor
        self.capabilities = capabilities
        self.sampleBuffer = sampleBuffer
        self.provider = TestCaptureDeviceProvider(
            driverID: driverID,
            descriptor: descriptor,
            handle: handle
        )
    }
}

private struct TestCaptureDeviceProvider:
    CaptureDeviceProvider,
    CaptureDeviceEventProvider
{
    let driverID: CaptureDriverID
    let descriptor: CaptureDeviceDescriptor
    let handle: TestCaptureDeviceHandle

    func authorizationStatus(
        for mediaType: CaptureMediaTypeID
    ) async -> CaptureAuthorizationStatus {
        mediaType == .video ? .authorized : .denied
    }

    func requestAccess(
        for mediaType: CaptureMediaTypeID
    ) async throws(CaptureDriverError) -> CaptureAuthorizationStatus {
        mediaType == .video ? .authorized : .denied
    }

    func devices(
        matching request: CaptureDiscoveryRequest
    ) async throws(CaptureDriverError) -> [CaptureDeviceDescriptor] {
        if let mediaType = request.mediaType,
           !descriptor.mediaTypes.contains(mediaType) {
            return []
        }
        if request.position != .unspecified,
           request.position != descriptor.position {
            return []
        }
        if !request.deviceTypeSelection.includes(descriptor.deviceTypeID) {
            return []
        }
        return [descriptor]
    }

    func deviceHandle(
        for deviceID: CaptureDeviceID
    ) async throws(CaptureDriverError) -> any CaptureDeviceHandle {
        guard deviceID == descriptor.deviceID else {
            throw .deviceNotFound(deviceID)
        }
        return handle
    }

    func deviceEventSubscription(
        matching request: CaptureDiscoveryRequest,
        sink: any CaptureDeviceEventSink
    ) async throws(CaptureDriverError)
        -> any CaptureDeviceEventSubscription
    {
        TestCaptureDeviceEventSubscription(
            driverID: driverID,
            descriptor: descriptor,
            request: request,
            sink: sink
        )
    }
}

private actor TestCaptureDeviceEventSubscription:
    CaptureDeviceEventSubscription
{
    nonisolated let driverID: CaptureDriverID

    private let descriptor: CaptureDeviceDescriptor
    private let request: CaptureDiscoveryRequest
    private let sink: any CaptureDeviceEventSink
    private var isStarted = false
    private var isShutdown = false

    init(
        driverID: CaptureDriverID,
        descriptor: CaptureDeviceDescriptor,
        request: CaptureDiscoveryRequest,
        sink: any CaptureDeviceEventSink
    ) {
        self.driverID = driverID
        self.descriptor = descriptor
        self.request = request
        self.sink = sink
    }

    func start() throws(CaptureDriverError) {
        guard !isShutdown else {
            throw .providerUnavailable(driverID: driverID)
        }
        guard !isStarted else {
            return
        }

        let matchesMediaType = request.mediaType.map {
            descriptor.mediaTypes.contains($0)
        } ?? true
        let matchesPosition = request.position == .unspecified
            || request.position == descriptor.position
        let matchesDeviceType = request.deviceTypeSelection.includes(
            descriptor.deviceTypeID
        )
        let descriptors = matchesMediaType
            && matchesPosition
            && matchesDeviceType ? [descriptor] : []
        if sink.offer(.snapshot(descriptors)) == .stop {
            isShutdown = true
            return
        }
        isStarted = true
    }

    func shutdown() {
        isShutdown = true
    }
}

private actor TestCaptureDeviceHandle: CaptureDeviceHandle {
    private let snapshotValue: CaptureDeviceSnapshot
    private let sampleBuffer: any CMSampleBuffer
    private var isShutdown = false
    private var activeConfiguration: CaptureDeviceConfiguration?

    init(
        snapshot: CaptureDeviceSnapshot,
        sampleBuffer: any CMSampleBuffer
    ) {
        self.snapshotValue = snapshot
        self.sampleBuffer = sampleBuffer
    }

    func snapshot() throws(CaptureDriverError) -> CaptureDeviceSnapshot {
        guard !isShutdown else {
            throw .deviceDisconnected(snapshotValue.descriptor.deviceID)
        }
        return snapshotValue
    }

    func configure(
        _ configuration: CaptureDeviceConfiguration
    ) throws(CaptureDriverError) -> CaptureDeviceSnapshot {
        guard !isShutdown else {
            throw .deviceDisconnected(snapshotValue.descriptor.deviceID)
        }
        guard configuration.deviceID == snapshotValue.descriptor.deviceID else {
            throw .deviceNotFound(configuration.deviceID)
        }
        guard configuration.capabilityRevision
                == snapshotValue.capabilities.revision else {
            throw .staleCapabilities(
                deviceID: configuration.deviceID,
                expectedRevision: configuration.capabilityRevision,
                actualRevision: snapshotValue.capabilities.revision
            )
        }
        guard let format = snapshotValue.capabilities.formats.first(
            where: { $0.formatID == configuration.formatID }
        ) else {
            throw .unsupportedFormat(
                deviceID: configuration.deviceID,
                formatID: configuration.formatID
            )
        }
        if let frameRate = configuration.frameRate,
           !format.frameRateRanges.contains(
               where: {
                   $0.minimum <= frameRate && frameRate <= $0.maximum
               }
           ) {
            throw .unsupportedFrameRate(
                deviceID: configuration.deviceID,
                formatID: configuration.formatID,
                frameRate: frameRate
            )
        }

        activeConfiguration = configuration
        return snapshotValue
    }

    func currentConfiguration() -> CaptureDeviceConfiguration? {
        activeConfiguration
    }

    func stream(
        for request: CaptureStreamRequest,
        sink: any CaptureSampleSink
    ) throws(CaptureDriverError) -> any CaptureStream {
        guard !isShutdown else {
            throw .deviceDisconnected(snapshotValue.descriptor.deviceID)
        }
        guard activeConfiguration == request.configuration else {
            throw .unsupportedConfiguration(request.configuration.deviceID)
        }

        return TestCaptureStream(
            deviceID: snapshotValue.descriptor.deviceID,
            sampleBuffer: sampleBuffer,
            sink: sink
        )
    }

    func shutdown() {
        isShutdown = true
    }
}

private actor TestCaptureStream: CaptureStream {
    nonisolated let deviceID: CaptureDeviceID

    private let sampleBuffer: any CMSampleBuffer
    private let sink: any CaptureSampleSink
    private var isStarted = false
    private var isShutdown = false

    init(
        deviceID: CaptureDeviceID,
        sampleBuffer: any CMSampleBuffer,
        sink: any CaptureSampleSink
    ) {
        self.deviceID = deviceID
        self.sampleBuffer = sampleBuffer
        self.sink = sink
    }

    func start() throws(CaptureDriverError) {
        guard !isShutdown else {
            throw .deviceDisconnected(deviceID)
        }
        guard !isStarted else {
            return
        }

        switch sink.offer(sampleBuffer) {
        case .accepted, .dropped:
            isStarted = true
        case .stop:
            isShutdown = true
        }
    }

    func shutdown() {
        isShutdown = true
    }
}

private final class TestCaptureSampleSink: CaptureSampleSink, Sendable {
    private let sample: Mutex<(any CMSampleBuffer)?>

    init() {
        sample = Mutex(nil)
    }

    func offer(
        _ sampleBuffer: any CMSampleBuffer
    ) -> CaptureSampleDisposition {
        sample.withLock { sample in
            sample = sampleBuffer
        }
        return .accepted
    }

    func receivedSample() -> (any CMSampleBuffer)? {
        sample.withLock { sample in
            sample
        }
    }
}
