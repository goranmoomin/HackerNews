import HNAPI
import SwiftUI

extension TopLevelItem {
    var title: String {
        switch self {
        case .story(let story): return story.title
        case .job(let job): return job.title
        }
    }
    var creation: Date {
        switch self {
        case .story(let story): return story.creation
        case .job(let job): return job.creation
        }
    }
    var content: Content {
        switch self {
        case .story(let story): return story.content
        case .job(let job): return job.content
        }
    }
}

struct ItemListCellSwiftUIView: View {
    let formatter = RelativeDateTimeFormatter()
    let item: TopLevelItem
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.title).bold()
            if let host = item.content.url?.host {
                Button(host) { NSWorkspace.shared.open(item.content.url!) }
            }
            HStack(spacing: 2) {
                if case .story(let story) = item {
                    HStack(spacing: 2) {
                        Image(systemName: "person").imageScale(.large)
                        Text(story.author).bold()
                    }
                    HStack(spacing: 2) {
                        Image(systemName: "hand.thumbsup").imageScale(.large)
                        Text("\(story.points)")
                    }
                    HStack(spacing: 2) {
                        Image(systemName: "text.bubble").imageScale(.large)
                        Text("\(story.commentCount)")
                    }
                }
                HStack(spacing: 2) {
                    Image(systemName: "clock").imageScale(.large)
                    Text(formatter.localizedString(for: item.creation, relativeTo: Date()))
                }
            }
            .foregroundColor(.secondary).font(.system(size: NSFont.systemFontSize(for: .small)))
        }
        .padding(.horizontal).padding(.vertical, 8)
    }
}

struct ItemListCellSwiftUIView_Previews: PreviewProvider {
    static var items: [TopLevelItem] = {
        let file = Bundle.main.url(forResource: "TopLevelItems", withExtension: "json")!
        let data = try! Data(contentsOf: file)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return try! decoder.decode([TopLevelItem].self, from: data)
    }()

    static var previews: some View {
        ForEach(items, id: \.id) { item in ItemListCellSwiftUIView(item: item) }
    }
}
