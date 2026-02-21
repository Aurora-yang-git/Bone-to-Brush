import Observation
import SwiftUI

@Observable @MainActor
final class GameState {

    // MARK: Shared state

    var currentLevelIndex = 0
    var snappedPositions: [String: CGPoint] = [:]
    var freePositions: [String: CGPoint] = [:] // New: Free-floating pieces
    var isEvolving = false
    var evolutionIndex: Int? = nil
    var showReflection = false
    var showContinue = false
    var finishedAllLevels = false
    var pictographMerging = false

    // Phase transition overlay
    var showPhaseTransition = false
    var phaseTransitionText = ""

    // Hint text (auto-fades)
    var hintVisible = false

    // Visual Hint State
    var draggingPieceID: String? = nil // Track what is being dragged to show hints

    // Trace mode (Level 1-9)
    var traceProgress: CGFloat = 0
    var traceCompleted = false

    // MARK: Constants

    static let phaseTransitions: [Phase: String] = [
        .pictograph: "You have learned to see.\nNow learn to mark.",
        .ideograph: "You have learned to mark.\nNow learn to create.",
        .compound: "You have learned to create.\nNow learn how systems grow.",
    ]

    static let levelHints: [Int: String] = [
        1: "Trace the character on the stage",
        10: "Drag the pieces to the stage",
    ]

    // MARK: Computed

    var currentLevel: Level? {
        guard currentLevelIndex < Level.all.count else { return nil }
        return Level.all[currentLevelIndex]
    }

    var isTraceMode: Bool {
        guard let level = currentLevel else { return false }
        return level.id <= 9 && level.traceGuide != nil
    }

    // MARK: Actions

    func resetForCurrentLevel() {
        snappedPositions = [:]
        freePositions = [:]
        isEvolving = false
        evolutionIndex = nil
        showReflection = false
        showContinue = false
        pictographMerging = false
        draggingPieceID = nil
        traceProgress = 0
        traceCompleted = false

        if let level = currentLevel, Self.levelHints[level.id] != nil {
            hintVisible = true
        } else {
            hintVisible = false
        }
    }

    func advanceLevel() {
        guard !finishedAllLevels else { return }

        let currentPhase = currentLevel?.phase
        let nextIndex = currentLevelIndex + 1

        if nextIndex < Level.all.count {
            let nextPhase = Level.all[nextIndex].phase
            if currentPhase != nextPhase,
               let cp = currentPhase,
               let text = Self.phaseTransitions[cp]
            {
                phaseTransitionText = text
                showPhaseTransition = true
                currentLevelIndex = nextIndex
            } else {
                currentLevelIndex = nextIndex
                resetForCurrentLevel()
            }
        } else {
            finishedAllLevels = true
            showContinue = false
        }
    }

    func dismissPhaseTransition() {
        showPhaseTransition = false
        resetForCurrentLevel()
    }

    func canUsePiece(_ pieceID: String) -> Bool {
        snappedPositions[pieceID] == nil
            && freePositions[pieceID] == nil
            && !isEvolving
            && !finishedAllLevels
    }

    // Phase 2, 3, 4: drag to place
    func placePiece(_ pieceID: String, near location: CGPoint, stageSize: CGSize) -> Bool {
        guard let level = currentLevel else { return false }

        // If it's already snapped, don't move it.
        if snappedPositions[pieceID] != nil { return false }

        // Check if it hits a target slot.
        if let norm = level.targetSlots[pieceID] {
            let target = CGPoint(x: norm.x * stageSize.width, y: norm.y * stageSize.height)
            let threshold = min(stageSize.width, stageSize.height) * 0.15

            if hypot(location.x - target.x, location.y - target.y) <= threshold {
                withAnimation(.easeOut(duration: 0.18)) {
                    snappedPositions[pieceID] = target
                    freePositions[pieceID] = nil
                }
                showPlacementFocus(for: pieceID)

                if level.solution.allSatisfy({ snappedPositions[$0] != nil }) {
                    startEvolution()
                }
                return true
            }
        }

        // If not snapped, place it freely on stage.
        let clampedLocation = clampedFreePosition(location, stageSize: stageSize)
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            freePositions[pieceID] = clampedLocation
        }
        showPlacementFocus(for: pieceID)
        return true
    }

    func updateHover(pieceID: String, location: CGPoint, stageSize: CGSize) {
        guard let level = currentLevel, let norm = level.targetSlots[pieceID] else {
            draggingPieceID = nil
            return
        }

        let target = CGPoint(x: norm.x * stageSize.width, y: norm.y * stageSize.height)
        let threshold = min(stageSize.width, stageSize.height) * 0.25

        if hypot(location.x - target.x, location.y - target.y) <= threshold {
            withAnimation(.easeInOut(duration: 0.2)) {
                draggingPieceID = pieceID
            }
        } else {
            withAnimation(.easeInOut(duration: 0.2)) {
                draggingPieceID = nil
            }
        }
    }

    func clearHover() {
        withAnimation { draggingPieceID = nil }
    }

    func clearTrace() {
        guard isTraceMode else { return }
        traceProgress = 0
        traceCompleted = false
    }

    func updateTrace(points: [CGPoint], didEnd: Bool) {
        guard isTraceMode,
              !isEvolving,
              !finishedAllLevels,
              let guide = currentLevel?.traceGuide
        else { return }

        let coverage = traceCoverage(points: points, guide: guide)
        if coverage > traceProgress {
            withAnimation(.easeInOut(duration: 0.12)) {
                traceProgress = coverage
            }
        } else if didEnd {
            // Keep progress monotonic while tracing, but allow reset only from clear button.
            traceProgress = max(traceProgress, coverage)
        }

        guard !traceCompleted, traceProgress >= guide.completionThreshold else { return }
        traceCompleted = true
        hintVisible = false
        startEvolution()
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

    private func clampedFreePosition(_ location: CGPoint, stageSize: CGSize) -> CGPoint {
        // Keep center inside the stage so the dropped tile never disappears out of bounds.
        let halfTile: CGFloat = 33
        let margin: CGFloat = 8
        let minX = halfTile + margin
        let maxX = stageSize.width - halfTile - margin
        let minY = halfTile + margin
        let maxY = stageSize.height - halfTile - margin
        return CGPoint(
            x: min(max(location.x, minX), maxX),
            y: min(max(location.y, minY), maxY)
        )
    }

    private func showPlacementFocus(for pieceID: String) {
        withAnimation(.easeInOut(duration: 0.12)) {
            draggingPieceID = pieceID
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) { [weak self] in
            guard let self else { return }
            if self.draggingPieceID == pieceID {
                withAnimation(.easeOut(duration: 0.18)) {
                    self.draggingPieceID = nil
                }
            }
        }
    }

    // MARK: Evolution sequence

    private func startEvolution() {
        guard let level = currentLevel, !isEvolving else { return }
        isEvolving = true
        hintVisible = false

        Task {
            if level.phase == .pictograph {
                withAnimation(.easeInOut(duration: 0.5)) {
                    pictographMerging = true
                }
                try? await Task.sleep(for: .milliseconds(500))
            } else {
                try? await Task.sleep(for: .milliseconds(420))
            }

            for index in 0..<level.evolutionFrames.count {
                withAnimation(.easeInOut(duration: 0.28)) { self.evolutionIndex = index }
                if index < level.evolutionFrames.count - 1 {
                    try? await Task.sleep(for: .milliseconds(380))
                }
            }

            try? await Task.sleep(for: .milliseconds(220))
            withAnimation(.easeInOut(duration: 0.28)) { self.showReflection = true }
            try? await Task.sleep(for: .milliseconds(140))
            withAnimation(.easeInOut(duration: 0.22)) { self.showContinue = true }
            self.isEvolving = false
        }
    }
}
