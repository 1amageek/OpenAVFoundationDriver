/// A marker for streams that override the base event capability and sink APIs.
///
/// Consumers do not need a runtime cast: Embedded Swift can call the base
/// `CaptureStream` requirements directly without protocol-conformance metadata.
public protocol CaptureStreamEventSource: CaptureStream {}
