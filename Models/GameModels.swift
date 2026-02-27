import SwiftUI

enum AppFlowState: Hashable {
    case intro
    case playing
    case ending
}

enum LevelType: Hashable {
    case learn
    case observe
    case tracing
    case draw
    case quiz
    case drag
    case combination
    case guess
    case free
}

enum LearnInteraction: String, Hashable {
    case observe
    case trace
    case drawFromMemory
    case shakeReveal
    case tapReveal
    case pulseReveal
    case silhouetteMatch
    case memoryDraw
    case swipeReveal
}

struct LearnCharacterData: Hashable {
    let characterID: String
    let sfSymbol: String
    let oracleStrokes: [OracleStroke]
    let modernGlyph: String
    let meaning: String
    let instruction: String
    let interaction: LearnInteraction
    let distractorShapes: [DistractorShape]

    init(
        characterID: String,
        sfSymbol: String,
        modernGlyph: String,
        meaning: String,
        instruction: String,
        interaction: LearnInteraction,
        distractorShapes: [DistractorShape] = []
    ) {
        self.characterID = characterID
        self.sfSymbol = sfSymbol
        self.oracleStrokes = OracleStrokePaths.strokes(for: characterID)
        self.modernGlyph = modernGlyph
        self.meaning = meaning
        self.instruction = instruction
        self.interaction = interaction
        self.distractorShapes = distractorShapes
    }
}

struct DistractorShape: Identifiable, Hashable {
    let id: String
    let label: String
    let strokes: [OracleStroke]
    let isCorrect: Bool
}

enum ScriptDisplayMode: Hashable {
    case oraclePreferred
    case modern
}

enum JourneyAction: String, Hashable {
    case observe
    case trace
    case draw
    case match
    case drag
    case combine
    case guess
    case create
}

enum JourneyEmotion: String, Hashable {
    case curiosity
    case understanding
    case confidence
    case achievement
}

enum HintStrategy: Hashable {
    case explicit
    case subtle
    case none
}

enum SpatialRule: Hashable {
    case leftRight
    case topBottom
    case stacked
    case any
}

enum CanvasItemStatus: Hashable {
    case idle
    case merging
    case repelling
    case returning
    case destroying
}

enum CombinationErrorKind: Hashable {
    case directionMismatch
    case invalidCombination
}

struct LevelOption: Identifiable, Hashable {
    let id: String
    let icon: String
    let label: String
    let isCorrect: Bool
    let oracleIcon: String?
    let oracleLabel: String?

    init(
        id: String,
        icon: String,
        label: String,
        isCorrect: Bool,
        oracleIcon: String? = nil,
        oracleLabel: String? = nil
    ) {
        self.id = id
        self.icon = icon
        self.label = label
        self.isCorrect = isCorrect
        self.oracleIcon = oracleIcon
        self.oracleLabel = oracleLabel
    }

    func displayIcon(mode: ScriptDisplayMode) -> String {
        if mode == .oraclePreferred, let oracleIcon {
            return oracleIcon
        }
        return icon
    }

    func displayLabel(mode: ScriptDisplayMode) -> String {
        if mode == .oraclePreferred, let oracleLabel {
            return oracleLabel
        }
        return label
    }
}

struct InventoryToken: Identifiable, Hashable {
    let id: String
    let icon: String
    let label: String
    let oracleIcon: String?
    let oracleLabel: String?

    init(
        id: String,
        icon: String,
        label: String,
        oracleIcon: String? = nil,
        oracleLabel: String? = nil
    ) {
        self.id = id
        self.icon = icon
        self.label = label
        self.oracleIcon = oracleIcon
        self.oracleLabel = oracleLabel
    }

    func displayIcon(mode: ScriptDisplayMode) -> String {
        if mode == .oraclePreferred, let oracleIcon {
            return oracleIcon
        }
        return icon
    }

    func displayLabel(mode: ScriptDisplayMode) -> String {
        if mode == .oraclePreferred, let oracleLabel {
            return oracleLabel
        }
        return label
    }
}

struct CanvasItem: Identifiable, Hashable {
    let uniqueID: String
    var item: InventoryToken
    var position: CGPoint
    var status: CanvasItemStatus = .idle

    var id: String { uniqueID }
}

struct EvolutionIngredient: Identifiable, Hashable {
    let id: String
    let icon: String
}

struct CombinationRecipe: Identifiable, Hashable {
    var id: String { resultPieceID }
    let ingredients: [String]
    let resultPieceID: String
    let resultGlyph: String
    let resultMeaning: String
    let explanation: String
    let spatial: SpatialRule
    let oracleResultMeaning: String?

    init(
        ingredients: [String],
        resultID: String,
        resultGlyph: String,
        resultMeaning: String,
        explanation: String,
        spatial: SpatialRule,
        oracleResultMeaning: String? = nil
    ) {
        self.ingredients = ingredients
        self.resultPieceID = resultID
        self.resultGlyph = resultGlyph
        self.resultMeaning = resultMeaning
        self.explanation = explanation
        self.spatial = spatial
        self.oracleResultMeaning = oracleResultMeaning
    }

    func displayResultMeaning(mode: ScriptDisplayMode) -> String {
        if mode == .oraclePreferred {
            return oracleResultMeaning ?? resultGlyph
        }
        return resultMeaning
    }
}

struct DistractorRule: Hashable {
    let ingredients: [String]
    let message: String
}

struct ObserveLevelData: Hashable {
    let worldSymbol: String
    let oracleGlyph: String
    let modernGlyph: String
    let instruction: String
    let detail: String
}

struct TracingLevelData: Hashable {
    let character: String
    let meaning: String
    let guide: TraceGuide
    let explanation: String
    let illustrationSymbol: String
    let imageAssetName: String
    let oracleCharacter: String?
    let oracleMeaning: String?
    let oracleExplanation: String?
    let oracleImageAssetName: String?

    init(
        character: String,
        meaning: String,
        guide: TraceGuide,
        explanation: String,
        illustrationSymbol: String,
        imageAssetName: String,
        oracleCharacter: String? = nil,
        oracleMeaning: String? = nil,
        oracleExplanation: String? = nil,
        oracleImageAssetName: String? = nil
    ) {
        self.character = character
        self.meaning = meaning
        self.guide = guide
        self.explanation = explanation
        self.illustrationSymbol = illustrationSymbol
        self.imageAssetName = imageAssetName
        self.oracleCharacter = oracleCharacter
        self.oracleMeaning = oracleMeaning
        self.oracleExplanation = oracleExplanation
        self.oracleImageAssetName = oracleImageAssetName
    }

    func displayCharacter(mode: ScriptDisplayMode) -> String {
        if mode == .oraclePreferred, let oracleCharacter {
            return oracleCharacter
        }
        return character
    }

    func displayMeaning(mode: ScriptDisplayMode) -> String {
        if mode == .oraclePreferred, let oracleMeaning {
            return oracleMeaning
        }
        return meaning
    }

    func displayExplanation(mode: ScriptDisplayMode) -> String {
        if mode == .oraclePreferred, let oracleExplanation {
            return oracleExplanation
        }
        return explanation
    }

    func displayImageAsset(mode: ScriptDisplayMode) -> String {
        if mode == .oraclePreferred, let oracleImageAssetName {
            return oracleImageAssetName
        }
        return imageAssetName
    }
}

struct DrawLevelData: Hashable {
    let character: String
    let meaning: String
    let guide: TraceGuide
    let instruction: String
    let explanation: String
    let imageAssetName: String
    let oracleCharacter: String?
    let oracleMeaning: String?
    let oracleInstruction: String?
    let oracleExplanation: String?
    let oracleImageAssetName: String?

    init(
        character: String,
        meaning: String,
        guide: TraceGuide,
        instruction: String,
        explanation: String,
        imageAssetName: String,
        oracleCharacter: String? = nil,
        oracleMeaning: String? = nil,
        oracleInstruction: String? = nil,
        oracleExplanation: String? = nil,
        oracleImageAssetName: String? = nil
    ) {
        self.character = character
        self.meaning = meaning
        self.guide = guide
        self.instruction = instruction
        self.explanation = explanation
        self.imageAssetName = imageAssetName
        self.oracleCharacter = oracleCharacter
        self.oracleMeaning = oracleMeaning
        self.oracleInstruction = oracleInstruction
        self.oracleExplanation = oracleExplanation
        self.oracleImageAssetName = oracleImageAssetName
    }

    func displayCharacter(mode: ScriptDisplayMode) -> String {
        if mode == .oraclePreferred, let oracleCharacter {
            return oracleCharacter
        }
        return character
    }

    func displayMeaning(mode: ScriptDisplayMode) -> String {
        if mode == .oraclePreferred, let oracleMeaning {
            return oracleMeaning
        }
        return meaning
    }

    func displayInstruction(mode: ScriptDisplayMode) -> String {
        if mode == .oraclePreferred, let oracleInstruction {
            return oracleInstruction
        }
        return instruction
    }

    func displayExplanation(mode: ScriptDisplayMode) -> String {
        if mode == .oraclePreferred, let oracleExplanation {
            return oracleExplanation
        }
        return explanation
    }

    func displayImageAsset(mode: ScriptDisplayMode) -> String {
        if mode == .oraclePreferred, let oracleImageAssetName {
            return oracleImageAssetName
        }
        return imageAssetName
    }
}

struct QuizLevelData: Hashable {
    let question: String
    let options: [LevelOption]
    let explanation: String
    let oracleQuestion: String?
    let oracleExplanation: String?

    init(
        question: String,
        options: [LevelOption],
        explanation: String,
        oracleQuestion: String? = nil,
        oracleExplanation: String? = nil
    ) {
        self.question = question
        self.options = options
        self.explanation = explanation
        self.oracleQuestion = oracleQuestion
        self.oracleExplanation = oracleExplanation
    }

    func displayQuestion(mode: ScriptDisplayMode) -> String {
        if mode == .oraclePreferred, let oracleQuestion {
            return oracleQuestion
        }
        return question
    }

    func displayExplanation(mode: ScriptDisplayMode) -> String {
        if mode == .oraclePreferred, let oracleExplanation {
            return oracleExplanation
        }
        return explanation
    }
}

struct DragLevelData: Hashable {
    let instruction: String
    let targetMeaning: String
    let targetChar: String
    let baseInventory: [InventoryToken]
    let recipe: CombinationRecipe
    let oracleInstruction: String?
    let oracleTargetMeaning: String?

    init(
        instruction: String,
        targetMeaning: String,
        targetChar: String,
        baseInventory: [InventoryToken],
        recipe: CombinationRecipe,
        oracleInstruction: String? = nil,
        oracleTargetMeaning: String? = nil
    ) {
        self.instruction = instruction
        self.targetMeaning = targetMeaning
        self.targetChar = targetChar
        self.baseInventory = baseInventory
        self.recipe = recipe
        self.oracleInstruction = oracleInstruction
        self.oracleTargetMeaning = oracleTargetMeaning
    }

    func displayInstruction(mode: ScriptDisplayMode) -> String {
        if mode == .oraclePreferred, let oracleInstruction {
            return oracleInstruction
        }
        return instruction
    }

    func displayTargetMeaning(mode: ScriptDisplayMode) -> String {
        if mode == .oraclePreferred, let oracleTargetMeaning {
            return oracleTargetMeaning
        }
        return targetMeaning
    }
}

struct GuessLevelData: Hashable {
    let instruction: String
    let ingredients: [EvolutionIngredient]
    let resultGlyph: String
    let options: [LevelOption]
    let explanation: String
    let oracleInstruction: String?
    let oracleExplanation: String?

    init(
        instruction: String,
        ingredients: [EvolutionIngredient],
        resultGlyph: String,
        options: [LevelOption],
        explanation: String,
        oracleInstruction: String? = nil,
        oracleExplanation: String? = nil
    ) {
        self.instruction = instruction
        self.ingredients = ingredients
        self.resultGlyph = resultGlyph
        self.options = options
        self.explanation = explanation
        self.oracleInstruction = oracleInstruction
        self.oracleExplanation = oracleExplanation
    }

    func displayInstruction(mode: ScriptDisplayMode) -> String {
        if mode == .oraclePreferred, let oracleInstruction {
            return oracleInstruction
        }
        return instruction
    }

    func displayExplanation(mode: ScriptDisplayMode) -> String {
        if mode == .oraclePreferred, let oracleExplanation {
            return oracleExplanation
        }
        return explanation
    }
}

struct CombinationLevelData: Hashable {
    let instruction: String
    let targetMeaning: String
    let targetChar: String
    let hintStrategy: HintStrategy
    let baseInventory: [InventoryToken]
    let recipes: [CombinationRecipe]
    let distractors: [DistractorRule]
    let oracleInstruction: String?
    let oracleTargetMeaning: String?

    init(
        instruction: String,
        targetMeaning: String,
        targetChar: String,
        hintStrategy: HintStrategy = .explicit,
        baseInventory: [InventoryToken],
        recipes: [CombinationRecipe],
        distractors: [DistractorRule],
        oracleInstruction: String? = nil,
        oracleTargetMeaning: String? = nil
    ) {
        self.instruction = instruction
        self.targetMeaning = targetMeaning
        self.targetChar = targetChar
        self.hintStrategy = hintStrategy
        self.baseInventory = baseInventory
        self.recipes = recipes
        self.distractors = distractors
        self.oracleInstruction = oracleInstruction
        self.oracleTargetMeaning = oracleTargetMeaning
    }

    func displayInstruction(mode: ScriptDisplayMode) -> String {
        if mode == .oraclePreferred, let oracleInstruction {
            return oracleInstruction
        }
        return instruction
    }

    func displayTargetMeaning(mode: ScriptDisplayMode) -> String {
        if mode == .oraclePreferred, let oracleTargetMeaning {
            return oracleTargetMeaning
        }
        return targetMeaning
    }
}

struct FreeLevelData: Hashable {
    let instruction: String
    let targetCount: Int
    let availableItems: [InventoryToken]
    let validRecipes: [CombinationRecipe]
    let finalMessage: String
    let oracleInstruction: String?
    let oracleFinalMessage: String?

    init(
        instruction: String,
        targetCount: Int,
        availableItems: [InventoryToken],
        validRecipes: [CombinationRecipe],
        finalMessage: String,
        oracleInstruction: String? = nil,
        oracleFinalMessage: String? = nil
    ) {
        self.instruction = instruction
        self.targetCount = targetCount
        self.availableItems = availableItems
        self.validRecipes = validRecipes
        self.finalMessage = finalMessage
        self.oracleInstruction = oracleInstruction
        self.oracleFinalMessage = oracleFinalMessage
    }

    func displayInstruction(mode: ScriptDisplayMode) -> String {
        if mode == .oraclePreferred, let oracleInstruction {
            return oracleInstruction
        }
        return instruction
    }

    func displayFinalMessage(mode: ScriptDisplayMode) -> String {
        if mode == .oraclePreferred, let oracleFinalMessage {
            return oracleFinalMessage
        }
        return finalMessage
    }
}

struct WebLevel: Identifiable, Hashable {
    let id: Int
    let type: LevelType
    let action: JourneyAction
    let emotion: JourneyEmotion
    let wowPauseSeconds: Double
    let title: String
    let oracleTitle: String?
    let learn: LearnCharacterData?
    let observe: ObserveLevelData?
    let tracing: TracingLevelData?
    let draw: DrawLevelData?
    let quiz: QuizLevelData?
    let drag: DragLevelData?
    let combination: CombinationLevelData?
    let guess: GuessLevelData?
    let free: FreeLevelData?

    static func learn(
        id: Int,
        title: String,
        oracleTitle: String? = nil,
        emotion: JourneyEmotion = .curiosity,
        wowPauseSeconds: Double = 2.5,
        data: LearnCharacterData
    ) -> WebLevel {
        WebLevel(
            id: id,
            type: .learn,
            action: JourneyAction(rawValue: data.interaction.rawValue) ?? .observe,
            emotion: emotion,
            wowPauseSeconds: wowPauseSeconds,
            title: title,
            oracleTitle: oracleTitle,
            learn: data,
            observe: nil,
            tracing: nil,
            draw: nil,
            quiz: nil,
            drag: nil,
            combination: nil,
            guess: nil,
            free: nil
        )
    }

    static func observe(
        id: Int,
        title: String,
        oracleTitle: String? = nil,
        emotion: JourneyEmotion = .curiosity,
        wowPauseSeconds: Double = 1.0,
        data: ObserveLevelData
    ) -> WebLevel {
        WebLevel(
            id: id,
            type: .observe,
            action: .observe,
            emotion: emotion,
            wowPauseSeconds: wowPauseSeconds,
            title: title,
            oracleTitle: oracleTitle,
            learn: nil,
            observe: data,
            tracing: nil,
            draw: nil,
            quiz: nil,
            drag: nil,
            combination: nil,
            guess: nil,
            free: nil
        )
    }

    static func tracing(
        id: Int,
        title: String,
        oracleTitle: String? = nil,
        emotion: JourneyEmotion = .curiosity,
        wowPauseSeconds: Double = 1.0,
        data: TracingLevelData
    ) -> WebLevel {
        WebLevel(
            id: id,
            type: .tracing,
            action: .trace,
            emotion: emotion,
            wowPauseSeconds: wowPauseSeconds,
            title: title,
            oracleTitle: oracleTitle,
            learn: nil,
            observe: nil,
            tracing: data,
            draw: nil,
            quiz: nil,
            drag: nil,
            combination: nil,
            guess: nil,
            free: nil
        )
    }

    static func draw(
        id: Int,
        title: String,
        oracleTitle: String? = nil,
        emotion: JourneyEmotion = .understanding,
        wowPauseSeconds: Double = 1.0,
        data: DrawLevelData
    ) -> WebLevel {
        WebLevel(
            id: id,
            type: .draw,
            action: .draw,
            emotion: emotion,
            wowPauseSeconds: wowPauseSeconds,
            title: title,
            oracleTitle: oracleTitle,
            learn: nil,
            observe: nil,
            tracing: nil,
            draw: data,
            quiz: nil,
            drag: nil,
            combination: nil,
            guess: nil,
            free: nil
        )
    }

    static func quiz(
        id: Int,
        title: String,
        oracleTitle: String? = nil,
        emotion: JourneyEmotion = .understanding,
        wowPauseSeconds: Double = 0,
        data: QuizLevelData
    ) -> WebLevel {
        WebLevel(
            id: id,
            type: .quiz,
            action: .match,
            emotion: emotion,
            wowPauseSeconds: wowPauseSeconds,
            title: title,
            oracleTitle: oracleTitle,
            learn: nil,
            observe: nil,
            tracing: nil,
            draw: nil,
            quiz: data,
            drag: nil,
            combination: nil,
            guess: nil,
            free: nil
        )
    }

    static func drag(
        id: Int,
        title: String,
        oracleTitle: String? = nil,
        emotion: JourneyEmotion = .confidence,
        wowPauseSeconds: Double = 1.0,
        data: DragLevelData
    ) -> WebLevel {
        WebLevel(
            id: id,
            type: .drag,
            action: .drag,
            emotion: emotion,
            wowPauseSeconds: wowPauseSeconds,
            title: title,
            oracleTitle: oracleTitle,
            learn: nil,
            observe: nil,
            tracing: nil,
            draw: nil,
            quiz: nil,
            drag: data,
            combination: nil,
            guess: nil,
            free: nil
        )
    }

    static func combination(
        id: Int,
        title: String,
        oracleTitle: String? = nil,
        emotion: JourneyEmotion = .confidence,
        wowPauseSeconds: Double = 1.0,
        data: CombinationLevelData
    ) -> WebLevel {
        WebLevel(
            id: id,
            type: .combination,
            action: .combine,
            emotion: emotion,
            wowPauseSeconds: wowPauseSeconds,
            title: title,
            oracleTitle: oracleTitle,
            learn: nil,
            observe: nil,
            tracing: nil,
            draw: nil,
            quiz: nil,
            drag: nil,
            combination: data,
            guess: nil,
            free: nil
        )
    }

    static func guess(
        id: Int,
        title: String,
        oracleTitle: String? = nil,
        emotion: JourneyEmotion = .confidence,
        wowPauseSeconds: Double = 1.0,
        data: GuessLevelData
    ) -> WebLevel {
        WebLevel(
            id: id,
            type: .guess,
            action: .guess,
            emotion: emotion,
            wowPauseSeconds: wowPauseSeconds,
            title: title,
            oracleTitle: oracleTitle,
            learn: nil,
            observe: nil,
            tracing: nil,
            draw: nil,
            quiz: nil,
            drag: nil,
            combination: nil,
            guess: data,
            free: nil
        )
    }

    static func free(
        id: Int,
        title: String,
        oracleTitle: String? = nil,
        emotion: JourneyEmotion = .achievement,
        wowPauseSeconds: Double = 0,
        data: FreeLevelData
    ) -> WebLevel {
        WebLevel(
            id: id,
            type: .free,
            action: .create,
            emotion: emotion,
            wowPauseSeconds: wowPauseSeconds,
            title: title,
            oracleTitle: oracleTitle,
            learn: nil,
            observe: nil,
            tracing: nil,
            draw: nil,
            quiz: nil,
            drag: nil,
            combination: nil,
            guess: nil,
            free: data
        )
    }

    func displayTitle(mode: ScriptDisplayMode) -> String {
        if mode == .oraclePreferred, let oracleTitle {
            return oracleTitle
        }
        return title
    }
}

struct TraceStroke: Hashable {
    let points: [CGPoint]
}

struct TraceGuide: Hashable {
    let strokes: [TraceStroke]
    let completionThreshold: CGFloat

    init(strokes: [TraceStroke], completionThreshold: CGFloat = 0.62) {
        self.strokes = strokes
        self.completionThreshold = completionThreshold
    }
}

extension TraceGuide {
    static func stroke(_ points: [(CGFloat, CGFloat)]) -> TraceStroke {
        TraceStroke(points: points.map { CGPoint(x: $0.0, y: $0.1) })
    }

    static func person() -> TraceGuide {
        TraceGuide(strokes: [
            stroke([(0.48, 0.22), (0.40, 0.46), (0.34, 0.74)]),
            stroke([(0.50, 0.22), (0.58, 0.50), (0.68, 0.76)]),
        ])
    }

    static func tree() -> TraceGuide {
        TraceGuide(strokes: [
            stroke([(0.50, 0.20), (0.50, 0.80)]),
            stroke([(0.28, 0.42), (0.72, 0.42)]),
            stroke([(0.50, 0.54), (0.36, 0.74)]),
            stroke([(0.50, 0.54), (0.64, 0.74)]),
        ])
    }

    static func mouth() -> TraceGuide {
        TraceGuide(strokes: [
            stroke([(0.34, 0.30), (0.34, 0.72)]),
            stroke([(0.34, 0.30), (0.68, 0.30), (0.68, 0.72)]),
            stroke([(0.34, 0.72), (0.68, 0.72)]),
        ])
    }

    static func sun() -> TraceGuide {
        TraceGuide(strokes: [
            stroke([(0.34, 0.26), (0.34, 0.78)]),
            stroke([(0.34, 0.26), (0.68, 0.26), (0.68, 0.78), (0.34, 0.78)]),
            stroke([(0.34, 0.52), (0.68, 0.52)]),
        ])
    }

    static func moon() -> TraceGuide {
        TraceGuide(strokes: [
            stroke([(0.34, 0.24), (0.34, 0.78)]),
            stroke([(0.34, 0.24), (0.66, 0.24), (0.66, 0.78)]),
            stroke([(0.40, 0.44), (0.62, 0.44)]),
            stroke([(0.40, 0.62), (0.62, 0.62)]),
        ])
    }

    static func heart() -> TraceGuide {
        TraceGuide(strokes: [
            stroke([(0.50, 0.26), (0.44, 0.46), (0.46, 0.74)]),
            stroke([(0.56, 0.40), (0.62, 0.54), (0.60, 0.74)]),
            stroke([(0.36, 0.56), (0.44, 0.62)]),
            stroke([(0.50, 0.56), (0.58, 0.62)]),
        ], completionThreshold: 0.56)
    }

    static func root() -> TraceGuide {
        TraceGuide(strokes: tree().strokes + [
            stroke([(0.40, 0.68), (0.60, 0.68)]),
        ])
    }

    static func tip() -> TraceGuide {
        TraceGuide(strokes: tree().strokes + [
            stroke([(0.36, 0.28), (0.64, 0.28)]),
        ])
    }
}
