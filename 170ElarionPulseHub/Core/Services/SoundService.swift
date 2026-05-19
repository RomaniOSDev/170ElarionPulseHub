import AudioToolbox

enum SoundService {
    private static var enabled: Bool {
        GameProgressStore.shared.soundEnabled
    }

    static func playSuccess() {
        guard enabled else { return }
        AudioServicesPlaySystemSound(1057)
    }

    static func playFail() {
        guard enabled else { return }
        AudioServicesPlaySystemSound(1521)
    }
}
