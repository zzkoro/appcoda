//
//  FoodersApp.swift
//  Fooders
//
//  Created by junemp on 2021/10/24.
//

import SwiftUI
import os
import UserNotifications
import Firebase
import KakaoSDKCommon
import KakaoSDKAuth

@main
struct FoodersApp: App {
    
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    @Environment(\.scenePhase) var scenePhase
    
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "someCategory")
    
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                
                
        }
        .onChange(of: scenePhase) { (phase) in
            switch phase {
            case .active:
                print("Active")
            case .inactive:
                print("Inactive")
            case .background:
                print("Background")
                createQuickActions()
            @unknown default:
                print("Default scene phase")
            }
        }
    }
    
    init() {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor(named: "NavigationBarTitle") ?? UIColor.systemRed, .font: UIFont(name: "ArialRoundedMTBold", size: 35)!]
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor(named: "NavigationBarTitle") ?? UIColor.systemRed, .font:UIFont(name: "ArialRoundedMTBold", size: 20)!]
        navBarAppearance.backgroundColor = .red
        navBarAppearance.backgroundEffect = .none
        navBarAppearance.shadowColor = .clear
        
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
        
        // kakao sdk 초기화
//        let KAKAO_APP_KEY: String = (Bundle.main.infoDictionary?["KAKAO_APP_KEY"] as? String)!
        KakaoSDK.initSDK(appKey: getKakaoAppKey())
    }
    
    func createQuickActions() {
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            let shortcutItem1 = UIApplicationShortcutItem(type: "\(bundleIdentifier).OpenFavorites", localizedTitle: "Show Favorites", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(systemImageName: "tag"), userInfo: nil)
            
            let shortcutItem2 = UIApplicationShortcutItem(type: "\(bundleIdentifier).OpenDiscover", localizedTitle: "Discover Restaurants", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(systemImageName: "eyes"), userInfo: nil)
            
            let shortcutItem3 = UIApplicationShortcutItem(type: "\(bundleIdentifier).NewRestaurant", localizedTitle: "New Restaurant", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: .add), userInfo: nil)
            
            UIApplication.shared.shortcutItems = [shortcutItem1, shortcutItem2, shortcutItem3]
            

        }
    }
    
    func getKakaoAppKey() -> String {
        let account = "KakaoAppKey"
        let service = Bundle.main.bundleIdentifier
        
        print("start getKakaoAppKey")
        
        // kakao app key 조회하기
        let readQuery: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                    kSecAttrService: service!,
                                    kSecAttrAccount: account,
                                     kSecMatchLimit: kSecMatchLimitOne,
                               kSecReturnAttributes: true,
                                     kSecReturnData: true]
        
        var item: CFTypeRef?
        if (SecItemCopyMatching(readQuery as CFDictionary, &item) == errSecSuccess) {
            
            print("start secItemCopyMatching")
            
            if let existingItem = item as? [String: Any],
               let data = existingItem[kSecAttrGeneric as String] as? String {
            
                print("read kakao app key: \(data)")
                
                return data
            }
        }
        

        
        // kakao app key 가져와서 KeyChain에 저장하기
        let kakaoAppKey = "767521032bb2b2d62d2ece5819c68a78"
        let saveQuery: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                    kSecAttrService: service!,
                                    kSecAttrAccount: account,
                                kSecAttrGeneric: kakaoAppKey]

        print("start secItemAdd")
        
        if (SecItemAdd(saveQuery as CFDictionary, nil) != errSecSuccess) {
            print("save kakao app key error")
        }
        
        return kakaoAppKey
        
    }
}

final class MainSceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    @Environment(\.openURL) private var openURL: OpenURLAction
    
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "someCategory")
    
    // App이 수행되고 있을때(background) QuickActiond을 수행한 경우
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        logger.log("windowScene performActionFor called")
        
        completionHandler(handleQuickAction(shortcutItem: shortcutItem))
    }
    
    // App이 수행되고 있지 않는 상태에서 QuickAction을 수행한 경우
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        logger.log("scene willConnectTo called")
        
        guard let shortcutItem = connectionOptions.shortcutItem else {
            return
        }
        
        _ = handleQuickAction(shortcutItem: shortcutItem)
    }
    
    
    private func handleQuickAction(shortcutItem: UIApplicationShortcutItem) -> Bool {
        let shortcutType = shortcutItem.type
        
        guard let shortcutIdentifier = shortcutType.components(separatedBy: ".").last
        else {
            return false
        }
        
        guard let url = URL(string: "fooders://actions/" + shortcutIdentifier)
        else {
            print("Failed to initiate the url")
            return false
        }
        
        openURL(url)
        
        return true
    }
    
}

final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "someCategory")
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        
        let configuration = UISceneConfiguration(name: "Main Scene", sessionRole: connectingSceneSession.role)
        
        configuration.delegateClass = MainSceneDelegate.self
        
        return configuration
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        print("application didFinishLaunchingWithOptions called")
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        // authorization request
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { (granted, error) in
            if granted {
                print("User notifications are allowed.")
            } else {
                print("User notifications are not allowed.")
            }
        })
        application.registerForRemoteNotifications()

        return true
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        logger.log("apns registered token: \(deviceToken)")
        
        // With swizzling disabled you must set the APNs token here.
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        logger.log("first didReceiveRemoteNotification: \(userInfo)")
        
        completionHandler(UIBackgroundFetchResult.newData)

    }
}

extension AppDelegate:UNUserNotificationCenterDelegate {
    // Application이 Foreground 상태에서 Push를 받을때
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        logger.log("Foreground notification: \(notification)")
        logger.log("Foreground notification: title - \(notification.request.content.title), body - \(notification.request.content.body)")
        logger.log("Foreground notification userInfo: \(notification.request.content.userInfo)");
        
        let userInfo = notification.request.content.userInfo
        
        for key in userInfo.keys {
            logger.log("key: \(key), value: \(userInfo[key] as! NSObject)")
        }
        
        if let key1 = userInfo["key1"] as? String {
            logger.log("key1: \(key1)")
        }
        
        if  let apsDict = userInfo["aps"] as? NSDictionary,
            let alertDict = apsDict["alert"] as? NSDictionary,
            let apsTitle = alertDict["title"] as? String,
            let apsBody = alertDict["body"] as? String {
            logger.log("apsTitle: \(apsTitle), apsBody: \(apsBody)")
        }
        

        
        completionHandler([.alert, .badge, .sound])

    }
    
    // Push를 선택했을때
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        logger.log("clicked notification: \(response)")
        logger.log("clicked notification userInfo: \(response.notification.request.content.userInfo)")
        
        
        if response.actionIdentifier == "fooders.makeReservation" {
            logger.log("Make reservation...")
            if let phone = response.notification.request.content.userInfo["phone"] {
                let telURL = "tel://\(phone)"
                if let url = URL(string: telURL) {
                    if UIApplication.shared.canOpenURL(url) {
                        logger.log("calling \(telURL)")
                        UIApplication.shared.open(url)
                    }
                }
            }
        }
        
        completionHandler()
    }
}

extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
//        print("fcm registered token: \(String(describing: fcmToken))")
        
        logger.log("fcm registered token: \(String(describing: fcmToken))")
        
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
           name: Notification.Name("FCMToken"),
           object: nil,
           userInfo: dataDict
        )
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    
}
