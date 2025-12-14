import Foundation

extension TimeInterval {

    var srtTimecode: String {
        let totalMilliseconds = Int(self * 1000)
        let ms = totalMilliseconds % 1000
        let totalSeconds = totalMilliseconds / 1000
        let s = totalSeconds % 60
        let m = (totalSeconds / 60) % 60
        let h = totalSeconds / 3600

        return String(format: "%02d:%02d:%02d,%03d", h, m, s, ms)
    }
}
