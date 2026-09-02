import UIKit

/// Haptic intensity tiers mapped to button importance in the Soundbook UI.
enum HapticFeedback {
    enum Level {
        /// Hero tiles and primary confirm actions.
        case primary
        /// Medium tiles and main navigation controls.
        case secondary
        /// Small tiles and dismissive actions.
        case tertiary
        /// Library and segmented selection changes.
        case selection
    }

    static func trigger(_ level: Level) {
        switch level {
        case .primary:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        case .secondary:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .tertiary:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .selection:
            UISelectionFeedbackGenerator().selectionChanged()
        }
    }
}

extension SoundGridPlacement {
    /// Grid footprint used to scale tile tap haptics with visual hierarchy.
    var gridCellCount: Int {
        columnSpan * rowSpan
    }

    var hapticLevel: HapticFeedback.Level {
        switch gridCellCount {
        case 16...:
            return .primary
        case 7..<16:
            return .secondary
        default:
            return .tertiary
        }
    }
}

extension SoundItem {
    var hapticLevel: HapticFeedback.Level {
        gridPlacement.hapticLevel
    }
}
