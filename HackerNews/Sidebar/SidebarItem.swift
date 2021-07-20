import Cocoa
import HNAPI

enum SidebarItem: Equatable {
    case header(title: String)
    case category(HNAPI.Category)
}

extension SidebarItem {
    var description: String {
        switch self {
        case .header(let title): return title
        case .category(let category):
            switch category {
            case .top: return "Top Items"
            case .new: return "New Items"
            case .best: return "Best Items"
            case .ask: return "Ask Items"
            case .show: return "Show Items"
            case .job: return "Job Items"
            }
        }
    }

    var icon: NSImage? {
        switch self {
        case .header: return nil
        case .category(let category):
            switch category {
            case .top: return NSImage(systemSymbolName: "heart", accessibilityDescription: nil)
            case .new:
                return NSImage(
                    systemSymbolName: "clock.arrow.circlepath", accessibilityDescription: nil)
            case .best:
                return NSImage(systemSymbolName: "hand.thumbsup", accessibilityDescription: nil)
            case .ask:
                return NSImage(systemSymbolName: "quote.bubble", accessibilityDescription: nil)
            case .show: return NSImage(systemSymbolName: "megaphone", accessibilityDescription: nil)
            case .job: return NSImage(systemSymbolName: "suitcase", accessibilityDescription: nil)
            }
        }
    }
}
