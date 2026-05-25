import Foundation

@Observable
final class TipStore {
    var tips: [CleaningTip] = []
    var filteredTips: [CleaningTip] = []
    var categories: [String] = []
    var selectedCategory: String = "すべて"
    var searchQuery: String = ""
    var currentIndex: Int = 0

    var currentTip: CleaningTip? {
        guard !filteredTips.isEmpty else { return nil }
        return filteredTips[currentIndex % filteredTips.count]
    }

    init() {
        loadTips()
    }

    private func loadTips() {
        guard let url = Bundle.main.url(forResource: "cleaning_tips", withExtension: "json") else { return }
        do {
            let data = try Data(contentsOf: url)
            tips = try JSONDecoder().decode([CleaningTip].self, from: data)
            let catSet = Set(tips.map(\.category))
            categories = ["すべて"] + catSet.sorted()
            applyFilter()
            randomize()
        } catch {
            print("Failed to load tips: \(error)")
        }
    }

    func applyFilter() {
        var result = tips
        if selectedCategory != "すべて" {
            result = result.filter { $0.category == selectedCategory }
        }
        if !searchQuery.isEmpty {
            let q = searchQuery.lowercased()
            result = result.filter {
                $0.title.lowercased().contains(q) ||
                $0.body.lowercased().contains(q) ||
                $0.target.lowercased().contains(q) ||
                $0.tags.contains(where: { $0.lowercased().contains(q) })
            }
        }
        filteredTips = result
        currentIndex = 0
    }

    func next() {
        guard !filteredTips.isEmpty else { return }
        currentIndex = (currentIndex + 1) % filteredTips.count
    }

    func previous() {
        guard !filteredTips.isEmpty else { return }
        currentIndex = (currentIndex - 1 + filteredTips.count) % filteredTips.count
    }

    func randomize() {
        guard !filteredTips.isEmpty else { return }
        currentIndex = Int.random(in: 0..<filteredTips.count)
    }
}
