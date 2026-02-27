import SwiftUI

struct OracleStroke: Hashable {
    let points: [CGPoint]
    let lineWidth: CGFloat

    init(points: [CGPoint], lineWidth: CGFloat = 4) {
        self.points = points
        self.lineWidth = lineWidth
    }

    init(_ tuples: [(CGFloat, CGFloat)], lineWidth: CGFloat = 4) {
        self.points = tuples.map { CGPoint(x: $0.0, y: $0.1) }
        self.lineWidth = lineWidth
    }
}

enum OracleStrokePaths {

    // MARK: - 日 Sun
    // Oracle bone: a circle with a dot/line in the center
    static func sun() -> [OracleStroke] {
        let n = 24
        var circle: [(CGFloat, CGFloat)] = []
        for i in 0...n {
            let angle = CGFloat(i) / CGFloat(n) * .pi * 2 - .pi / 2
            let x = 0.5 + cos(angle) * 0.28
            let y = 0.5 + sin(angle) * 0.28
            circle.append((x, y))
        }
        return [
            OracleStroke(circle, lineWidth: 4.5),
            OracleStroke([(0.42, 0.50), (0.58, 0.50)], lineWidth: 3.5),
        ]
    }

    // MARK: - 月 Moon
    // Oracle bone: a crescent with internal lines
    static func moon() -> [OracleStroke] {
        [
            OracleStroke([(0.38, 0.20), (0.38, 0.80)], lineWidth: 4),
            OracleStroke([(0.38, 0.20), (0.64, 0.24), (0.64, 0.76), (0.38, 0.80)], lineWidth: 4),
            OracleStroke([(0.38, 0.42), (0.62, 0.42)], lineWidth: 3),
            OracleStroke([(0.38, 0.60), (0.62, 0.60)], lineWidth: 3),
        ]
    }

    // MARK: - 人 Person
    // Oracle bone: a figure with legs spread apart
    static func person() -> [OracleStroke] {
        [
            OracleStroke([(0.50, 0.18), (0.42, 0.44), (0.30, 0.78)], lineWidth: 4.5),
            OracleStroke([(0.50, 0.18), (0.58, 0.48), (0.70, 0.78)], lineWidth: 4.5),
        ]
    }

    // MARK: - 木 Tree
    // Oracle bone: trunk + branches + roots
    static func tree() -> [OracleStroke] {
        [
            OracleStroke([(0.50, 0.14), (0.50, 0.86)], lineWidth: 4.5),
            OracleStroke([(0.26, 0.38), (0.50, 0.38), (0.74, 0.38)], lineWidth: 4),
            OracleStroke([(0.50, 0.56), (0.34, 0.76)], lineWidth: 3.5),
            OracleStroke([(0.50, 0.56), (0.66, 0.76)], lineWidth: 3.5),
        ]
    }

    // MARK: - 口 Mouth
    // Oracle bone: an open rectangular shape
    static func mouth() -> [OracleStroke] {
        [
            OracleStroke([(0.34, 0.28), (0.34, 0.72)], lineWidth: 4.5),
            OracleStroke([(0.34, 0.28), (0.66, 0.28), (0.66, 0.72)], lineWidth: 4.5),
            OracleStroke([(0.34, 0.72), (0.66, 0.72)], lineWidth: 4.5),
        ]
    }

    // MARK: - 心 Heart
    // Oracle bone: a vessel shape with internal dots/strokes
    static func heart() -> [OracleStroke] {
        [
            OracleStroke([
                (0.50, 0.22), (0.44, 0.38), (0.38, 0.54),
                (0.36, 0.66), (0.42, 0.76), (0.50, 0.78),
                (0.58, 0.76), (0.64, 0.66), (0.62, 0.54),
                (0.56, 0.38), (0.50, 0.22),
            ], lineWidth: 4),
            OracleStroke([(0.42, 0.46), (0.46, 0.52)], lineWidth: 3),
            OracleStroke([(0.54, 0.46), (0.58, 0.52)], lineWidth: 3),
            OracleStroke([(0.48, 0.60), (0.52, 0.64)], lineWidth: 3),
        ]
    }

    // MARK: - 女 Woman
    // Oracle bone: a kneeling figure with crossed arms
    static func woman() -> [OracleStroke] {
        [
            OracleStroke([(0.30, 0.30), (0.50, 0.46), (0.70, 0.30)], lineWidth: 4.5),
            OracleStroke([(0.50, 0.22), (0.50, 0.70)], lineWidth: 4.5),
            OracleStroke([(0.36, 0.70), (0.50, 0.70), (0.64, 0.70)], lineWidth: 4),
        ]
    }

    // MARK: - 子 Child
    // Oracle bone: a small figure with a large head
    static func child() -> [OracleStroke] {
        let n = 16
        var head: [(CGFloat, CGFloat)] = []
        for i in 0...n {
            let angle = CGFloat(i) / CGFloat(n) * .pi * 2 - .pi / 2
            let x = 0.50 + cos(angle) * 0.12
            let y = 0.28 + sin(angle) * 0.10
            head.append((x, y))
        }
        return [
            OracleStroke(head, lineWidth: 4),
            OracleStroke([(0.50, 0.38), (0.50, 0.78)], lineWidth: 4.5),
            OracleStroke([(0.34, 0.52), (0.50, 0.52), (0.66, 0.52)], lineWidth: 3.5),
        ]
    }

    // MARK: - 一 One
    // Oracle bone: a single horizontal stroke
    static func one() -> [OracleStroke] {
        [
            OracleStroke([(0.20, 0.50), (0.80, 0.50)], lineWidth: 5),
        ]
    }

    static func strokes(for characterID: String) -> [OracleStroke] {
        switch characterID {
        case "ri": return sun()
        case "yue": return moon()
        case "ren": return person()
        case "mu": return tree()
        case "kou": return mouth()
        case "xin": return heart()
        case "nv": return woman()
        case "zi": return child()
        case "yi": return one()
        default: return []
        }
    }
}
