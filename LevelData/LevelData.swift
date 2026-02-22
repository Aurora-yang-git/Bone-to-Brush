import SwiftUI

extension WebLevel {
    static let all: [WebLevel] = [
        .tracing(
            id: 1,
            title: "Person",
            data: TracingLevelData(
                character: "\u{4EBA}",
                meaning: "Person",
                guide: .person(),
                explanation: "Two strokes. A walking body.",
                illustrationSymbol: "figure.walk",
                imageAssetName: "pictograph_person",
                oracleCharacter: "\u{4EBA}",
                oracleMeaning: "Oracle · Person",
                oracleExplanation: "Two strokes form a walking figure.",
                oracleImageAssetName: "pictograph_person"
            )
        ),
        .tracing(
            id: 2,
            title: "Tree",
            oracleTitle: "Tree",
            data: TracingLevelData(
                character: "\u{6728}",
                meaning: "Tree",
                guide: .tree(),
                explanation: "The trunk holds the branches.",
                illustrationSymbol: "tree",
                imageAssetName: "pictograph_tree",
                oracleCharacter: "\u{6728}",
                oracleMeaning: "Oracle · Tree",
                oracleExplanation: "The center stroke is the trunk, with side strokes as branches.",
                oracleImageAssetName: "pictograph_tree"
            )
        ),
        .tracing(
            id: 3,
            title: "Mouth",
            oracleTitle: "Mouth",
            data: TracingLevelData(
                character: "\u{53E3}",
                meaning: "Mouth",
                guide: .mouth(),
                explanation: "A mouth is an opening.",
                illustrationSymbol: "mouth",
                imageAssetName: "pictograph_mouth",
                oracleCharacter: "\u{53E3}",
                oracleMeaning: "Oracle · Mouth",
                oracleExplanation: "A square outline represents an opening.",
                oracleImageAssetName: "pictograph_mouth"
            )
        ),
        .tracing(
            id: 4,
            title: "Sun",
            oracleTitle: "Sun",
            data: TracingLevelData(
                character: "\u{65E5}",
                meaning: "Sun",
                guide: .sun(),
                explanation: "The sun was a marked circle.",
                illustrationSymbol: "sun.max",
                imageAssetName: "pictograph_sun",
                oracleCharacter: "\u{65E5}",
                oracleMeaning: "Oracle · Sun",
                oracleExplanation: "The outer frame marks the shape, the inner stroke marks light.",
                oracleImageAssetName: "pictograph_sun"
            )
        ),
        .quiz(
            id: 5,
            title: "Match Nature",
            oracleTitle: "Match Nature",
            data: QuizLevelData(
                question: "Which represents Nature?",
                options: [
                    LevelOption(id: "mu", icon: "\u{6728}", label: "Tree", isCorrect: true, oracleIcon: "\u{6728}", oracleLabel: "Tree"),
                    LevelOption(id: "kou", icon: "\u{53E3}", label: "Mouth", isCorrect: false, oracleIcon: "\u{53E3}", oracleLabel: "Mouth"),
                    LevelOption(id: "ren", icon: "\u{4EBA}", label: "Person", isCorrect: false, oracleIcon: "\u{4EBA}", oracleLabel: "Person"),
                    LevelOption(id: "yi", icon: "\u{4E00}", label: "One", isCorrect: false, oracleIcon: "\u{4E00}", oracleLabel: "One"),
                ],
                explanation: "Tree (Wood) is a natural element.",
                oracleQuestion: "Which option best matches nature?",
                oracleExplanation: "Tree is a core symbol of natural growth."
            )
        ),
        .combination(
            id: 6,
            title: "Rest",
            oracleTitle: "Rest",
            data: CombinationLevelData(
                instruction: "When a person rests...",
                targetMeaning: "Rest",
                targetChar: "\u{4F11}",
                baseInventory: [.ren, .mu, .kou],
                recipes: [
                    CombinationRecipe(
                        ingredients: ["ren", "mu"],
                        resultID: "xiu",
                        resultGlyph: "\u{4F11}",
                        resultMeaning: "Rest",
                        explanation: "Rest is a person leaning on a tree.",
                        spatial: .leftRight
                    ),
                    CombinationRecipe(
                        ingredients: ["kou", "mu"],
                        resultID: "dai",
                        resultGlyph: "\u{5446}",
                        resultMeaning: "Dull",
                        explanation: "Mouth on wood creates Dull.",
                        spatial: .topBottom
                    ),
                ],
                distractors: [
                    DistractorRule(ingredients: ["ren", "kou"], message: "Speech does not create rest.")
                ],
                oracleInstruction: "A person beside a tree forms rest.",
                oracleTargetMeaning: "Rest"
            )
        ),
        .combination(
            id: 7,
            title: "Follow",
            oracleTitle: "Follow",
            data: CombinationLevelData(
                instruction: "One follows another.",
                targetMeaning: "Follow",
                targetChar: "\u{4ECE}",
                baseInventory: [.ren],
                recipes: [
                    CombinationRecipe(
                        ingredients: ["ren", "ren"],
                        resultID: "cong",
                        resultGlyph: "\u{4ECE}",
                        resultMeaning: "Follow",
                        explanation: "One person follows another.",
                        spatial: .leftRight
                    )
                ],
                distractors: [],
                oracleInstruction: "Two people side by side form follow.",
                oracleTargetMeaning: "Follow"
            )
        ),
        .combination(
            id: 8,
            title: "Crowd",
            oracleTitle: "Crowd",
            data: CombinationLevelData(
                instruction: "Many is layered.",
                targetMeaning: "Crowd",
                targetChar: "\u{4F17}",
                baseInventory: [.ren],
                recipes: [
                    CombinationRecipe(
                        ingredients: ["ren", "ren", "ren"],
                        resultID: "zhong",
                        resultGlyph: "\u{4F17}",
                        resultMeaning: "Crowd",
                        explanation: "Many people become a crowd.",
                        spatial: .stacked
                    )
                ],
                distractors: [],
                oracleInstruction: "Three people stacked form crowd.",
                oracleTargetMeaning: "Crowd"
            )
        ),
        .combination(
            id: 9,
            title: "Bright",
            oracleTitle: "Bright",
            data: CombinationLevelData(
                instruction: "Bright is sun and moon together.",
                targetMeaning: "Bright",
                targetChar: "\u{660E}",
                baseInventory: [.ri, .yue, .mu],
                recipes: [
                    CombinationRecipe(
                        ingredients: ["ri", "yue"],
                        resultID: "ming",
                        resultGlyph: "\u{660E}",
                        resultMeaning: "Bright",
                        explanation: "Bright is sun and moon together.",
                        spatial: .leftRight
                    )
                ],
                distractors: [],
                oracleInstruction: "Sun and moon together form bright.",
                oracleTargetMeaning: "Bright"
            )
        ),
        .combination(
            id: 10,
            title: "Speech",
            oracleTitle: "Speech",
            data: CombinationLevelData(
                instruction: "Speech is more than one opening.",
                targetMeaning: "Speech",
                targetChar: "\u{8A00}",
                baseInventory: [.kou],
                recipes: [
                    CombinationRecipe(
                        ingredients: ["kou", "kou"],
                        resultID: "yan",
                        resultGlyph: "\u{8A00}",
                        resultMeaning: "Speech",
                        explanation: "Two mouths become speech.",
                        spatial: .stacked
                    )
                ],
                distractors: [],
                oracleInstruction: "Repeated mouth shapes form speech.",
                oracleTargetMeaning: "Speech"
            )
        ),
        .combination(
            id: 11,
            title: "Trust",
            oracleTitle: "Trust",
            data: CombinationLevelData(
                instruction: "What makes trust?",
                targetMeaning: "Trust",
                targetChar: "\u{4FE1}",
                baseInventory: [.ren, .kou],
                recipes: [
                    CombinationRecipe(
                        ingredients: ["kou", "kou"],
                        resultID: "yan",
                        resultGlyph: "\u{8A00}",
                        resultMeaning: "Speech",
                        explanation: "Two mouths become speech.",
                        spatial: .stacked
                    ),
                    CombinationRecipe(
                        ingredients: ["ren", "yan"],
                        resultID: "xin",
                        resultGlyph: "\u{4FE1}",
                        resultMeaning: "Trust",
                        explanation: "Trust is a person standing by their word.",
                        spatial: .leftRight
                    ),
                ],
                distractors: [
                    DistractorRule(ingredients: ["ren", "kou"], message: "Need speech, not just one mouth.")
                ],
                oracleInstruction: "Person and speech together form trust.",
                oracleTargetMeaning: "Trust"
            )
        ),
        .combination(
            id: 12,
            title: "Forest",
            oracleTitle: "Forest",
            data: CombinationLevelData(
                instruction: "Build something about many trees.",
                targetMeaning: "Forest",
                targetChar: "\u{68EE}",
                baseInventory: [.mu],
                recipes: [
                    CombinationRecipe(
                        ingredients: ["mu", "mu"],
                        resultID: "lin",
                        resultGlyph: "\u{6797}",
                        resultMeaning: "Woods",
                        explanation: "One tree becomes woods.",
                        spatial: .leftRight
                    ),
                    CombinationRecipe(
                        ingredients: ["mu", "mu", "mu"],
                        resultID: "sen",
                        resultGlyph: "\u{68EE}",
                        resultMeaning: "Forest",
                        explanation: "Three trees become forest.",
                        spatial: .stacked
                    ),
                ],
                distractors: [],
                oracleInstruction: "Many trees together form forest.",
                oracleTargetMeaning: "Forest"
            )
        ),
        .combination(
            id: 13,
            title: "Origin",
            oracleTitle: "Origin",
            data: CombinationLevelData(
                instruction: "Build something about origin.",
                targetMeaning: "Origin",
                targetChar: "\u{672C}",
                baseInventory: [.mu, .yi],
                recipes: [
                    CombinationRecipe(
                        ingredients: ["mu", "yi"],
                        resultID: "ben",
                        resultGlyph: "\u{672C}",
                        resultMeaning: "Origin",
                        explanation: "A line at the base marks the root.",
                        spatial: .topBottom
                    ),
                    CombinationRecipe(
                        ingredients: ["mu", "yi"],
                        resultID: "mo",
                        resultGlyph: "\u{672B}",
                        resultMeaning: "Tip",
                        explanation: "A line above marks the tip.",
                        spatial: .topBottom
                    ),
                ],
                distractors: [],
                oracleInstruction: "A line at the base marks origin; above marks tip.",
                oracleTargetMeaning: "Origin"
            )
        ),
        .combination(
            id: 14,
            title: "Body",
            oracleTitle: "Body",
            data: CombinationLevelData(
                instruction: "Build something about body.",
                targetMeaning: "Body",
                targetChar: "\u{4F53}",
                baseInventory: [.ren, .mu, .yi],
                recipes: [
                    CombinationRecipe(
                        ingredients: ["mu", "yi"],
                        resultID: "ben",
                        resultGlyph: "\u{672C}",
                        resultMeaning: "Origin",
                        explanation: "Root first.",
                        spatial: .topBottom
                    ),
                    CombinationRecipe(
                        ingredients: ["ren", "ben"],
                        resultID: "ti",
                        resultGlyph: "\u{4F53}",
                        resultMeaning: "Body",
                        explanation: "Body is a person with roots.",
                        spatial: .leftRight
                    ),
                ],
                distractors: [],
                oracleInstruction: "A person with a rooted base forms body.",
                oracleTargetMeaning: "Body"
            )
        ),
        .free(
            id: 15,
            title: "Origins Of Civilization",
            oracleTitle: "Origins Of Civilization",
            data: FreeLevelData(
                instruction: "Create characters freely.",
                targetCount: 3,
                availableItems: [.ren, .mu, .kou, .ri, .yue, .yi, .xin, .nv, .zi],
                validRecipes: [
                    CombinationRecipe(ingredients: ["ren", "ren", "ren"], resultID: "zhong", resultGlyph: "\u{4F17}", resultMeaning: "Crowd", explanation: "Many people", spatial: .stacked),
                    CombinationRecipe(ingredients: ["kou", "kou"], resultID: "yan", resultGlyph: "\u{8A00}", resultMeaning: "Speech", explanation: "Words", spatial: .stacked),
                    CombinationRecipe(ingredients: ["ren", "yan"], resultID: "xin", resultGlyph: "\u{4FE1}", resultMeaning: "Trust", explanation: "True words", spatial: .leftRight),
                    CombinationRecipe(ingredients: ["ri", "yue"], resultID: "ming", resultGlyph: "\u{660E}", resultMeaning: "Bright", explanation: "Sun and moon", spatial: .leftRight),
                    CombinationRecipe(ingredients: ["mu", "mu"], resultID: "lin", resultGlyph: "\u{6797}", resultMeaning: "Woods", explanation: "Two trees", spatial: .leftRight),
                    CombinationRecipe(ingredients: ["mu", "mu", "mu"], resultID: "sen", resultGlyph: "\u{68EE}", resultMeaning: "Forest", explanation: "Many trees", spatial: .stacked),
                    CombinationRecipe(ingredients: ["ren", "mu"], resultID: "xiu", resultGlyph: "\u{4F11}", resultMeaning: "Rest", explanation: "Resting by tree", spatial: .leftRight),
                    CombinationRecipe(ingredients: ["nv", "zi"], resultID: "hao", resultGlyph: "\u{597D}", resultMeaning: "Good", explanation: "Woman and child", spatial: .leftRight),
                    CombinationRecipe(ingredients: ["ren", "ben"], resultID: "ti", resultGlyph: "\u{4F53}", resultMeaning: "Body", explanation: "Person and root", spatial: .leftRight),
                    CombinationRecipe(ingredients: ["mu", "yi"], resultID: "mo", resultGlyph: "\u{672B}", resultMeaning: "Tip", explanation: "Top mark", spatial: .topBottom),
                ],
                finalMessage: "These were never symbols. They were decisions about life.",
                oracleInstruction: "Combine freely and discover how meaning forms.",
                oracleFinalMessage: "These marks were never empty symbols; they came from real life."
            )
        ),
    ]
}

private extension InventoryToken {
    static let ren = InventoryToken(id: "ren", icon: "\u{4EBA}", label: "Person", oracleIcon: "\u{4EBA}", oracleLabel: "Person")
    static let mu = InventoryToken(id: "mu", icon: "\u{6728}", label: "Tree", oracleIcon: "\u{6728}", oracleLabel: "Tree")
    static let kou = InventoryToken(id: "kou", icon: "\u{53E3}", label: "Mouth", oracleIcon: "\u{53E3}", oracleLabel: "Mouth")
    static let ri = InventoryToken(id: "ri", icon: "\u{65E5}", label: "Sun", oracleIcon: "\u{65E5}", oracleLabel: "Sun")
    static let yue = InventoryToken(id: "yue", icon: "\u{6708}", label: "Moon", oracleIcon: "\u{6708}", oracleLabel: "Moon")
    static let yi = InventoryToken(id: "yi", icon: "\u{4E00}", label: "One", oracleIcon: "\u{4E00}", oracleLabel: "One")
    static let xin = InventoryToken(id: "xin", icon: "\u{5FC3}", label: "Heart", oracleIcon: "\u{5FC3}", oracleLabel: "Heart")
    static let nv = InventoryToken(id: "nv", icon: "\u{5973}", label: "Woman", oracleIcon: "\u{5973}", oracleLabel: "Woman")
    static let zi = InventoryToken(id: "zi", icon: "\u{5B50}", label: "Child", oracleIcon: "\u{5B50}", oracleLabel: "Child")
}
