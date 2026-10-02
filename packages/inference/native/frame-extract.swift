// AVFoundation frame-extraction helper — the video
// equivalent of the audio path's afconvert doctrine: macOS-native codecs,
// zero vendored dependencies.
//
//   frame-extract <video> <outDir> [fps=2] [maxFrames=768]
//     → writes frame-%04d.png (RGB) + prints "N <count> W <w> H <h>"
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

let args = CommandLine.arguments
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
// Fragmented/malformed containers can load with an indefinite duration —
// CMTimeGetSeconds yields NaN and Int(NaN) is a Swift runtime TRAP. Fall
// back to the frame cap; the extraction loop below already stops at the
// first undecodable timestamp.
let seconds = CMTimeGetSeconds(duration)
let count = seconds.isFinite
    ? max(1, min(Int((seconds * fps).rounded(.up)), maxFrames))
    : maxFrames

let gen = AVAssetImageGenerator(asset: asset)
gen.appliesPreferredTrackTransform = true
gen.requestedTimeToleranceBefore = .zero
gen.requestedTimeToleranceAfter = .zero
// Bound DECODED memory at the source: the language pipeline's video pixel
// budget always downscales frames far below 1024px anyway (max_pixels
// 32·32·768 across t·h·w), so capping the longest edge here loses nothing
// it would have kept while keeping a 4K clip from materializing ~24 MB per
// frame (768 frames ≈ 17.8 GiB) before preprocessing.
gen.maximumSize = CGSize(width: 1024, height: 1024)

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
