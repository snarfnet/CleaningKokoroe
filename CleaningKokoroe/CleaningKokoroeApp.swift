import SwiftUI
import GoogleMobileAds
import AppTrackingTransparency

@main
struct CleaningKokoroeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        Task { await MobileAds.shared.start() }
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        guard !UserDefaults.standard.bool(forKey: "att_requested") else { return }
        UserDefaults.standard.set(true, forKey: "att_requested")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            ATTrackingManager.requestTrackingAuthorization { _ in }
        }
    }
}
