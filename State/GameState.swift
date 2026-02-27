import Observation
import SwiftUI

@Observable @MainActor
final class GameState {
    enum MotionContract {
        static let standardSpring = Animation.spring(response: 0.28, dampingFraction: 0.82)
        static let fastEase = Animation.easeInOut(duration: 0.18)
        static let traceProgressEase = Animation.easeInOut(duration: 0.12)
        static let microEase = Animation.easeInOut(duration: 0.14)
        static let tilePressEase = Animation.easeInOut(duration: 0.12)
        static let traceRevealEase = Animation.easeInOut(duration: 0.38)
        static let resultRevealEase = Animation.easeInOut(duration: 0.18)
        static let introTitleRevealEase = Animation.easeOut(duration: 0.52)
        static let introHaloRevealEase = Animation.easeOut(duration: 0.60)
        static let introButtonRevealEase = Animation.easeOut(duration: 0.45)
        static let introFooterRevealEase = Animation.easeOut(duration: 0.40)
        static let endingTitleRevealEase = Animation.easeOut(duration: 0.50)
        static let endingGlyphRevealSpring = Animation.spring(response: 0.28, dampingFraction: 0.80)
        static let endingButtonRevealEase = Animation.easeOut(duration: 0.42)
        static let successSpring = Animation.spring(response: 0.32, dampingFraction: 0.80)
        static let repelSpring = Animation.spring(response: 0.18, dampingFraction: 0.62)
        static let returnSpring = Animation.spring(response: 0.24, dampingFraction: 0.76)

        static let defaultAdvanceDelaySeconds: Double = 0.9
        static let tracingAdvanceDelaySeconds: Double = 1.0
        static let combinationAdvanceDelaySeconds: Double = 1.0
        static let repelClearDelay: Duration = .milliseconds(650)
        static let returnClearDelay: Duration = .milliseconds(540)
        static let feedbackClearDelay: Duration = .milliseconds(420)
        static let transientFeedbackClearDelay: Duration = .milliseconds(1150)
        static let secondaryResultHoldDelay: Duration = .milliseconds(850)
        static let evolutionStageDuration: Duration = .milliseconds(1650)

        static let quizRevealDelay: Duration = .milliseconds(320)
        static let quizAutoAdvanceDelay: Duration = .milliseconds(1200)
        static let quizWrongResetDelay: Duration = .milliseconds(650)

        static let repelOffsetX: CGFloat = 18
        static let returnOffsetY: CGFloat = 176
        static let returningScale: CGFloat = 0.82
    }

    // MARK: App flow
    var flowState: AppFlowState = .intro {
        didSet {
            // #region agent log
            AgentRuntimeDebugLogger.log(
                hypothesisID: "H6",
                location: "GameState.swift:46",
                message: "flowState changed",
                data: [
                    "oldValue": "\(oldValue)",
                    "newValue": "\(flowState)",
                    "currentLevelIndex": currentLevelIndex,
                ]
            )
            // #endregion
        }
    }
    var currentLevelIndex = 0 {
        didSet {
            // #region agent log
            AgentRuntimeDebugLogger.log(
                hypothesisID: "H6",
                location: "GameState.swift:57",
                message: "currentLevelIndex changed",
                data: [
                    "oldValue": oldValue,
                    "newValue": currentLevelIndex,
                    "flowState": "\(flowState)",
                ]
            )
            // #endregion
        }
    }
    var showLevelMenu = false
    var audioEnabled = false
    var scriptDisplayMode: ScriptDisplayMode = .modern
    var a11yPreviewVoiceOverEnabled = false

    // MARK: Tracing state
    var traceProgress: CGFloat = 0
    var traceCompleted = false
    var traceStartedAt: Date? = nil

    // MARK: Quiz state
    var quizSelectedOptionID: String? = nil
    var quizAnswered = false
    var quizWasCorrect = false
    var quizFeedback = ""
    var quizShowExplanation = false

    // MARK: Combination state
    var combinationInventory: [InventoryToken] = []
    var combinationWorkbench: [String] = []
    var combinationFeedback = ""
    var combinationResultGlyph = ""
    var combinationSolvedTarget = false

    // MARK: Free mode state
    var freeInventory: [InventoryToken] = []
    var freeWorkbench: [String] = []
    var freeFeedback = ""
    var freeDiscoveredGlyphs: [String] = []
    var freeReachedGoal = false

    // MARK: Shared constants
    static let minimumTraceDuration: TimeInterval = 1.2
    private var advanceTask: Task<Void, Never>? = nil
    private var quizTask: Task<Void, Never>? = nil

    // MARK: Computed
    let levels: [WebLevel]
    var currentLevel: WebLevel? {
        guard currentLevelIndex >= 0 && currentLevelIndex < levels.count else { return nil }
        return levels[currentLevelIndex]
    }
    var isLastLevel: Bool { currentLevelIndex == levels.count - 1 }

    init() {
        self.levels = WebLevel.all
        // #region agent log
        AgentRuntimeDebugLogger.log(
            hypothesisID: "H6",
            location: "GameState.swift:116",
            message: "GameState initialized",
            data: [
                "levelsCount": levels.count,
                "initialFlowState": "\(flowState)",
                "initialLevelIndex": currentLevelIndex,
                "gameStateID": ObjectIdentifier(self).hashValue,
            ]
        )
        // #endregion
    }

    // MARK: App actions
    func startJourney() {
        // #region agent log
        AgentRuntimeDebugLogger.log(
            hypothesisID: "H1",
            location: "GameState.swift:95",
            message: "startJourney invoked",
            data: [
                "flowStateBefore": "\(flowState)",
                "currentLevelIndexBefore": currentLevelIndex,
                "levelsCount": levels.count,
            ]
        )
        // #endregion
        enterPlaying(at: 0)
    }

    func restartJourney() {
        // #region agent log
        AgentRuntimeDebugLogger.log(
            hypothesisID: "H6",
            location: "GameState.swift:124",
            message: "restartJourney invoked",
            data: [
                "flowStateBefore": "\(flowState)",
                "currentLevelIndexBefore": currentLevelIndex,
            ]
        )
        // #endregion
        advanceTask?.cancel()
        quizTask?.cancel()
        flowState = .intro
        showLevelMenu = false
        currentLevelIndex = 0
        resetForCurrentLevel()
    }

    func jumpToLevel(_ index: Int) {
        guard levels.indices.contains(index) else { return }
        enterPlaying(at: index)
    }

    func advanceLevel() {
        let next = currentLevelIndex + 1
        guard levels.indices.contains(next) else {
            flowState = .ending
            showLevelMenu = false
            return
        }
        currentLevelIndex = next
        resetForCurrentLevel()
    }

    func scheduleAdvance(delaySeconds: Double = MotionContract.defaultAdvanceDelaySeconds) {
        advanceTask?.cancel()
        let expectedLevel = currentLevel?.id
        advanceTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(delaySeconds))
            guard let self else { return }
            guard self.currentLevel?.id == expectedLevel else { return }
            self.advanceLevel()
        }
    }

    func resetForCurrentLevel() {
        advanceTask?.cancel()
        quizTask?.cancel()
        traceProgress = 0
        traceCompleted = false
        traceStartedAt = nil

        quizSelectedOptionID = nil
        quizAnswered = false
        quizWasCorrect = false
        quizFeedback = ""
        quizShowExplanation = false

        combinationInventory = []
        combinationWorkbench = []
        combinationFeedback = ""
        combinationResultGlyph = ""
        combinationSolvedTarget = false

        freeInventory = []
        freeWorkbench = []
        freeFeedback = ""
        freeDiscoveredGlyphs = []
        freeReachedGoal = false

        guard let level = currentLevel else { return }
        if let combination = level.combination {
            combinationInventory = combination.baseInventory
        }
        if let free = level.free {
            freeInventory = free.availableItems
        }
    }

    // MARK: Tracing
    func clearTrace() {
        advanceTask?.cancel()
        traceProgress = 0
        traceCompleted = false
        traceStartedAt = nil
    }

    func updateTrace(points: [CGPoint], didEnd: Bool, guide: TraceGuide) {
        guard !traceCompleted else { return }

        if traceStartedAt == nil, !points.isEmpty {
            traceStartedAt = Date()
        }

        let coverage = traceCoverage(points: points, guide: guide)
        if coverage > traceProgress {
            withAnimation(MotionContract.traceProgressEase) {
                traceProgress = coverage
            }
        } else if didEnd {
            // Keep progress monotonic while tracing, but allow reset only from clear button.
            traceProgress = max(traceProgress, coverage)
        }

        guard didEnd else { return }
        guard let startedAt = traceStartedAt else { return }
        guard Date().timeIntervalSince(startedAt) >= Self.minimumTraceDuration else { return }
        traceProgress = max(traceProgress, min(guide.completionThreshold, 1))
    }

    func confirmTrace() {
        guard traceProgress > 0.01 else { return }
        traceCompleted = true
    }

    private func traceCoverage(points: [CGPoint], guide: TraceGuide) -> CGFloat {
        guard !points.isEmpty else { return 0 }
        let guidePoints = guide.strokes.flatMap(\.points)
        guard !guidePoints.isEmpty else { return 0 }

        let tolerance: CGFloat = 0.08
        let coveredCount = guidePoints.reduce(into: 0) { count, guidePoint in
            if points.contains(where: { hypot($0.x - guidePoint.x, $0.y - guidePoint.y) <= tolerance }) {
                count += 1
            }
        }
        return min(CGFloat(coveredCount) / CGFloat(guidePoints.count), 1)
    }

    // MARK: Quiz
    func chooseQuizOption(_ id: String) {
        guard let quiz = currentLevel?.quiz else { return }
        guard !quizAnswered else { return }
        guard let option = quiz.options.first(where: { $0.id == id }) else { return }
        quizTask?.cancel()
        quizSelectedOptionID = id
        quizAnswered = true
        quizWasCorrect = option.isCorrect
        quizFeedback = ""
        quizShowExplanation = false

        if option.isCorrect {
            let expectedLevelID = currentLevel?.id
            quizTask = Task { [weak self] in
                try? await Task.sleep(for: MotionContract.quizRevealDelay)
                guard let self else { return }
                guard self.currentLevel?.id == expectedLevelID else { return }
                withAnimation(MotionContract.fastEase) {
                    self.quizShowExplanation = true
                    self.quizFeedback = quiz.displayExplanation(mode: self.scriptDisplayMode)
                }
            }
        } else {
            let levelID = currentLevel?.id
            quizTask = Task { @MainActor [weak self] in
                guard let self else { return }
                try? await Task.sleep(for: MotionContract.quizWrongResetDelay)
                guard self.currentLevel?.id == levelID else { return }
                self.quizSelectedOptionID = nil
                self.quizAnswered = false
                self.quizWasCorrect = false
                self.quizFeedback = ""
                self.quizShowExplanation = false
            }
        }
    }

    // MARK: Combination
    func dropCombinationToken(_ id: String) {
        guard combinationWorkbench.count < 3 else { return }
        combinationWorkbench.append(id)
    }

    func undoCombinationToken() {
        _ = combinationWorkbench.popLast()
    }

    func clearCombinationWorkbench() {
        combinationWorkbench = []
    }

    func combineWorkbench() {
        guard let level = currentLevel, let combination = level.combination else { return }
        guard combinationWorkbench.count >= 2 else {
            combinationFeedback = "Drop at least two pieces before combining."
            return
        }

        let key = ingredientKey(combinationWorkbench)
        if let distractor = combination.distractors.first(where: { ingredientKey($0.ingredients) == key }) {
            combinationFeedback = distractor.message
            combinationWorkbench = []
            return
        }

        guard let recipe = combination.recipes.first(where: { ingredientKey($0.ingredients) == key }) else {
            combinationFeedback = "Those pieces do not form a known character."
            combinationWorkbench = []
            return
        }

        combinationResultGlyph = recipe.resultGlyph
        combinationFeedback = "\(recipe.resultGlyph) · \(recipe.resultMeaning). \(recipe.explanation)"
        if !combinationInventory.contains(where: { $0.id == recipe.resultPieceID }) {
            combinationInventory.append(
                InventoryToken(
                    id: recipe.resultPieceID,
                    icon: recipe.resultGlyph,
                    label: recipe.resultMeaning
                )
            )
        }
        combinationWorkbench = []

        if recipe.resultGlyph == combination.targetChar {
            combinationSolvedTarget = true
        }
    }

    // MARK: Free mode
    func dropFreeToken(_ id: String) {
        guard freeWorkbench.count < 3 else { return }
        freeWorkbench.append(id)
    }

    func undoFreeToken() {
        _ = freeWorkbench.popLast()
    }

    func clearFreeWorkbench() {
        freeWorkbench = []
    }

    func combineFreeWorkbench() {
        guard let free = currentLevel?.free else { return }
        guard freeWorkbench.count >= 2 else {
            freeFeedback = "Pick at least two pieces."
            return
        }

        let key = ingredientKey(freeWorkbench)
        guard let recipe = free.validRecipes.first(where: { ingredientKey($0.ingredients) == key }) else {
            freeFeedback = "No character formed. Try another combination."
            freeWorkbench = []
            return
        }

        freeFeedback = "\(recipe.resultGlyph) · \(recipe.resultMeaning). \(recipe.explanation)"
        if !freeInventory.contains(where: { $0.id == recipe.resultPieceID }) {
            freeInventory.append(
                InventoryToken(
                    id: recipe.resultPieceID,
                    icon: recipe.resultGlyph,
                    label: recipe.resultMeaning
                )
            )
        }
        if !freeDiscoveredGlyphs.contains(recipe.resultGlyph) {
            freeDiscoveredGlyphs.append(recipe.resultGlyph)
        }
        freeWorkbench = []

        if freeDiscoveredGlyphs.count >= free.targetCount {
            freeReachedGoal = true
            freeFeedback = free.finalMessage
        }
    }

    private func ingredientKey(_ ids: [String]) -> String {
        ids.sorted().joined(separator: "|")
    }

    private func enterPlaying(at index: Int) {
        guard levels.indices.contains(index) else { return }
        // #region agent log
        AgentRuntimeDebugLogger.log(
            hypothesisID: "H1",
            location: "GameState.swift:363",
            message: "enterPlaying accepted index",
            data: [
                "targetIndex": index,
                "flowStateBefore": "\(flowState)",
                "showLevelMenuBefore": showLevelMenu,
            ]
        )
        // #endregion
        advanceTask?.cancel()
        quizTask?.cancel()
        showLevelMenu = false
        currentLevelIndex = index
        flowState = .playing
        resetForCurrentLevel()
        // #region agent log
        AgentRuntimeDebugLogger.log(
            hypothesisID: "H3",
            location: "GameState.swift:371",
            message: "enterPlaying completed",
            data: [
                "flowStateAfter": "\(flowState)",
                "currentLevelIndexAfter": currentLevelIndex,
                "currentLevelExists": currentLevel != nil,
                "currentLevelType": "\(String(describing: currentLevel?.type))",
                "currentLevelID": currentLevel?.id ?? -1,
            ]
        )
        // #endregion
    }
}
