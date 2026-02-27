import Foundation

// MARK: - VoiceGuideScriptBuilder
// Converts a WebLevel + current GameState snapshot into an ordered
// list of VoiceGuideItems that VoiceGuidePlayer will narrate one by one.

enum VoiceGuideScriptBuilder {

    struct Context {
        let level: WebLevel
        let mode: ScriptDisplayMode
        let totalLevels: Int
        // Tracing
        var traceProgress: CGFloat = 0
        var traceCompleted: Bool = false
        // Quiz
        var quizSelectedOptionID: String? = nil
        var quizAnswered: Bool = false
        var quizWasCorrect: Bool = false
        var quizFeedback: String = ""
        // Combination / Free
        var placedItemLabels: [String] = []
        var combinationFeedback: String = ""
        var freeDiscoveredGlyphs: [String] = []
        var freeTargetCount: Int = 0
    }

    static func build(context: Context) -> [VoiceGuideItem] {
        let level = context.level
        let mode = context.mode
        let title = level.displayTitle(mode: mode)
        var items: [VoiceGuideItem] = []

        // ── Chapter header (always first) ──────────────────────────────
        items.append(VoiceGuideItem(
            id: "header",
            text: "Chapter \(level.id) of \(context.totalLevels). \(title).",
            kind: .header
        ))

        // ── Type-specific body ──────────────────────────────────────────
        switch level.type {

        case .learn:
            if let learn = level.learn {
                items.append(VoiceGuideItem(
                    id: "instruction",
                    text: learn.instruction,
                    kind: .body
                ))
                items.append(VoiceGuideItem(
                    id: "character",
                    text: "Character: \(learn.modernGlyph). Meaning: \(learn.meaning).",
                    kind: .image
                ))
                items.append(VoiceGuideItem(
                    id: "interaction",
                    text: "Interaction type: \(learn.interaction.rawValue). Follow the on-screen prompt.",
                    kind: .body
                ))
                items.append(VoiceGuideItem(
                    id: "control-continue",
                    text: "After the character transforms, tap Continue to proceed.",
                    kind: .control
                ))
            }

        case .observe:
            guard let observe = level.observe else { break }
            items.append(VoiceGuideItem(
                id: "instruction",
                text: observe.instruction,
                kind: .body
            ))
            items.append(VoiceGuideItem(
                id: "image-oracle",
                text: "The oracle pictograph shows the original drawn shape: \(observe.oracleGlyph).",
                kind: .image
            ))
            items.append(VoiceGuideItem(
                id: "image-modern",
                text: "The modern character is: \(observe.modernGlyph).",
                kind: .image
            ))
            items.append(VoiceGuideItem(
                id: "detail",
                text: observe.detail,
                kind: .body
            ))
            items.append(VoiceGuideItem(
                id: "control-continue",
                text: "Tap the Continue button to proceed to the next chapter.",
                kind: .control
            ))

        case .tracing:
            guard let tracing = level.tracing else { break }
            let character = tracing.displayCharacter(mode: mode)
            let meaning   = tracing.displayMeaning(mode: mode)
            let explanation = tracing.displayExplanation(mode: mode)
            items.append(VoiceGuideItem(
                id: "character",
                text: "Character: \(character). Meaning: \(meaning).",
                kind: .image
            ))
            items.append(VoiceGuideItem(
                id: "instruction",
                text: "Trace the strokes of the character on the canvas below.",
                kind: .body
            ))
            items.append(VoiceGuideItem(
                id: "explanation",
                text: explanation,
                kind: .body
            ))
            if context.traceCompleted {
                items.append(VoiceGuideItem(
                    id: "state-complete",
                    text: "Tracing complete! Moving to the next chapter automatically.",
                    kind: .state
                ))
            } else {
                let pct = Int(context.traceProgress * 100)
                items.append(VoiceGuideItem(
                    id: "state-progress",
                    text: "Current tracing progress: \(pct) percent.",
                    kind: .state
                ))
                items.append(VoiceGuideItem(
                    id: "control-trace",
                    text: "Tap the Auto trace button to complete tracing. Or tap Clear to start over, then Confirm to submit.",
                    kind: .control
                ))
            }

        case .draw:
            guard let draw = level.draw else { break }
            let character   = draw.displayCharacter(mode: mode)
            let meaning     = draw.displayMeaning(mode: mode)
            let instruction = draw.displayInstruction(mode: mode)
            let explanation = draw.displayExplanation(mode: mode)
            items.append(VoiceGuideItem(
                id: "instruction",
                text: instruction,
                kind: .body
            ))
            items.append(VoiceGuideItem(
                id: "character",
                text: "Reference character: \(character). Meaning: \(meaning).",
                kind: .image
            ))
            items.append(VoiceGuideItem(
                id: "explanation",
                text: explanation,
                kind: .body
            ))
            items.append(VoiceGuideItem(
                id: "control-draw",
                text: "Draw from memory on the canvas. Tap Clear to start again. Once you have drawn enough, tap Confirm.",
                kind: .control
            ))

        case .quiz:
            guard let quiz = level.quiz else { break }
            let question = quiz.displayQuestion(mode: mode)
            items.append(VoiceGuideItem(
                id: "question",
                text: question,
                kind: .body
            ))
            for (index, option) in quiz.options.enumerated() {
                let icon  = option.displayIcon(mode: mode)
                let label = option.displayLabel(mode: mode)
                var stateDesc = ""
                if let selectedID = context.quizSelectedOptionID, selectedID == option.id {
                    stateDesc = context.quizAnswered
                        ? (context.quizWasCorrect ? " — Correct!" : " — Incorrect.")
                        : " — Selected."
                }
                items.append(VoiceGuideItem(
                    id: "option-\(index)",
                    text: "Option \(index + 1): \(label), shown as \(icon).\(stateDesc)",
                    kind: .body
                ))
            }
            if context.quizAnswered, !context.quizFeedback.isEmpty {
                items.append(VoiceGuideItem(
                    id: "feedback",
                    text: context.quizFeedback,
                    kind: .state
                ))
            }
            if !context.quizAnswered {
                items.append(VoiceGuideItem(
                    id: "control",
                    text: "Tap an option to select your answer.",
                    kind: .control
                ))
            }

        case .drag:
            guard let drag = level.drag else { break }
            let instruction  = drag.displayInstruction(mode: mode)
            let targetMeaning = drag.displayTargetMeaning(mode: mode)
            items.append(VoiceGuideItem(
                id: "instruction",
                text: instruction,
                kind: .body
            ))
            items.append(VoiceGuideItem(
                id: "target",
                text: "Target character: \(drag.targetChar). Meaning: \(targetMeaning).",
                kind: .state
            ))
            for (i, token) in drag.baseInventory.enumerated() {
                let label = token.displayLabel(mode: mode)
                let icon  = token.displayIcon(mode: mode)
                items.append(VoiceGuideItem(
                    id: "inventory-\(i)",
                    text: "Available piece \(i + 1): \(label), shown as \(icon).",
                    kind: .body
                ))
            }
            items.append(VoiceGuideItem(
                id: "control",
                text: "Tap the inventory pieces to place them into the drop slots. The result appears when both slots are filled.",
                kind: .control
            ))

        case .combination:
            guard let combination = level.combination else { break }
            let instruction  = combination.displayInstruction(mode: mode)
            let targetMeaning = combination.displayTargetMeaning(mode: mode)
            items.append(VoiceGuideItem(
                id: "instruction",
                text: instruction,
                kind: .body
            ))
            items.append(VoiceGuideItem(
                id: "target",
                text: "Target character: \(combination.targetChar). Meaning: \(targetMeaning).",
                kind: .state
            ))
            for (i, token) in combination.baseInventory.enumerated() {
                let label = token.displayLabel(mode: mode)
                let icon  = token.displayIcon(mode: mode)
                items.append(VoiceGuideItem(
                    id: "inventory-\(i)",
                    text: "Available piece \(i + 1): \(label), shown as \(icon).",
                    kind: .body
                ))
            }
            if context.placedItemLabels.isEmpty {
                items.append(VoiceGuideItem(
                    id: "canvas-empty",
                    text: "The combination zone is empty.",
                    kind: .state
                ))
            } else {
                let placed = context.placedItemLabels.joined(separator: ", ")
                items.append(VoiceGuideItem(
                    id: "canvas-state",
                    text: "On the canvas: \(placed).",
                    kind: .state
                ))
            }
            if !context.combinationFeedback.isEmpty {
                items.append(VoiceGuideItem(
                    id: "feedback",
                    text: context.combinationFeedback,
                    kind: .state
                ))
            }
            items.append(VoiceGuideItem(
                id: "control",
                text: "Tap an inventory piece to add it to the canvas. Use the Layout and Swap buttons to change orientation. The combination triggers automatically.",
                kind: .control
            ))

        case .guess:
            guard let guess = level.guess else { break }
            let instruction = guess.displayInstruction(mode: mode)
            items.append(VoiceGuideItem(
                id: "instruction",
                text: instruction,
                kind: .body
            ))
            let ingredientTexts = guess.ingredients.map { "\($0.icon)" }.joined(separator: " and ")
            items.append(VoiceGuideItem(
                id: "result-image",
                text: "The combined character \(guess.resultGlyph) was formed from: \(ingredientTexts).",
                kind: .image
            ))
            for (index, option) in guess.options.enumerated() {
                let icon  = option.displayIcon(mode: mode)
                let label = option.displayLabel(mode: mode)
                items.append(VoiceGuideItem(
                    id: "option-\(index)",
                    text: "Option \(index + 1): \(label), shown as \(icon).",
                    kind: .body
                ))
            }
            items.append(VoiceGuideItem(
                id: "control",
                text: "Tap an option to select the meaning of the resulting character.",
                kind: .control
            ))

        case .free:
            guard let free = level.free else { break }
            let instruction = free.displayInstruction(mode: mode)
            items.append(VoiceGuideItem(
                id: "instruction",
                text: instruction,
                kind: .body
            ))
            items.append(VoiceGuideItem(
                id: "target",
                text: "Goal: discover \(free.targetCount) different characters.",
                kind: .state
            ))
            for (i, token) in free.availableItems.enumerated() {
                let label = token.displayLabel(mode: mode)
                let icon  = token.displayIcon(mode: mode)
                items.append(VoiceGuideItem(
                    id: "inventory-\(i)",
                    text: "Available piece \(i + 1): \(label), shown as \(icon).",
                    kind: .body
                ))
            }
            if context.freeDiscoveredGlyphs.isEmpty {
                items.append(VoiceGuideItem(
                    id: "discovered-none",
                    text: "No characters formed yet.",
                    kind: .state
                ))
            } else {
                let formed = context.freeDiscoveredGlyphs.joined(separator: ", ")
                let count  = context.freeDiscoveredGlyphs.count
                items.append(VoiceGuideItem(
                    id: "discovered",
                    text: "Formed so far: \(formed). \(count) of \(context.freeTargetCount).",
                    kind: .state
                ))
            }
            items.append(VoiceGuideItem(
                id: "control",
                text: "Tap inventory pieces to add them to the creation zone. Pieces nearby each other combine automatically.",
                kind: .control
            ))
        }

        return items
    }

    // MARK: - Convenience factory from GameState

    @MainActor static func build(from gameState: GameState) -> [VoiceGuideItem] {
        guard let level = gameState.currentLevel else { return [] }

        var ctx = Context(
            level: level,
            mode: gameState.scriptDisplayMode,
            totalLevels: gameState.levels.count
        )
        // Tracing
        ctx.traceProgress  = gameState.traceProgress
        ctx.traceCompleted = gameState.traceCompleted
        // Quiz
        ctx.quizSelectedOptionID = gameState.quizSelectedOptionID
        ctx.quizAnswered         = gameState.quizAnswered
        ctx.quizWasCorrect       = gameState.quizWasCorrect
        ctx.quizFeedback         = gameState.quizFeedback
        // Combination
        ctx.combinationFeedback  = gameState.combinationFeedback
        // Free
        ctx.freeDiscoveredGlyphs = gameState.freeDiscoveredGlyphs
        if let free = level.free {
            ctx.freeTargetCount = free.targetCount
        }

        return build(context: ctx)
    }
}
