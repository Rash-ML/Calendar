import Foundation

extension Calendar {
    public var isRTL: Bool {
        guard let locale = locale else { return false }
        let identifier = locale.identifier
        switch identifier {
        case _ where identifier.contains("fa"): return true
        default: return false
        }
    }
}
