import SwiftUI
import AppTrackingTransparency

#if canImport(GoogleMobileAds)
import GoogleMobileAds
#endif

@main
struct CleaningKokoroeApp: App {
    @State private var attRequested = false
    @State private var adsReady = false

    private var isPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }

    var body: some Scene {
        WindowGroup {
            ContentView(adsReady: adsReady)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    guard !attRequested else { return }
                    attRequested = true
                    guard isPhone else { return }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        ATTrackingManager.requestTrackingAuthorization { _ in
                            DispatchQueue.main.async {
                                MobileAds.shared.start { _ in
                                    adsReady = true
                                }
                            }
                        }
                    }
                }
        }
    }
}
