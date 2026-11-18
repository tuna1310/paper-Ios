import Foundation
import os.signpost
import QuartzCore

/// Lightweight zero-allocation frame-time monitor using `os_signpost` and rolling statistics.
final class FrameMetrics {
    private let log = OSLog(subsystem: "com.paperterritory.game", category: "FrameLoop")
    private var lastTimestamp: CFTimeInterval = 0
    private var sampleSumMs: Double = 0
    private var sampleCount: Int = 0
    private(set) var lastAverageFrameMs: Double = 16.67
    private(set) var lastPeakFrameMs: Double = 0

    func beginFrame() -> CFTimeInterval {
        let now = CACurrentMediaTime()
        if lastTimestamp > 0 {
            let frameMs = (now - lastTimestamp) * 1000.0
            sampleSumMs += frameMs
            sampleCount += 1
            if frameMs > lastPeakFrameMs {
                lastPeakFrameMs = frameMs
            }
            if sampleCount >= 60 {
                lastAverageFrameMs = sampleSumMs / Double(sampleCount)
                sampleSumMs = 0
                sampleCount = 0
                lastPeakFrameMs = frameMs
            }
        }
        lastTimestamp = now
        os_signpost(.begin, log: log, name: "ArenaFrame")
        return now
    }

    func endFrame() {
        os_signpost(.end, log: log, name: "ArenaFrame")
    }

    func reset() {
        lastTimestamp = 0
        sampleSumMs = 0
        sampleCount = 0
        lastPeakFrameMs = 0
    }
}
