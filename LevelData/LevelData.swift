import SwiftUI

extension WebLevel {
    static let all: [WebLevel] = [
        // --- LEARN PHASE: 9 characters, each a unique interaction ---

        // 1. Sun · Observe (pure watching)
        .learn(
            id: 1,
            title: "The Beginning",
            emotion: .curiosity,
            wowPauseSeconds: 2.5,
            data: LearnCharacterData(
                characterID: "ri",
                sfSymbol: "sun.max.fill",
                modernGlyph: "\u{65E5}",
                meaning: "Sun",
                instruction: "Watch how a mark of the sun becomes writing.",
                interaction: .observe
            )
        ),

        // 2. Moon · Trace (guided tracing)
        .learn(
            id: 2,
            title: "Follow the Path",
            emotion: .curiosity,
            wowPauseSeconds: 2.5,
            data: LearnCharacterData(
                characterID: "yue",
                sfSymbol: "moon.stars",
                modernGlyph: "\u{6708}",
                meaning: "Moon",
                instruction: "Trace the ancient strokes with your finger.",
                interaction: .trace
            )
        ),

        // 3. Person · Draw from Memory (flash + draw)
        .learn(
            id: 3,
            title: "From Memory",
            emotion: .understanding,
            wowPauseSeconds: 2.5,
            data: LearnCharacterData(
                characterID: "ren",
                sfSymbol: "figure.stand",
                modernGlyph: "\u{4EBA}",
                meaning: "Person",
                instruction: "Look once. Then draw the character from memory.",
                interaction: .drawFromMemory
            )
        ),

        // 4. Tree · Shake/Tap Reveal (crack open)
        .learn(
            id: 4,
            title: "What's Inside",
            emotion: .understanding,
            wowPauseSeconds: 2.5,
            data: LearnCharacterData(
                characterID: "mu",
                sfSymbol: "tree.fill",
                modernGlyph: "\u{6728}",
                meaning: "Tree",
                instruction: "Tap the tree to reveal the ancient form inside.",
                interaction: .shakeReveal
            )
        ),

        // 5. Mouth · Tap to Speak (progressive stroke reveal)
        .learn(
            id: 5,
            title: "Speak It",
            emotion: .understanding,
            wowPauseSeconds: 2.5,
            data: LearnCharacterData(
                characterID: "kou",
                sfSymbol: "mouth.fill",
                modernGlyph: "\u{53E3}",
                meaning: "Mouth",
                instruction: "Tap the screen as if speaking. Each tap draws one stroke.",
                interaction: .tapReveal
            )
        ),

        // 6. Heart · Pulse Reveal (heartbeat rhythm)
        .learn(
            id: 6,
            title: "Feel It",
            emotion: .confidence,
            wowPauseSeconds: 2.5,
            data: LearnCharacterData(
                characterID: "xin",
                sfSymbol: "heart.fill",
                modernGlyph: "\u{5FC3}",
                meaning: "Heart",
                instruction: "Feel the pulse. Each heartbeat reveals one stroke.",
                interaction: .pulseReveal
            )
        ),

        // 7. Woman · Silhouette Match (pick the correct shape)
        .learn(
            id: 7,
            title: "Recognize",
            emotion: .confidence,
            wowPauseSeconds: 2.5,
            data: LearnCharacterData(
                characterID: "nv",
                sfSymbol: "figure.dress.line.vertical.figure",
                modernGlyph: "\u{5973}",
                meaning: "Woman",
                instruction: "Which ancient shape means Woman?",
                interaction: .silhouetteMatch,
                distractorShapes: [
                    DistractorShape(id: "nv", label: "Woman", strokes: OracleStrokePaths.woman(), isCorrect: true),
                    DistractorShape(id: "ren", label: "Person", strokes: OracleStrokePaths.person(), isCorrect: false),
                    DistractorShape(id: "zi", label: "Child", strokes: OracleStrokePaths.child(), isCorrect: false),
                    DistractorShape(id: "mu", label: "Tree", strokes: OracleStrokePaths.tree(), isCorrect: false),
                ]
            )
        ),

        // 8. Child · Memory Draw (show + hide + redraw)
        .learn(
            id: 8,
            title: "Remember",
            emotion: .confidence,
            wowPauseSeconds: 2.5,
            data: LearnCharacterData(
                characterID: "zi",
                sfSymbol: "figure.and.child.holdinghands",
                modernGlyph: "\u{5B50}",
                meaning: "Child",
                instruction: "Study the shape for 2 seconds, then redraw it.",
                interaction: .memoryDraw
            )
        ),

        // 9. One · Swipe Reveal (single gesture)
        .learn(
            id: 9,
            title: "The Simplest Mark",
            emotion: .achievement,
            wowPauseSeconds: 2.0,
            data: LearnCharacterData(
                characterID: "yi",
                sfSymbol: "line.horizontal.star.fill.line.horizontal",
                modernGlyph: "\u{4E00}",
                meaning: "One",
                instruction: "One swipe. The simplest character in the world.",
                interaction: .swipeReveal
            )
        ),

        // --- COMBINE PHASE: 4 levels using existing views ---

        // 10. Woods (林) · Drag
        .drag(
            id: 10,
            title: "Two Become One",
            emotion: .confidence,
            wowPauseSeconds: 2.5,
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
                )
            )
        ),

        // 11. Good (好) · Guess
        .guess(
            id: 11,
            title: "Guess the Meaning",
            emotion: .confidence,
            wowPauseSeconds: 2.5,
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
                    LevelOption(id: "bright", icon: "\u{660E}", label: "Bright", isCorrect: false),
                    LevelOption(id: "woods", icon: "\u{6797}", label: "Woods", isCorrect: false),
                ],
                explanation: "Woman + child formed an ancient idea of goodness."
            )
        ),

        // 12. Free Create (3 targets)
        .free(
            id: 12,
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
                finalMessage: "You can now create meaning, not just copy form."
            )
        ),

        // 13. Free Create All
        .free(
            id: 13,
            title: "Master",
            emotion: .achievement,
            wowPauseSeconds: 0.0,
            data: FreeLevelData(
                instruction: "Combine all you have learned. Discover every character.",
                targetCount: 4,
                availableItems: [.ren, .mu, .ri, .yue, .nv, .zi, .kou, .xin, .yi],
                validRecipes: [
                    CombinationRecipe(ingredients: ["ren", "mu"], resultID: "xiu", resultGlyph: "\u{4F11}", resultMeaning: "Rest", explanation: "Person beside tree.", spatial: .leftRight),
                    CombinationRecipe(ingredients: ["ri", "yue"], resultID: "ming", resultGlyph: "\u{660E}", resultMeaning: "Bright", explanation: "Sun with moon.", spatial: .leftRight),
                    CombinationRecipe(ingredients: ["mu", "mu"], resultID: "lin", resultGlyph: "\u{6797}", resultMeaning: "Woods", explanation: "Two trees together.", spatial: .leftRight),
                    CombinationRecipe(ingredients: ["nv", "zi"], resultID: "hao", resultGlyph: "\u{597D}", resultMeaning: "Good", explanation: "Woman and child.", spatial: .leftRight),
                ],
                finalMessage: "You just replayed a small piece of how civilization wrote the world down."
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
    static let kou = InventoryToken(id: "kou", icon: "\u{53E3}", label: "Mouth")
    static let xin = InventoryToken(id: "xin", icon: "\u{5FC3}", label: "Heart")
    static let yi = InventoryToken(id: "yi", icon: "\u{4E00}", label: "One")
}
