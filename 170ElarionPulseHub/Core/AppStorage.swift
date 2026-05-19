import Combine
import Foundation

final class GameProgressStore: ObservableObject {
    static let shared = GameProgressStore()

    private enum Keys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let totalActivitiesPlayed = "totalActivitiesPlayed"
        static let totalStarsEarned = "totalStarsEarned"
        static let totalPlayTimeSeconds = "totalPlayTimeSeconds"
        static let starsPerActivity = "starsPerActivity"
        static let unlockedLevels = "unlockedLevels"
        static let streakCount = "streakCount"
        static let dayStreak = "dayStreak"
        static let lastPlayDayKey = "lastPlayDayKey"
        static let dailyMission = "dailyMission"
        static let bestRecords = "bestRecords"
        static let activityStats = "activityStats"
        static let seenTutorials = "seenTutorials"
        static let selectedShipSkin = "selectedShipSkin"
        static let soundEnabled = "soundEnabled"
        static let hapticsEnabled = "hapticsEnabled"
    }

    private let defaults: UserDefaults
    private var cancellables = Set<AnyCancellable>()

    @Published var hasSeenOnboarding: Bool {
        didSet { defaults.set(hasSeenOnboarding, forKey: Keys.hasSeenOnboarding) }
    }

    @Published var totalActivitiesPlayed: Int {
        didSet { defaults.set(totalActivitiesPlayed, forKey: Keys.totalActivitiesPlayed) }
    }

    @Published var totalStarsEarned: Int {
        didSet { defaults.set(totalStarsEarned, forKey: Keys.totalStarsEarned) }
    }

    @Published var totalPlayTimeSeconds: Int {
        didSet { defaults.set(totalPlayTimeSeconds, forKey: Keys.totalPlayTimeSeconds) }
    }

    @Published var starsPerActivity: [String: [String: [Int]]] {
        didSet { saveEncoded(starsPerActivity, forKey: Keys.starsPerActivity) }
    }

    @Published var unlockedLevels: [String: [String: Int]] {
        didSet { saveEncoded(unlockedLevels, forKey: Keys.unlockedLevels) }
    }

    @Published var streakCount: Int {
        didSet { defaults.set(streakCount, forKey: Keys.streakCount) }
    }

    @Published var dayStreak: Int {
        didSet { defaults.set(dayStreak, forKey: Keys.dayStreak) }
    }

    @Published var lastPlayDayKey: String {
        didSet { defaults.set(lastPlayDayKey, forKey: Keys.lastPlayDayKey) }
    }

    @Published var dailyMission: DailyMission? {
        didSet { saveEncoded(dailyMission, forKey: Keys.dailyMission) }
    }

    @Published var bestRecords: [String: LevelBestRecord] {
        didSet { saveEncoded(bestRecords, forKey: Keys.bestRecords) }
    }

    @Published var activityStats: [String: ActivitySessionStats] {
        didSet { saveEncoded(activityStats, forKey: Keys.activityStats) }
    }

    @Published var seenTutorials: Set<String> {
        didSet { defaults.set(Array(seenTutorials), forKey: Keys.seenTutorials) }
    }

    @Published var selectedShipSkin: String {
        didSet { defaults.set(selectedShipSkin, forKey: Keys.selectedShipSkin) }
    }

    @Published var soundEnabled: Bool {
        didSet { defaults.set(soundEnabled, forKey: Keys.soundEnabled) }
    }

    @Published var hapticsEnabled: Bool {
        didSet { defaults.set(hapticsEnabled, forKey: Keys.hapticsEnabled) }
    }

    static let levelsPerDifficulty = 10

    static var maxStarsPerActivity: Int {
        levelsPerDifficulty * 3 * Difficulty.allCases.count
    }

    var pilotRank: PilotRank {
        PilotRank.current(for: totalStarsEarned)
    }

    var selectedSkin: ShipSkin {
        ShipSkin.find(id: selectedShipSkin)
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        totalActivitiesPlayed = defaults.integer(forKey: Keys.totalActivitiesPlayed)
        totalStarsEarned = defaults.integer(forKey: Keys.totalStarsEarned)
        totalPlayTimeSeconds = defaults.integer(forKey: Keys.totalPlayTimeSeconds)
        streakCount = defaults.integer(forKey: Keys.streakCount)
        dayStreak = defaults.integer(forKey: Keys.dayStreak)
        lastPlayDayKey = defaults.string(forKey: Keys.lastPlayDayKey) ?? ""
        selectedShipSkin = defaults.string(forKey: Keys.selectedShipSkin) ?? "default"
        soundEnabled = defaults.object(forKey: Keys.soundEnabled) as? Bool ?? true
        hapticsEnabled = defaults.object(forKey: Keys.hapticsEnabled) as? Bool ?? true
        starsPerActivity = Self.load(from: defaults, key: Keys.starsPerActivity, default: [:])
        unlockedLevels = Self.load(from: defaults, key: Keys.unlockedLevels, default: [:])
        dailyMission = Self.load(from: defaults, key: Keys.dailyMission, default: nil as DailyMission?)
        bestRecords = Self.load(from: defaults, key: Keys.bestRecords, default: [:])
        activityStats = Self.load(from: defaults, key: Keys.activityStats, default: [:])
        if let saved = defaults.array(forKey: Keys.seenTutorials) as? [String] {
            seenTutorials = Set(saved)
        } else {
            seenTutorials = []
        }

        NotificationCenter.default.publisher(for: .progressReset)
            .sink { [weak self] _ in self?.reloadFromDefaults() }
            .store(in: &cancellables)

        refreshDailyMissionIfNeeded()
        updateDayStreak()
    }

    func refreshOnLaunch() {
        refreshDailyMissionIfNeeded()
        updateDayStreak()
    }

    // MARK: - Achievements

    var achievements: [AchievementDefinition] {
        AchievementDefinition.all
    }

    func isAchievementUnlocked(_ achievement: AchievementDefinition) -> Bool {
        achievement.isUnlocked(self)
    }

    func newlyUnlockedAchievements(comparedTo prior: AchievementSnapshot) -> [AchievementDefinition] {
        AchievementDefinition.all.filter { achievement in
            achievement.isUnlocked(self) && !prior.isUnlocked(achievement)
        }
    }

    func achievementSnapshot() -> AchievementSnapshot {
        AchievementSnapshot(store: self)
    }

    // MARK: - Levels & stars

    func stars(activityId: String, difficulty: Difficulty, level: Int) -> Int {
        let key = difficulty.rawValue
        guard let levels = starsPerActivity[activityId]?[key], level >= 0, level < levels.count else {
            return 0
        }
        return levels[level]
    }

    func isLevelUnlocked(activityId: String, difficulty: Difficulty, level: Int) -> Bool {
        if level == 0 { return true }
        let key = difficulty.rawValue
        let highest = unlockedLevels[activityId]?[key] ?? 0
        return level <= highest
    }

    func highestUnlockedLevel(activityId: String, difficulty: Difficulty) -> Int {
        unlockedLevels[activityId]?[difficulty.rawValue] ?? 0
    }

    func bestRecord(activityId: String, difficulty: Difficulty, level: Int) -> LevelBestRecord {
        bestRecords[Self.recordKey(activityId: activityId, difficulty: difficulty, level: level)] ?? LevelBestRecord()
    }

    func totalStars(for activityId: String) -> Int {
        guard let perDifficulty = starsPerActivity[activityId] else { return 0 }
        return perDifficulty.values.flatMap { $0 }.reduce(0, +)
    }

    func activityStat(for activityId: String) -> ActivitySessionStats {
        activityStats[activityId] ?? ActivitySessionStats()
    }

    func hasSeenTutorial(for activityId: String) -> Bool {
        seenTutorials.contains(activityId)
    }

    func markTutorialSeen(for activityId: String) {
        seenTutorials.insert(activityId)
    }

    func selectShipSkin(_ skin: ShipSkin) {
        guard skin.isUnlocked(totalStars: totalStarsEarned) else { return }
        selectedShipSkin = skin.id
    }

    // MARK: - Daily mission

    func refreshDailyMissionIfNeeded() {
        let today = DailyMission.todayKey()
        if dailyMission?.dayKey == today { return }
        dailyMission = generateDailyMission(for: today)
    }

    private func generateDailyMission(for dayKey: String) -> DailyMission {
        let activity = ActivityItem.all.randomElement() ?? ActivityItem.all[0]
        let difficulty = Difficulty.allCases.randomElement() ?? .easy
        let maxLevel = max(0, highestUnlockedLevel(activityId: activity.id, difficulty: difficulty))
        let level = Int.random(in: 0...maxLevel)
        return DailyMission(
            dayKey: dayKey,
            activityId: activity.id,
            difficultyRaw: difficulty.rawValue,
            level: level,
            isCompleted: false
        )
    }

    func completeDailyMissionIfMatching(activityId: String, difficulty: Difficulty, level: Int) -> Bool {
        guard var mission = dailyMission,
              mission.dayKey == DailyMission.todayKey(),
              !mission.isCompleted,
              mission.activityId == activityId,
              mission.difficulty == difficulty,
              mission.level == level else {
            return false
        }
        mission.isCompleted = true
        dailyMission = mission
        totalStarsEarned += 1
        return true
    }

    // MARK: - Day streak

    func updateDayStreak() {
        let today = DailyMission.todayKey()
        guard !today.isEmpty else { return }

        if lastPlayDayKey.isEmpty {
            dayStreak = 1
            lastPlayDayKey = today
            return
        }

        if lastPlayDayKey == today { return }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let lastDate = formatter.date(from: lastPlayDayKey),
              let todayDate = formatter.date(from: today) else {
            dayStreak = 1
            lastPlayDayKey = today
            return
        }

        let dayDiff = Calendar.current.dateComponents([.day], from: lastDate, to: todayDate).day ?? 0
        if dayDiff == 1 {
            dayStreak += 1
        } else if dayDiff > 1 {
            dayStreak = 1
        }
        lastPlayDayKey = today
    }

    // MARK: - Complete level

    func completeLevel(
        activityId: String,
        difficulty: Difficulty,
        level: Int,
        starsEarned: Int,
        playTimeSeconds: Int,
        sessionScore: Int = 0,
        survivalSeconds: Double = 0,
        peakCombo: Int = 0
    ) {
        let diffKey = difficulty.rawValue
        var activityStars = starsPerActivity[activityId] ?? [:]
        var levelStars = activityStars[diffKey] ?? Array(repeating: 0, count: Self.levelsPerDifficulty)
        while levelStars.count < Self.levelsPerDifficulty {
            levelStars.append(0)
        }

        let previous = levelStars[level]
        if starsEarned > previous {
            let delta = starsEarned - previous
            totalStarsEarned += delta
            levelStars[level] = starsEarned
            activityStars[diffKey] = levelStars
            starsPerActivity = starsPerActivity.merging([activityId: activityStars]) { _, new in new }
        }

        if starsEarned >= 1, level + 1 < Self.levelsPerDifficulty {
            var activityUnlocks = unlockedLevels[activityId] ?? [:]
            let current = activityUnlocks[diffKey] ?? 0
            if level + 1 > current {
                activityUnlocks[diffKey] = level + 1
                unlockedLevels = unlockedLevels.merging([activityId: activityUnlocks]) { _, new in new }
            }
        }

        updateBestRecord(
            activityId: activityId,
            difficulty: difficulty,
            level: level,
            score: sessionScore,
            survivalSeconds: survivalSeconds,
            combo: peakCombo
        )
        updateActivityStats(
            activityId: activityId,
            score: sessionScore,
            survivalSeconds: survivalSeconds,
            combo: peakCombo
        )

        totalActivitiesPlayed += 1
        totalPlayTimeSeconds += playTimeSeconds
        streakCount += 1
        updateDayStreak()
        _ = completeDailyMissionIfMatching(activityId: activityId, difficulty: difficulty, level: level)
    }

    private func updateBestRecord(
        activityId: String,
        difficulty: Difficulty,
        level: Int,
        score: Int,
        survivalSeconds: Double,
        combo: Int
    ) {
        let key = Self.recordKey(activityId: activityId, difficulty: difficulty, level: level)
        var record = bestRecords[key] ?? LevelBestRecord()
        if score > record.bestScore { record.bestScore = score }
        if survivalSeconds > record.bestSurvivalSeconds { record.bestSurvivalSeconds = survivalSeconds }
        if combo > record.bestCombo { record.bestCombo = combo }
        bestRecords[key] = record
    }

    func recordSession(
        activityId: String,
        score: Int = 0,
        survivalSeconds: Double = 0,
        combo: Int = 0,
        playTimeSeconds: Int = 0
    ) {
        updateActivityStats(
            activityId: activityId,
            score: score,
            survivalSeconds: survivalSeconds,
            combo: combo
        )
        if playTimeSeconds > 0 {
            totalPlayTimeSeconds += playTimeSeconds
        }
    }

    private func updateActivityStats(
        activityId: String,
        score: Int,
        survivalSeconds: Double,
        combo: Int
    ) {
        var stats = activityStats[activityId] ?? ActivitySessionStats()
        stats.sessionsPlayed += 1
        if score > stats.bestScore { stats.bestScore = score }
        if survivalSeconds > stats.bestSurvivalSeconds { stats.bestSurvivalSeconds = survivalSeconds }
        if combo > stats.highestCombo { stats.highestCombo = combo }
        activityStats[activityId] = stats
    }

    func resetAllProgress() {
        let domain = Bundle.main.bundleIdentifier ?? ""
        defaults.removePersistentDomain(forName: domain)
        defaults.synchronize()
        reloadFromDefaults()
        refreshDailyMissionIfNeeded()
        NotificationCenter.default.post(name: .progressReset, object: nil)
    }

    func formattedPlayTime() -> String {
        let hours = totalPlayTimeSeconds / 3600
        let minutes = (totalPlayTimeSeconds % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }

    static func recordKey(activityId: String, difficulty: Difficulty, level: Int) -> String {
        "\(activityId)|\(difficulty.rawValue)|\(level)"
    }

    private func reloadFromDefaults() {
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        totalActivitiesPlayed = defaults.integer(forKey: Keys.totalActivitiesPlayed)
        totalStarsEarned = defaults.integer(forKey: Keys.totalStarsEarned)
        totalPlayTimeSeconds = defaults.integer(forKey: Keys.totalPlayTimeSeconds)
        streakCount = defaults.integer(forKey: Keys.streakCount)
        dayStreak = defaults.integer(forKey: Keys.dayStreak)
        lastPlayDayKey = defaults.string(forKey: Keys.lastPlayDayKey) ?? ""
        selectedShipSkin = defaults.string(forKey: Keys.selectedShipSkin) ?? "default"
        soundEnabled = defaults.object(forKey: Keys.soundEnabled) as? Bool ?? true
        hapticsEnabled = defaults.object(forKey: Keys.hapticsEnabled) as? Bool ?? true
        starsPerActivity = Self.load(from: defaults, key: Keys.starsPerActivity, default: [:])
        unlockedLevels = Self.load(from: defaults, key: Keys.unlockedLevels, default: [:])
        dailyMission = Self.load(from: defaults, key: Keys.dailyMission, default: nil as DailyMission?)
        bestRecords = Self.load(from: defaults, key: Keys.bestRecords, default: [:])
        activityStats = Self.load(from: defaults, key: Keys.activityStats, default: [:])
        if let saved = defaults.array(forKey: Keys.seenTutorials) as? [String] {
            seenTutorials = Set(saved)
        } else {
            seenTutorials = []
        }
    }

    private func saveEncoded<T: Encodable>(_ value: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(value) {
            defaults.set(data, forKey: key)
        }
    }

    private static func load<T: Decodable>(from defaults: UserDefaults, key: String, default defaultValue: T) -> T {
        guard let data = defaults.data(forKey: key),
              let decoded = try? JSONDecoder().decode(T.self, from: data) else {
            return defaultValue
        }
        return decoded
    }
}

struct AchievementSnapshot {
    let totalStarsEarned: Int
    let totalActivitiesPlayed: Int
    let totalPlayTimeSeconds: Int

    init(store: GameProgressStore) {
        totalStarsEarned = store.totalStarsEarned
        totalActivitiesPlayed = store.totalActivitiesPlayed
        totalPlayTimeSeconds = store.totalPlayTimeSeconds
    }

    func isUnlocked(_ achievement: AchievementDefinition) -> Bool {
        switch achievement.id {
        case "first_star":
            return totalStarsEarned >= 1
        case "rookie_pilot":
            return totalActivitiesPlayed >= 10
        case "star_hoarder":
            return totalStarsEarned >= 50
        case "in_the_sky":
            return totalPlayTimeSeconds >= 3600
        case "star_collector":
            return totalStarsEarned >= 25
        case "star_master":
            return totalStarsEarned >= 75
        case "active_player":
            return totalActivitiesPlayed >= 25
        case "hundred_plays":
            return totalActivitiesPlayed >= 100
        default:
            return false
        }
    }
}
