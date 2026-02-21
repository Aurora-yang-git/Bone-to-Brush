import SwiftUI

extension Level {
    static let all: [Level] = [

        // ── Phase 1: Pictograph  象形 (1-7) ──────────────────────

        Level(
            id: 1, phase: .pictograph,
            prompt: "A figure walks across an open plain. What is it?",
            components: [],
            solution: ["pictograph"],
            targetSlots: ["pictograph": CGPoint(x: 0.5, y: 0.5)],
            evolutionFrames: ["𠆢", "亻", "人"],
            reflection: "The simplest stroke became us.",
            ancientForm: "𠆢",
            pictographImage: "pictograph_person",
            referenceImage: "reference_person",
            referenceSymbol: "figure.stand",
            traceGuide: .person()
        ),
        Level(
            id: 2, phase: .pictograph,
            prompt: "Roots below, branches above. What stands between earth and sky?",
            components: [],
            solution: ["pictograph"],
            targetSlots: ["pictograph": CGPoint(x: 0.5, y: 0.5)],
            evolutionFrames: ["丫", "朩", "木"],
            reflection: "They drew what they saw, and the tree still stands in the character.",
            ancientForm: "丫",
            pictographImage: "pictograph_tree",
            referenceImage: "reference_tree",
            referenceSymbol: "tree",
            traceGuide: .tree()
        ),
        Level(
            id: 3, phase: .pictograph,
            prompt: "An opening through which breath and words pass. What shape is it?",
            components: [],
            solution: ["pictograph"],
            targetSlots: ["pictograph": CGPoint(x: 0.5, y: 0.5)],
            evolutionFrames: ["◯", "囗", "口"],
            reflection: "The shape of a mouth has not changed in three thousand years.",
            ancientForm: "◯",
            pictographImage: "pictograph_mouth",
            referenceImage: "reference_mouth",
            referenceSymbol: "mouth",
            traceGuide: .mouth()
        ),
        Level(
            id: 4, phase: .pictograph,
            prompt: "Five fingers spread wide. What reaches out to grasp the world?",
            components: [],
            solution: ["pictograph"],
            targetSlots: ["pictograph": CGPoint(x: 0.5, y: 0.5)],
            evolutionFrames: ["☞", "⺘", "手"],
            reflection: "A hand, open and reaching — the first gesture preserved in ink.",
            ancientForm: "☞",
            pictographImage: "pictograph_hand",
            referenceImage: "reference_hand",
            referenceSymbol: "hand.raised",
            traceGuide: .hand()
        ),
        Level(
            id: 5, phase: .pictograph,
            prompt: "A bright circle rises each morning. What burns at the center of the sky?",
            components: [],
            solution: ["pictograph"],
            targetSlots: ["pictograph": CGPoint(x: 0.5, y: 0.5)],
            evolutionFrames: ["◎", "⊙", "日"],
            reflection: "The sun was the first thing worth writing down.",
            ancientForm: "◎",
            pictographImage: "pictograph_sun",
            referenceImage: "reference_sun",
            referenceSymbol: "sun.max",
            traceGuide: .sun()
        ),
        Level(
            id: 6, phase: .pictograph,
            prompt: "A curved sliver of light watches over the dark. What is it?",
            components: [],
            solution: ["pictograph"],
            targetSlots: ["pictograph": CGPoint(x: 0.5, y: 0.5)],
            evolutionFrames: ["☽", "⺝", "月"],
            reflection: "Even the moon was captured — crescent by crescent.",
            ancientForm: "☽",
            pictographImage: "pictograph_moon",
            referenceImage: "reference_moon",
            referenceSymbol: "moon",
            traceGuide: .moon()
        ),
        Level(
            id: 7, phase: .pictograph,
            prompt: "Something beats inside every living thing, unseen. What is it?",
            components: [],
            solution: ["pictograph"],
            targetSlots: ["pictograph": CGPoint(x: 0.5, y: 0.5)],
            evolutionFrames: ["♡", "忄", "心"],
            reflection: "They knew the heart before they could name it.",
            ancientForm: "♡",
            pictographImage: "pictograph_heart",
            referenceImage: "reference_heart",
            referenceSymbol: "heart",
            traceGuide: .heart()
        ),

        // ── Phase 2: Ideograph  指事 (8-9) ───────────────────────

        Level(
            id: 8, phase: .ideograph,
            prompt: "Where does a tree draw its strength from?",
            components: [
                ComponentPiece(id: "marker", glyph: "一", accessibilityName: "horizontal stroke marker"),
            ],
            solution: ["marker"],
            targetSlots: ["marker": CGPoint(x: 0.5, y: 0.72)],
            evolutionFrames: ["木", "本"],
            reflection: "Mark the base, and meaning takes root.",
            ancientForm: "木",
            traceGuide: .root()
        ),
        Level(
            id: 9, phase: .ideograph,
            prompt: "Where does a tree reach toward the light?",
            components: [
                ComponentPiece(id: "marker", glyph: "一", accessibilityName: "horizontal stroke marker"),
            ],
            solution: ["marker"],
            targetSlots: ["marker": CGPoint(x: 0.5, y: 0.28)],
            evolutionFrames: ["木", "末"],
            reflection: "Mark the tip, and meaning reaches upward.",
            ancientForm: "木",
            traceGuide: .tip()
        ),

        // ── Phase 3: Compound  会意 (10-14) ──────────────────────

        Level(
            id: 10, phase: .compound,
            prompt: "Combine 'Person' (人) and 'Tree' (木).\nWhen a person rests against a tree, what do they find?",
            components: [
                ComponentPiece(id: "ren", glyph: "人", accessibilityName: "person"),
                ComponentPiece(id: "mu", glyph: "木", accessibilityName: "tree"),
                ComponentPiece(id: "kou", glyph: "口", accessibilityName: "mouth"),
            ],
            solution: ["ren", "mu"],
            targetSlots: [
                "ren": CGPoint(x: 0.42, y: 0.50),
                "mu": CGPoint(x: 0.58, y: 0.50),
            ],
            evolutionFrames: ["亻木", "休"],
            reflection: "Rest (休) is a person next to a tree."
        ),
        Level(
            id: 11, phase: .compound,
            prompt: "Combine 'Sun' (日) and 'Moon' (月).\nWhen the two brightest lights appear together, what fills the world?",
            components: [
                ComponentPiece(id: "ri", glyph: "日", accessibilityName: "sun"),
                ComponentPiece(id: "yue", glyph: "月", accessibilityName: "moon"),
                ComponentPiece(id: "huo", glyph: "火", accessibilityName: "fire"),
            ],
            solution: ["ri", "yue"],
            targetSlots: [
                "ri": CGPoint(x: 0.42, y: 0.50),
                "yue": CGPoint(x: 0.58, y: 0.50),
            ],
            evolutionFrames: ["日月", "朙", "明"],
            reflection: "Bright (明) is the sun and moon shining together."
        ),
        Level(
            id: 12, phase: .compound,
            prompt: "Combine two 'Person' (人) characters.\nWhen one person walks behind another, what emerges?",
            components: [
                ComponentPiece(id: "ren1", glyph: "人", accessibilityName: "first person"),
                ComponentPiece(id: "ren2", glyph: "人", accessibilityName: "second person"),
                ComponentPiece(id: "da", glyph: "大", accessibilityName: "big"),
            ],
            solution: ["ren1", "ren2"],
            targetSlots: [
                "ren1": CGPoint(x: 0.44, y: 0.50),
                "ren2": CGPoint(x: 0.56, y: 0.50),
            ],
            evolutionFrames: ["人人", "从"],
            reflection: "Follow (从) is one person walking after another."
        ),
        Level(
            id: 13, phase: .compound,
            prompt: "Combine three 'Person' (人) characters.\nOne follows, but what do many become together?",
            components: [
                ComponentPiece(id: "ren_top", glyph: "人", accessibilityName: "person on top"),
                ComponentPiece(id: "ren_left", glyph: "人", accessibilityName: "person on left"),
                ComponentPiece(id: "ren_right", glyph: "人", accessibilityName: "person on right"),
                ComponentPiece(id: "mu_d", glyph: "木", accessibilityName: "tree"),
            ],
            solution: ["ren_top", "ren_left", "ren_right"],
            targetSlots: [
                "ren_top": CGPoint(x: 0.50, y: 0.36),
                "ren_left": CGPoint(x: 0.40, y: 0.58),
                "ren_right": CGPoint(x: 0.60, y: 0.58),
            ],
            evolutionFrames: ["人人人", "众"],
            reflection: "Crowd (众) is simply many people together."
        ),
        Level(
            id: 14, phase: .compound,
            prompt: "Combine 'Person' (人) and 'Speech' (言).\nWhen a person stands by their word, what is that called?",
            components: [
                ComponentPiece(id: "ren", glyph: "人", accessibilityName: "person"),
                ComponentPiece(id: "yan", glyph: "言", accessibilityName: "speech"),
                ComponentPiece(id: "xin_d", glyph: "心", accessibilityName: "heart"),
            ],
            solution: ["ren", "yan"],
            targetSlots: [
                "ren": CGPoint(x: 0.40, y: 0.50),
                "yan": CGPoint(x: 0.58, y: 0.50),
            ],
            evolutionFrames: ["亻言", "信"],
            reflection: "Trust (信) is a person standing by their words."
        ),

        // ── Phase 4: Phono-semantic  形声 (15-16) ────────────────

        Level(
            id: 15, phase: .phonoSemantic,
            prompt: "Combine 'Person' (人) and 'Root' (本).\nWhat is a person's physical root or body?",
            components: [
                ComponentPiece(id: "ren_rad", glyph: "亻", accessibilityName: "person meaning radical"),
                ComponentPiece(id: "ben", glyph: "本", accessibilityName: "root sound component"),
                ComponentPiece(id: "yan_d", glyph: "言", accessibilityName: "speech"),
                ComponentPiece(id: "mu_d", glyph: "木", accessibilityName: "tree"),
            ],
            solution: ["ren_rad", "ben"],
            targetSlots: [
                "ren_rad": CGPoint(x: 0.35, y: 0.50),
                "ben": CGPoint(x: 0.63, y: 0.50),
            ],
            evolutionFrames: ["亻本", "体"],
            reflection: "Body (体) combines Person (meaning) and Root (sound)."
        ),
        Level(
            id: 16, phase: .phonoSemantic,
            prompt: "Combine 'Speech' (言) and 'Completion' (成).\nWords that become real — what virtue is that?",
            components: [
                ComponentPiece(id: "yan_rad", glyph: "言", accessibilityName: "speech meaning radical"),
                ComponentPiece(id: "cheng", glyph: "成", accessibilityName: "completion sound component"),
                ComponentPiece(id: "xin_d", glyph: "心", accessibilityName: "heart"),
                ComponentPiece(id: "ren_d", glyph: "人", accessibilityName: "person"),
            ],
            solution: ["yan_rad", "cheng"],
            targetSlots: [
                "yan_rad": CGPoint(x: 0.35, y: 0.50),
                "cheng": CGPoint(x: 0.63, y: 0.50),
            ],
            evolutionFrames: ["言成", "诚"],
            reflection: "Honesty (诚) is Speech (meaning) + Completion (sound)."
        ),
    ]
}
