import SwiftUI

struct ContentView: View {
    @State private var store = TipStore()
    @State private var showTimer = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: 16) {
                        FengShuiCard()
                        TipCard(store: store)
                        FilterBar(store: store)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 100)
                }
                .background(Color(.systemGroupedBackground))

                BannerAdView(adUnitID: "ca-app-pub-9404799280370656/2663934779")
                    .frame(height: 50)
            }
            .navigationTitle("清掃の心得")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showTimer = true
                    } label: {
                        Image(systemName: "timer")
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        store.randomize()
                    } label: {
                        Image(systemName: "arrow.trianglehead.2.clockwise")
                    }
                }
            }
            .sheet(isPresented: $showTimer) {
                TimerView()
            }
        }
        .tint(Color.green)
    }
}

// MARK: - Feng Shui Card

struct FengShuiCard: View {
    let item = todayFengShui()

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("今日の風水掃除")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(item.spot)
                    .font(.title2.bold())
                Text(item.advice)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(spacing: 4) {
                Text(item.direction)
                    .font(.title3.bold())
                Text(item.color)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(12)
            .background(.green.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}

// MARK: - Tip Card

struct TipCard: View {
    let store: TipStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let tip = store.currentTip {
                HStack {
                    Text(tip.category)
                        .font(.caption.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.green.opacity(0.15), in: Capsule())
                    Spacer()
                    HStack(spacing: 8) {
                        Label(tip.level, systemImage: "star.fill")
                        Label("\(tip.minutes)分", systemImage: "clock")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                Text(tip.title)
                    .font(.headline)

                Text(tip.body)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineSpacing(4)

                if !tip.warning.isEmpty {
                    Label(tip.warning, systemImage: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                }

                HStack {
                    Text("\(store.currentIndex + 1) / \(store.filteredTips.count)件")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    Spacer()
                    Button { store.previous() } label: {
                        Image(systemName: "chevron.left")
                    }
                    Button { store.next() } label: {
                        Image(systemName: "chevron.right")
                    }
                }
            } else {
                Text("該当する心得がありません")
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}

// MARK: - Filter Bar

struct FilterBar: View {
    @Bindable var store: TipStore

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("検索: 浴室、カビ、5分…", text: $store.searchQuery)
                    .textFieldStyle(.plain)
                    .onChange(of: store.searchQuery) { _, _ in
                        store.applyFilter()
                    }
                if !store.searchQuery.isEmpty {
                    Button { store.searchQuery = ""; store.applyFilter() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(10)
            .background(Color(.tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 10))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(store.categories, id: \.self) { cat in
                        Button {
                            store.selectedCategory = cat
                            store.applyFilter()
                        } label: {
                            Text(cat)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(
                                    store.selectedCategory == cat
                                        ? Color.green.opacity(0.2)
                                        : Color(.tertiarySystemGroupedBackground),
                                    in: Capsule()
                                )
                                .foregroundStyle(store.selectedCategory == cat ? .green : .primary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}
