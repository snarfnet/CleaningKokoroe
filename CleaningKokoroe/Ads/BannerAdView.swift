import SwiftUI
import GoogleMobileAds

struct BannerAdView: UIViewRepresentable {
    let adUnitID: String

    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView()
        banner.adUnitID = adUnitID
        banner.translatesAutoresizingMaskIntoConstraints = false
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first,
               let root = windowScene.keyWindow?.rootViewController {
                banner.rootViewController = root
                banner.load(Request())
            }
        }
        return banner
    }

    func updateUIView(_ uiView: BannerView, context: Context) {}
}
