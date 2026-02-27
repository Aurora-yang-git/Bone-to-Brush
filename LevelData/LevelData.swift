import SwiftUI

extension WebLevel {
    static let all: [WebLevel] = [
        .observe(
            id: 1,
            title: "The Beginning",
            emotion: .curiosity,
            wowPauseSeconds: 1.0,
            data: ObserveLevelData(
                worldSymbol: "sun.max.fill",
                oracleGlyph: "\u{2609}",
                modernGlyph: "\u{65E5}",
                instruction: "Watch how a mark of the sun becomes writing.",
                detail: "3,000 years ago, writing began as pictures."
            )
        ),
        .tracing(
            id: 2,
            title: "Follow the Path",
            emotion: .curiosity,
            wowPauseSeconds: 1.0,
            data: TracingLevelData(
                character: "\u{6708}",
                meaning: "Moon",
                guide: .moon(),
                explanation: "You traced a shape people recognized for thousands of years.",
                illustrationSymbol: "moon.stars",
                imageAssetName: "pictograph_moon",
                oracleCharacter: "\u{6708}",
                oracleMeaning: "Oracle · Moon",
                oracleExplanation: "Crescent-like lines became the moon character.",
                oracleImageAssetName: "pictograph_moon"
            )
        ),
        .draw(
            id: 3,
            title: "From Memory",
            emotion: .understanding,
            wowPauseSeconds: 1.0,
            data: DrawLevelData(
                character: "\u{4EBA}",
                meaning: "Person",
                guide: .person(),
                instruction: "Look once. Then draw the character from memory.",
                explanation: "You moved from following to remembering.",
                imageAssetName: "pictograph_person",
                oracleCharacter: "\u{4EBA}",
                oracleMeaning: "Oracle · Person",
                oracleInstruction: "Observe the shape, then redraw it from memory.",
                oracleExplanation: "The figure of a person became a stable written form.",
                oracleImageAssetName: "pictograph_person"
            )
        ),
        .quiz(
            id: 4,
            title: "Find the Match",
            emotion: .understanding,
            wowPauseSeconds: 0.9,
            data: QuizLevelData(
                question: "Which glyph means Tree?",
                options: [
                    LevelOption(id: "mu", icon: "\u{6728}", label: "Tree", isCorrect: true),
                    LevelOption(id: "kou", icon: "\u{53E3}", label: "Mouth", isCorrect: false),
                    LevelOption(id: "ren", icon: "\u{4EBA}", label: "Person", isCorrect: false),
                    LevelOption(id: "ri", icon: "\u{65E5}", label: "Sun", isCorrect: false),
                ],
                explanation: "Correct. Tree keeps the trunk and branches in one sign.",
                oracleQuestion: "Match the oracle shape to Tree.",
                oracleExplanation: "Tree keeps the trunk and branch structure."
            )
        ),
        .drag(
            id: 5,
            title: "Two Become One",
            emotion: .confidence,
            wowPauseSeconds: 1.0,
            data: DragLevelData(
                instruction: "Drag two Tree pieces into the slots to form a new character.",
                targetMeaning: "Woods",
                targetChar: "\u{6797}",
                baseInventory: [.mu],
                recipe: CombinationRecipe(
                    ingredients: ["mu", "mu"],
                    resultID: "lin",
                    resultGlyph: "\u{6797}",
                    resultMeaning: "Woods",
                    explanation: "Two trees together become woods.",
                    spatial: .leftRight
                ),
                oracleInstruction: "Place two tree signs side by side.",
                oracleTargetMeaning: "Woods"
            )
        ),
        .guess(
            id: 6,
            title: "Guess the Meaning",
            emotion: .confidence,
            wowPauseSeconds: 1.0,
            data: GuessLevelData(
                instruction: "Watch the combination, then guess the meaning.",
                ingredients: [
                    EvolutionIngredient(id: "nv", icon: "\u{5973}"),
                    EvolutionIngredient(id: "zi", icon: "\u{5B50}"),
                ],
                resultGlyph: "\u{597D}",
                options: [
                    LevelOption(id: "good", icon: "\u{597D}", label: "Good", isCorrect: true),
                    LevelOption(id: "rest", icon: "\u{4F11}", label: "Rest", isCorrect: false),
                    LevelOption(id: "\u{6728}", icon: "\u{6728}", label: "Tree", isCorrect: false),
                    LevelOption(id: "bright", icon: "\u{660E}", label: "Bright", isCorrect: false),
                ],
                explanation: "Correct. Woman + child formed an ancient idea of goodness.",
                oracleInstruction: "Observe the fusion, then infer the idea.",
                oracleExplanation: "Meaning was built by combining familiar life images."
            )
        ),
        .free(
            id: 7,
            title: "Create",
            emotion: .achievement,
            wowPauseSeconds: 0.0,
            data: FreeLevelData(
                instruction: "Create three characters on your own.",
                targetCount: 3,
                availableItems: [.ren, .mu, .ri, .yue, .nv, .zi],
                validRecipes: [
                    CombinationRecipe(ingredients: ["ren", "mu"], resultID: "xiu", resultGlyph: "\u{4F11}", resultMeaning: "Rest", explanation: "Person beside tree.", spatial: .leftRight),
                    CombinationRecipe(ingredients: ["ri", "yue"], resultID: "ming", resultGlyph: "\u{660E}", resultMeaning: "Bright", explanation: "Sun with moon.", spatial: .leftRight),
                    CombinationRecipe(ingredients: ["mu", "mu"], resultID: "lin", resultGlyph: "\u{6797}", resultMeaning: "Woods", explanation: "Two trees together.", spatial: .leftRight),
                    CombinationRecipe(ingredients: ["nv", "zi"], resultID: "hao", resultGlyph: "\u{597D}", resultMeaning: "Good", explanation: "Woman and child.", spatial: .leftRight),
                ],
                finalMessage: "You can now create meaning, not just copy form.",
                oracleInstruction: "Combine freely and discover how meaning forms.",
                oracleFinalMessage: "You replayed a creative moment of civilization."
            )
        ),
    ]
}

private extension InventoryToken {
    static let ren = InventoryToken(id: "ren", icon: "\u{4EBA}", label: "Person")
    static let mu = InventoryToken(id: "mu", icon: "\u{6728}", label: "Tree")
    static let ri = InventoryToken(id: "ri", icon: "\u{65E5}", label: "Sun")
    static let yue = InventoryToken(id: "yue", icon: "\u{6708}", label: "Moon")
    static let nv = InventoryToken(id: "nv", icon: "\u{5973}", label: "Woman")
    static let zi = InventoryToken(id: "zi", icon: "\u{5B50}", label: "Child")
}
