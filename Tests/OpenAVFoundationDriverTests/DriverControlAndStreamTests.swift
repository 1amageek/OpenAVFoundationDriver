import OpenAVFoundationDriver
import OpenAVFoundationDriverTesting
import Testing

@Test("Typed camera controls validate configuration against capabilities")
func typedControlContracts() throws {
    let fixture = try ControlFixture()
    let configuration = try CaptureDeviceConfiguration(
        deviceID: fixture.deviceID,
        capabilityRevision: fixture.capabilities.revision,
        formatID: fixture.formatID,
        frameRate: 30,
        controls: CaptureDeviceControls(
            focus: CaptureFocusConfiguration(
                mode: .locked,
                lensPosition: 0.5
            ),
            exposure: CaptureExposureConfiguration(
                mode: .custom,
                duration: CMTime(value: 1, timescale: 60),
                iso: 200
            ),
            whiteBalance: CaptureWhiteBalanceConfiguration(
                mode: .locked,
                gains: try CaptureWhiteBalanceGains(
                    red: 1.5,
                    green: 1,
                    blue: 1.25
                )
            ),
            zoom: CaptureZoomConfiguration(factor: 2),
            deviceSpecific: [
                CaptureDeviceControlSetting(
                    controlID: fixture.hdrControlID,
                    value: .boolean(true)
                )
            ]
        )
    )

    #expect(
        try fixture.capabilities.validatedConfiguration(configuration)
            == configuration
    )

    let unsupportedZoom = try CaptureDeviceConfiguration(
        deviceID: fixture.deviceID,
        capabilityRevision: fixture.capabilities.revision,
        formatID: fixture.formatID,
        controls: CaptureDeviceControls(
            zoom: CaptureZoomConfiguration(factor: 5)
        )
    )
    do {
        _ = try fixture.capabilities.validatedConfiguration(unsupportedZoom)
        Issue.record("An out-of-range zoom factor must fail")
    } catch {
        #expect(
            error == .unsupportedControlValue(
                deviceID: fixture.deviceID,
                controlID: .zoom
            )
        )
    }

    let unknownControlID = try CaptureDeviceControlID("vendor.unknown")
    let unsupportedControl = try CaptureDeviceConfiguration(
        deviceID: fixture.deviceID,
        capabilityRevision: fixture.capabilities.revision,
        formatID: fixture.formatID,
        controls: CaptureDeviceControls(
            deviceSpecific: [
                CaptureDeviceControlSetting(
                    controlID: unknownControlID,
                    value: .boolean(true)
                )
            ]
        )
    )
    do {
        _ = try fixture.capabilities.validatedConfiguration(
            unsupportedControl
        )
        Issue.record("An unknown device-specific control must fail")
    } catch {
        #expect(
            error == .unsupportedControl(
                deviceID: fixture.deviceID,
                controlID: unknownControlID
            )
        )
    }
}

@Test("Control constructors reject invalid modes, ranges, and duplicates")
func invalidControlContracts() throws {
    do {
        _ = try CaptureFocusCapabilities(supportedModes: [])
        Issue.record("Focus capabilities require an explicit mode")
    } catch {
        #expect(error == .missingControlModes(.focus))
    }

    do {
        _ = try CaptureFocusConfiguration(
            mode: .continuousAutoFocus,
            lensPosition: 0.5
        )
        Issue.record("Manual lens position requires locked focus")
    } catch {
        #expect(error == .invalidControlConfiguration(.focus))
    }

    do {
        _ = try CaptureNormalizedPoint(x: 1.1, y: 0.5)
        Issue.record("A point outside normalized coordinates must fail")
    } catch {
        #expect(error == .invalidNormalizedPoint(x: 1.1, y: 0.5))
    }

    let duplicateID = try CaptureDeviceControlID("vendor.mode")
    do {
        _ = try CaptureDeviceControls(
            deviceSpecific: [
                CaptureDeviceControlSetting(
                    controlID: duplicateID,
                    value: .option("first")
                ),
                CaptureDeviceControlSetting(
                    controlID: duplicateID,
                    value: .option("second")
                )
            ]
        )
        Issue.record("Device-specific settings must be unique")
    } catch {
        #expect(error == .duplicateDeviceControlSetting(duplicateID))
    }
}

@Test("Concurrent stream negotiation validates combinations and sink identity")
func concurrentStreamContracts() throws {
    let fixture = try MultiStreamFixture()
    let mainRequest = CaptureStreamRequest(
        streamID: fixture.mainStreamID,
        configuration: try CaptureDeviceConfiguration(
            deviceID: fixture.deviceID,
            capabilityRevision: fixture.capabilities.revision,
            formatID: fixture.mainFormatID,
            frameRate: 30
        )
    )
    let depthRequest = CaptureStreamRequest(
        streamID: fixture.depthStreamID,
        configuration: try CaptureDeviceConfiguration(
            deviceID: fixture.deviceID,
            capabilityRevision: fixture.capabilities.revision,
            formatID: fixture.depthFormatID,
            frameRate: 30
        )
    )
    let group = try CaptureStreamGroupRequest(
        requests: [mainRequest, depthRequest]
    )
    let sink = NullCaptureSampleSink()
    let bindings = [
        CaptureStreamSinkBinding(
            streamID: fixture.mainStreamID,
            sink: sink
        ),
        CaptureStreamSinkBinding(
            streamID: fixture.depthStreamID,
            sink: sink
        )
    ]

    #expect(
        try fixture.capabilities.validatedStreamGroupRequest(
            group,
            sinks: bindings
        ) == group
    )

    do {
        _ = try fixture.capabilities.validatedStreamGroupRequest(
            group,
            sinks: [bindings[0]]
        )
        Issue.record("Every negotiated stream requires one sink")
    } catch {
        #expect(
            error == .unsupportedStreamCombination(
                deviceID: fixture.deviceID,
                streamIDs: [fixture.mainStreamID, fixture.depthStreamID]
            )
        )
    }
}

@Test("Provider conformance suite exercises an atomic stream group lifecycle")
func concurrentStreamConformanceLifecycle() async throws {
    let fixture = try MultiStreamFixture()
    let descriptor = try CaptureDeviceDescriptor(
        deviceID: fixture.deviceID,
        deviceTypeID: try CaptureDeviceTypeID("multi-camera"),
        localizedName: "Multi Camera",
        manufacturer: "Vendor",
        modelID: "Fixture",
        position: .external,
        mediaTypes: [.video],
        capabilityRevision: fixture.capabilities.revision
    )
    let snapshot = try CaptureDeviceSnapshot(
        descriptor: descriptor,
        capabilities: fixture.capabilities
    )
    let mainRequest = CaptureStreamRequest(
        streamID: fixture.mainStreamID,
        configuration: try CaptureDeviceConfiguration(
            deviceID: fixture.deviceID,
            capabilityRevision: fixture.capabilities.revision,
            formatID: fixture.mainFormatID,
            frameRate: 30
        )
    )
    let depthRequest = CaptureStreamRequest(
        streamID: fixture.depthStreamID,
        configuration: try CaptureDeviceConfiguration(
            deviceID: fixture.deviceID,
            capabilityRevision: fixture.capabilities.revision,
            formatID: fixture.depthFormatID,
            frameRate: 30
        )
    )
    let request = try CaptureStreamGroupRequest(
        requests: [mainRequest, depthRequest]
    )
    let sink = NullCaptureSampleSink()
    let sinks = [
        CaptureStreamSinkBinding(
            streamID: fixture.mainStreamID,
            sink: sink
        ),
        CaptureStreamSinkBinding(
            streamID: fixture.depthStreamID,
            sink: sink
        )
    ]
    let group = TestCaptureStreamGroup(
        deviceID: fixture.deviceID,
        streamIDs: request.streamIDs
    )
    let handle = TestMultiStreamDeviceHandle(
        snapshot: snapshot,
        group: group
    )

    try await CaptureProviderConformanceSuite.exerciseStreamGroupLifecycle(
        on: handle,
        request: request,
        sinks: sinks
    )

    #expect(await group.didStart)
    #expect(await group.shutdownCount == 2)
}

@Test("Provider conformance validator rejects duplicate discovered devices")
func providerConformanceValidationContracts() throws {
    let fixture = try MultiStreamFixture()
    let descriptor = try CaptureDeviceDescriptor(
        deviceID: fixture.deviceID,
        deviceTypeID: try CaptureDeviceTypeID("camera"),
        localizedName: "Camera",
        manufacturer: "Vendor",
        modelID: "Model",
        position: .external,
        mediaTypes: [.video],
        capabilityRevision: fixture.capabilities.revision
    )

    do {
        try CaptureProviderConformanceSuite.validate(
            [descriptor, descriptor],
            driverID: fixture.deviceID.driverID,
            request: CaptureDiscoveryRequest(mediaType: .video)
        )
        Issue.record("Duplicate discovery identifiers must fail")
    } catch {
        #expect(error == .duplicateDeviceID(fixture.deviceID))
    }
}

@Test("Video connection policy validates against the selected stream")
func videoConnectionContracts() throws {
    let driverID = try CaptureDriverID("connection-test")
    let deviceID = try CaptureDeviceID(
        driverID: driverID,
        localID: "camera"
    )
    let formatID = try CaptureDeviceFormatID("video")
    let streamID = try CaptureStreamID("main")
    let format = CaptureDeviceFormatDescriptor(
        formatID: formatID,
        mediaType: .video,
        mediaSubtype: CaptureMediaSubtype(rawValue: 0)
    )
    let connectionCapabilities = try CaptureVideoConnectionCapabilities(
        supportedOrientations: [.portrait, .landscapeRight],
        supportedStabilizationModes: [.off, .standard],
        supportedMirroringModes: [.automatic, .disabled]
    )
    let stream = try CaptureStreamDescriptor(
        streamID: streamID,
        mediaType: .video,
        formatIDs: [formatID],
        eventCapabilities: [
            .interruptions,
            .sourceDrops,
            .systemPressure,
            .terminalFailures
        ],
        videoConnectionCapabilities: connectionCapabilities
    )
    let capabilities = try CaptureDeviceCapabilities(
        deviceID: deviceID,
        revision: 1,
        formats: [format],
        preferredFormatID: formatID,
        supportsConcurrentStreams: false,
        streams: [stream],
        supportedStreamCombinations: [
            try CaptureStreamCombination(streamIDs: [streamID])
        ]
    )
    let configuration = try CaptureDeviceConfiguration(
        deviceID: deviceID,
        capabilityRevision: 1,
        formatID: formatID
    )
    let supported = CaptureStreamRequest(
        streamID: streamID,
        configuration: configuration,
        videoConnectionConfiguration: CaptureVideoConnectionConfiguration(
            orientation: .portrait,
            stabilizationMode: .standard,
            mirroringMode: .automatic
        )
    )

    #expect(try capabilities.validatedStreamRequest(supported) == supported)
    #expect(
        stream.eventCapabilities == [
            .interruptions,
            .sourceDrops,
            .systemPressure,
            .terminalFailures
        ]
    )

    let unsupported = CaptureStreamRequest(
        streamID: streamID,
        configuration: configuration,
        videoConnectionConfiguration: CaptureVideoConnectionConfiguration(
            orientation: .portraitUpsideDown
        )
    )
    do {
        _ = try capabilities.validatedStreamRequest(unsupported)
        Issue.record("An unsupported orientation must remain a typed failure")
    } catch {
        #expect(
            error == .unsupportedVideoOrientation(
                deviceID: deviceID,
                streamID: streamID,
                orientation: .portraitUpsideDown
            )
        )
    }
}

@Test("Video connection capabilities reject duplicate values")
func duplicateVideoConnectionCapabilitiesFail() throws {
    do {
        _ = try CaptureVideoConnectionCapabilities(
            supportedOrientations: [.portrait, .portrait]
        )
        Issue.record("Duplicate orientations must fail")
    } catch {
        #expect(error == .duplicateVideoOrientation)
    }
}

@Test("Stream events preserve typed source state without media copies")
func streamEventContracts() throws {
    let recorder = CaptureStreamEventRecorder()
    let pressure = CaptureSystemPressure(
        level: .serious,
        factors: [.systemTemperature, .peakPower]
    )
    let dropped = CaptureStreamDropEvent(
        presentationTimeStamp: CMTime(value: 3, timescale: 30),
        cumulativeCount: 4,
        reason: .outOfBuffers
    )

    #expect(recorder.offer(.interrupted(.deviceInUseByAnotherClient))
        == .continueStreaming)
    #expect(recorder.offer(.pressure(pressure)) == .continueStreaming)
    #expect(recorder.offer(.dropped(dropped)) == .continueStreaming)
    #expect(recorder.offer(.resumed) == .continueStreaming)
    #expect(
        recorder.events == [
            .interrupted(.deviceInUseByAnotherClient),
            .pressure(pressure),
            .dropped(dropped),
            .resumed
        ]
    )
    try CaptureProviderConformanceSuite.validate(
        .pressure(pressure),
        capabilities: [.systemPressure]
    )
    #expect(throws: CaptureProviderConformanceError.self) {
        try CaptureProviderConformanceSuite.validate(
            .pressure(pressure),
            capabilities: [.interruptions]
        )
    }
}

private struct ControlFixture {
    let deviceID: CaptureDeviceID
    let formatID: CaptureDeviceFormatID
    let hdrControlID: CaptureDeviceControlID
    let capabilities: CaptureDeviceCapabilities

    init() throws {
        let driverID = try CaptureDriverID("control-test")
        deviceID = try CaptureDeviceID(
            driverID: driverID,
            localID: "camera"
        )
        formatID = try CaptureDeviceFormatID("video")
        hdrControlID = try CaptureDeviceControlID("vendor.hdr")
        let format = CaptureDeviceFormatDescriptor(
            formatID: formatID,
            mediaType: .video,
            mediaSubtype: CaptureMediaSubtype(rawValue: 0),
            dimensions: try CaptureDimensions(width: 1920, height: 1080),
            frameRateRanges: [
                try CaptureFrameRateRange(minimum: 24, maximum: 60)
            ]
        )
        let controls = try CaptureDeviceControlCapabilities(
            focus: CaptureFocusCapabilities(
                supportedModes: [
                    .locked,
                    .autoFocus,
                    .continuousAutoFocus
                ],
                lensPositionRange: CaptureScalarRange(
                    minimum: 0,
                    maximum: 1
                ),
                supportsPointOfInterest: true
            ),
            exposure: CaptureExposureCapabilities(
                supportedModes: [
                    .locked,
                    .autoExpose,
                    .continuousAutoExposure,
                    .custom
                ],
                durationRange: CaptureExposureDurationRange(
                    minimum: CMTime(value: 1, timescale: 1_000),
                    maximum: CMTime(value: 1, timescale: 10)
                ),
                isoRange: CaptureScalarRange(
                    minimum: 50,
                    maximum: 800
                ),
                supportsPointOfInterest: true
            ),
            whiteBalance: CaptureWhiteBalanceCapabilities(
                supportedModes: [
                    .locked,
                    .autoWhiteBalance,
                    .continuousAutoWhiteBalance
                ],
                gainRange: CaptureScalarRange(
                    minimum: 1,
                    maximum: 4
                )
            ),
            zoom: CaptureZoomCapabilities(
                factorRange: CaptureScalarRange(
                    minimum: 1,
                    maximum: 4
                )
            ),
            deviceSpecific: [
                try CaptureDeviceControlDescriptor(
                    controlID: hdrControlID,
                    constraint: .boolean
                )
            ]
        )
        capabilities = try CaptureDeviceCapabilities(
            deviceID: deviceID,
            revision: 5,
            formats: [format],
            preferredFormatID: formatID,
            supportsConcurrentStreams: false,
            controls: controls
        )
    }
}

private struct MultiStreamFixture {
    let deviceID: CaptureDeviceID
    let mainFormatID: CaptureDeviceFormatID
    let depthFormatID: CaptureDeviceFormatID
    let mainStreamID: CaptureStreamID
    let depthStreamID: CaptureStreamID
    let capabilities: CaptureDeviceCapabilities

    init() throws {
        let driverID = try CaptureDriverID("multi-test")
        deviceID = try CaptureDeviceID(
            driverID: driverID,
            localID: "camera"
        )
        mainFormatID = try CaptureDeviceFormatID("main")
        depthFormatID = try CaptureDeviceFormatID("depth")
        mainStreamID = try CaptureStreamID("main")
        depthStreamID = try CaptureStreamID("depth")
        let frameRates = [
            try CaptureFrameRateRange(minimum: 30, maximum: 30)
        ]
        let formats = [
            CaptureDeviceFormatDescriptor(
                formatID: mainFormatID,
                mediaType: .video,
                mediaSubtype: CaptureMediaSubtype(rawValue: 1),
                frameRateRanges: frameRates
            ),
            CaptureDeviceFormatDescriptor(
                formatID: depthFormatID,
                mediaType: .video,
                mediaSubtype: CaptureMediaSubtype(rawValue: 2),
                frameRateRanges: frameRates
            )
        ]
        capabilities = try CaptureDeviceCapabilities(
            deviceID: deviceID,
            revision: 3,
            formats: formats,
            preferredFormatID: mainFormatID,
            supportsConcurrentStreams: true,
            streams: [
                CaptureStreamDescriptor(
                    streamID: mainStreamID,
                    mediaType: .video,
                    formatIDs: [mainFormatID]
                ),
                CaptureStreamDescriptor(
                    streamID: depthStreamID,
                    mediaType: .video,
                    formatIDs: [depthFormatID]
                )
            ],
            supportedStreamCombinations: [
                CaptureStreamCombination(
                    streamIDs: [mainStreamID, depthStreamID]
                )
            ]
        )
    }
}

private final class NullCaptureSampleSink: CaptureSampleSink, Sendable {
    func offer(
        _ sampleBuffer: any CMSampleBuffer
    ) -> CaptureSampleDisposition {
        .accepted
    }
}

private actor TestMultiStreamDeviceHandle: CaptureMultiStreamDeviceHandle {
    private let snapshotValue: CaptureDeviceSnapshot
    private let group: TestCaptureStreamGroup

    init(
        snapshot: CaptureDeviceSnapshot,
        group: TestCaptureStreamGroup
    ) {
        snapshotValue = snapshot
        self.group = group
    }

    func snapshot() throws(CaptureDriverError) -> CaptureDeviceSnapshot {
        snapshotValue
    }

    func configure(
        _ configuration: CaptureDeviceConfiguration
    ) throws(CaptureDriverError) -> CaptureDeviceSnapshot {
        _ = try snapshotValue.capabilities.validatedConfiguration(
            configuration
        )
        return snapshotValue
    }

    func stream(
        for request: CaptureStreamRequest,
        sink: any CaptureSampleSink
    ) throws(CaptureDriverError) -> any CaptureStream {
        throw .unsupportedConfiguration(request.configuration.deviceID)
    }

    func streamGroup(
        for request: CaptureStreamGroupRequest,
        sinks: [CaptureStreamSinkBinding]
    ) throws(CaptureDriverError) -> any CaptureStreamGroup {
        _ = try snapshotValue.capabilities.validatedStreamGroupRequest(
            request,
            sinks: sinks
        )
        return group
    }

    func shutdown() {}
}

private actor TestCaptureStreamGroup: CaptureStreamGroup {
    nonisolated let deviceID: CaptureDeviceID
    nonisolated let streamIDs: [CaptureStreamID]

    private(set) var didStart = false
    private(set) var shutdownCount = 0

    init(
        deviceID: CaptureDeviceID,
        streamIDs: [CaptureStreamID]
    ) {
        self.deviceID = deviceID
        self.streamIDs = streamIDs
    }

    func start() {
        didStart = true
    }

    func shutdown() {
        shutdownCount += 1
    }
}
