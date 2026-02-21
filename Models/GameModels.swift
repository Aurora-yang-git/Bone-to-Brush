import SwiftUI

enum Phase: Hashable {
    case pictograph
    case ideograph
    case compound
    case phonoSemantic
}

struct ComponentPiece: Identifiable, Hashable {
    let id: String
    let glyph: String
    let accessibilityName: String
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

struct Level: Identifiable {
    let id: Int
    let phase: Phase
    let prompt: String
    let components: [ComponentPiece]
    let solution: [String]
    let targetSlots: [String: CGPoint]
    let evolutionFrames: [String]
    let reflection: String
    let ancientForm: String?
    let pictographImage: String?
    let referenceImage: String?
    let referenceSymbol: String?
    let traceGuide: TraceGuide?

    init(
        id: Int, phase: Phase, prompt: String,
        components: [ComponentPiece], solution: [String],
        targetSlots: [String: CGPoint] = [:],
        evolutionFrames: [String], reflection: String,
        ancientForm: String? = nil,
        pictographImage: String? = nil,
        referenceImage: String? = nil,
        referenceSymbol: String? = nil,
        traceGuide: TraceGuide? = nil
    ) {
        self.id = id
        self.phase = phase
        self.prompt = prompt
        self.components = components
        self.solution = solution
        self.targetSlots = targetSlots
        self.evolutionFrames = evolutionFrames
        self.reflection = reflection
        self.ancientForm = ancientForm
        self.pictographImage = pictographImage
        self.referenceImage = referenceImage
        self.referenceSymbol = referenceSymbol
        self.traceGuide = traceGuide
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

    static func hand() -> TraceGuide {
        TraceGuide(strokes: [
            stroke([(0.32, 0.38), (0.72, 0.38)]),
            stroke([(0.38, 0.50), (0.68, 0.50)]),
            stroke([(0.50, 0.20), (0.50, 0.80)]),
            stroke([(0.50, 0.62), (0.38, 0.80)]),
            stroke([(0.50, 0.62), (0.66, 0.78)]),
        ], completionThreshold: 0.58)
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
