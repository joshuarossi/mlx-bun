// AVFoundation frame-extraction sidecar probe (PLAN 14w) — the video
// equivalent of the audio path's afconvert doctrine: macOS-native codecs,
// zero vendored dependencies.
//
//   frame-extract <video> <outDir> [fps=2] [maxFrames=768]
//     → writes frame-%04d.png (RGB) + prints "N <count> W <w> H <h>"
//   frame-extract --make-fixture <out.mov>
//     → writes the deterministic 6-frame 320x240 gradient test clip
//
// Sampling mirrors mlx-vlm's do_sample_frames: timestamps k/fps for
// k = 0..min(ceil(duration*fps), maxFrames)-1, precise tolerance.

import AVFoundation
import Foundation
import ImageIO
import UniformTypeIdentifiers

func die(_ msg: String) -> Never {
    FileHandle.standardError.write((msg + "\n").data(using: .utf8)!)
    exit(1)
}

func makeFixture(_ path: String) {
    let url = URL(fileURLWithPath: path)
    try? FileManager.default.removeItem(at: url)
    guard let writer = try? AVAssetWriter(outputURL: url, fileType: .mov) else {
        die("AVAssetWriter init failed")
    }
    let W = 320, H = 240, FRAMES = 6
    let settings: [String: Any] = [
        AVVideoCodecKey: AVVideoCodecType.h264,
        AVVideoWidthKey: W,
        AVVideoHeightKey: H,
    ]
    let input = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
    let adaptor = AVAssetWriterInputPixelBufferAdaptor(
        assetWriterInput: input,
        sourcePixelBufferAttributes: [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB,
            kCVPixelBufferWidthKey as String: W,
            kCVPixelBufferHeightKey as String: H,
        ])
    writer.add(input)
    writer.startWriting()
    writer.startSession(atSourceTime: .zero)
    for f in 0..<FRAMES {
        while !input.isReadyForMoreMediaData { Thread.sleep(forTimeInterval: 0.01) }
        var pb: CVPixelBuffer?
        CVPixelBufferCreate(nil, W, H, kCVPixelFormatType_32ARGB, nil, &pb)
        guard let pixelBuffer = pb else { die("CVPixelBufferCreate failed") }
        CVPixelBufferLockBaseAddress(pixelBuffer, [])
        let base = CVPixelBufferGetBaseAddress(pixelBuffer)!
        let bpr = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let p = base.assumingMemoryBound(to: UInt8.self)
        for y in 0..<H {
            for x in 0..<W {
                let o = y * bpr + x * 4
                p[o] = 255
                p[o + 1] = UInt8((x * 255 / W + f * 20) % 256)
                p[o + 2] = UInt8((y * 255 / H + f * 10) % 256)
                p[o + 3] = UInt8(((x + y) * 255 / (W + H) + f * 30) % 256)
            }
        }
        CVPixelBufferUnlockBaseAddress(pixelBuffer, [])
        adaptor.append(pixelBuffer, withPresentationTime: CMTime(value: CMTimeValue(f), timescale: 2))
    }
    input.markAsFinished()
    let sem = DispatchSemaphore(value: 0)
    writer.finishWriting { sem.signal() }
    sem.wait()
    guard writer.status == .completed else { die("finishWriting status \(writer.status.rawValue)") }
    print("fixture \(path)")
}

let args = CommandLine.arguments
if args.count >= 3 && args[1] == "--make-fixture" {
    makeFixture(args[2])
    exit(0)
}
guard args.count >= 3 else { die("usage: frame-extract <video> <outDir> [fps] [maxFrames]") }
let videoPath = args[1]
let outDir = args[2]
let fps = args.count > 3 ? Double(args[3]) ?? 2.0 : 2.0
let maxFrames = args.count > 4 ? Int(args[4]) ?? 768 : 768

let asset = AVURLAsset(url: URL(fileURLWithPath: videoPath))
let sem = DispatchSemaphore(value: 0)
var duration = CMTime.zero
var loadError: Error?
Task {
    do { duration = try await asset.load(.duration) } catch { loadError = error }
    sem.signal()
}
sem.wait()
if let e = loadError { die("asset load failed: \(e.localizedDescription)") }
let seconds = CMTimeGetSeconds(duration)
let count = max(1, min(Int((seconds * fps).rounded(.up)), maxFrames))

let gen = AVAssetImageGenerator(asset: asset)
gen.appliesPreferredTrackTransform = true
gen.requestedTimeToleranceBefore = .zero
gen.requestedTimeToleranceAfter = .zero

try? FileManager.default.createDirectory(
    atPath: outDir, withIntermediateDirectories: true)
var written = 0
var lastW = 0, lastH = 0
for k in 0..<count {
    let t = CMTime(seconds: Double(k) / fps, preferredTimescale: 600)
    let img: CGImage
    do {
        img = try gen.copyCGImage(at: t, actualTime: nil)
    } catch {
        // Past-end sampling on short clips: stop at the last decodable frame.
        break
    }
    lastW = img.width
    lastH = img.height
    let out = URL(fileURLWithPath: String(format: "%@/frame-%04d.png", outDir, k))
    guard let dest = CGImageDestinationCreateWithURL(
        out as CFURL, UTType.png.identifier as CFString, 1, nil)
    else { die("png destination failed") }
    CGImageDestinationAddImage(dest, img, nil)
    guard CGImageDestinationFinalize(dest) else { die("png write failed") }
    written += 1
}
guard written > 0 else { die("no frames decodable from \(videoPath)") }
print("N \(written) W \(lastW) H \(lastH)")
