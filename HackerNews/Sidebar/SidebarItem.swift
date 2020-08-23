
import Foundation
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
}
