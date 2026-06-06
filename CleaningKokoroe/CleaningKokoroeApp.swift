import SwiftUI
import GoogleMobileAds
import AppTrackingTransparency

@main
struct CleaningKokoroeApp: App {
    @State private var attRequested = false
    @State private var adsReady = false

    var body: some Scene {
        WindowGroup {
            ContentView(adsReady: adsReady)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    guard !attRequested else { return }
                    attRequested = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        ATTrackingManager.requestTrackingAuthorization { _ in
                            if UIDevice.current.userInterfaceIdiom == .phone {
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
}
