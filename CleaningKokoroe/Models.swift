import Foundation

struct CleaningTip: Codable, Identifiable {
    let id: Int
    let category: String
    let target: String
    let title: String
    let body: String
    let action: String
    let level: String
    let minutes: Int
    let warning: String
    let tags: [String]
}

struct FengShuiItem {
    let spot: String
    let direction: String
    let color: String
    let advice: String
}

let fengShuiData: [FengShuiItem] = [
    FengShuiItem(spot: "玄関", direction: "東", color: "若草", advice: "入口を軽く掃くと、朝の空気が入りやすくなります。"),
    FengShuiItem(spot: "洗面所", direction: "北", color: "白", advice: "鏡と蛇口を光らせると、水まわりの重さが抜けます。"),
    FengShuiItem(spot: "キッチン", direction: "南東", color: "青磁", advice: "シンクの水滴を切ると、家の流れがすっきりします。"),
    FengShuiItem(spot: "窓まわり", direction: "南", color: "淡い金", advice: "窓を一枚拭くと、光が入りやすくなります。"),
    FengShuiItem(spot: "寝る前の床", direction: "西", color: "生成り", advice: "床の物を少し減らすと、休む場所の気配が落ち着きます。"),
    FengShuiItem(spot: "トイレ", direction: "北東", color: "薄緑", advice: "床の奥を拭くと、こもったニオイを残しにくくなります。"),
    FengShuiItem(spot: "本棚", direction: "北西", color: "藍", advice: "紙を十枚だけ分けると、考えごとが散らかりにくくなります。"),
]

func todayFengShui() -> FengShuiItem {
    let cal = Calendar.current
    let d = cal.dateComponents([.year, .month, .day], from: Date())
    let seed = (d.year ?? 2026) * 10000 + (d.month ?? 1) * 100 + (d.day ?? 1)
    return fengShuiData[seed % fengShuiData.count]
}
