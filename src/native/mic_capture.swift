// Microphone capture sidecar for `mlx-bun dictate`: AVAudioEngine input
// → 16 kHz mono float32 little-endian PCM on stdout, continuously, in
// 20 ms buffers. Control lines go to stderr: "ready", and with --hotkey
// <keycode>, "hotkey down" / "hotkey up" from a CGEvent listen-only tap
// (needs the terminal app to have Input Monitoring; the mic needs
// Microphone permission — macOS prompts on first use).
//
//   mic-capture [--rate 16000] [--hotkey 61]      (61 = Right Option)

import AVFoundation
import CoreGraphics
import Foundation

var rate: Double = 16000
var hotkey: Int64? = nil
var args = Array(CommandLine.arguments.dropFirst())
while !args.isEmpty {
    let a = args.removeFirst()
    switch a {
    case "--rate": rate = Double(args.removeFirst()) ?? 16000
    case "--hotkey": hotkey = Int64(args.removeFirst())
    default:
        FileHandle.standardError.write("usage: mic-capture [--rate 16000] [--hotkey <keycode>]\n".data(using: .utf8)!)
        exit(2)
    }
}

let err = FileHandle.standardError
let out = FileHandle.standardOutput
let writeLock = NSLock()
func note(_ s: String) { err.write((s + "\n").data(using: .utf8)!) }

var hotkeyDown = false
let engine = AVAudioEngine()
let input = engine.inputNode
let inFormat = input.outputFormat(forBus: 0)
guard let outFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: rate, channels: 1, interleaved: true),
      let converter = AVAudioConverter(from: inFormat, to: outFormat) else {
    note("error: cannot build audio converter"); exit(1)
}
input.installTap(onBus: 0, bufferSize: AVAudioFrameCount(inFormat.sampleRate * 0.02), format: inFormat) { buffer, _ in
    let ratio = rate / inFormat.sampleRate
    let capacity = AVAudioFrameCount(Double(buffer.frameLength) * ratio) + 32
    guard let outBuf = AVAudioPCMBuffer(pcmFormat: outFormat, frameCapacity: capacity) else { return }
    var consumed = false
    var convError: NSError? = nil
    converter.convert(to: outBuf, error: &convError) { _, status in
        if consumed { status.pointee = .noDataNow; return nil }
        consumed = true
        status.pointee = .haveData
        return buffer
    }
    if convError != nil || outBuf.frameLength == 0 { return }
    let bytes = Data(bytes: outBuf.floatChannelData![0], count: Int(outBuf.frameLength) * 4)
    writeLock.lock(); out.write(bytes); writeLock.unlock()
}
do { try engine.start() } catch { note("error: audio engine failed: \(error)"); exit(1) }
note("ready rate=\(Int(rate)) input=\(Int(inFormat.sampleRate))Hz/\(inFormat.channelCount)ch")

if let key = hotkey {
    let mask: CGEventMask = (1 << CGEventType.flagsChanged.rawValue) | (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.keyUp.rawValue)
    let callback: CGEventTapCallBack = { _, type, event, _ in
        let code = event.getIntegerValueField(.keyboardEventKeycode)
        if code == hotkey! {
            var isDown = false
            switch type {
            case .keyDown: isDown = true
            case .keyUp: isDown = false
            case .flagsChanged:
                let f = event.flags
                isDown = f.contains(.maskAlternate) || f.contains(.maskCommand) || f.contains(.maskControl) || f.contains(.maskShift) || f.contains(.maskSecondaryFn)
            default: return Unmanaged.passUnretained(event)
            }
            if isDown != hotkeyDown { hotkeyDown = isDown; note(isDown ? "hotkey down" : "hotkey up") }
        }
        return Unmanaged.passUnretained(event)
    }
    guard let tap = CGEvent.tapCreate(tap: .cgSessionEventTap, place: .headInsertEventTap, options: .listenOnly, eventsOfInterest: mask, callback: callback, userInfo: nil) else {
        note("error: cannot create event tap — grant Input Monitoring to your terminal (System Settings → Privacy & Security)")
        exit(3)
    }
    let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
    CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
    CGEvent.tapEnable(tap: tap, enable: true)
    note("hotkey \(key) armed")
}
// stdin EOF (parent gone) ends the helper
DispatchQueue.global().async {
    _ = FileHandle.standardInput.readDataToEndOfFile()
    exit(0)
}
CFRunLoopRun()
