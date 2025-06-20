import AVFoundation

let basePath = CommandLine.arguments[1]
let files = [
    "voice/meditation/home_mingxiang_1.mp3",
    "voice/meditation/home_mingxiang_2.mp3",
    "voice/meditation/mingxiang_1.mp3",
    "voice/meditation/mingxiang_2.mp3"
]

for file in files {
    let path = (basePath as NSString).appendingPathComponent(file)
    if let asset = AVAsset(url: URL(fileURLWithPath: path)) as? AVURLAsset {
        let duration = CMTimeGetSeconds(asset.duration)
        print("\(file): \(duration) seconds")
    } else {
        print("Error: Could not load \(file)")
    }
} 