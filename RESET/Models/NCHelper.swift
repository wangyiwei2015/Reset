//
//  NCHelper.swift
//  RESET
//
//  Created by Wangyiwei on 2021/6/14.
//

import Foundation
import UserNotifications

class NCHelper: NSObject {
    static let shared = NCHelper()
    
    private let center = UNUserNotificationCenter.current()
    public var authed = false
    
    public func updateAuth() {
        checkAuth({self.authed = $0})
    }
    
    private func checkAuth(_ completion: @escaping ((Bool)->Void)) {
        center.getNotificationSettings(completionHandler: {settings in
            switch settings.authorizationStatus {
            case .authorized, .ephemeral, .provisional:
                completion(true)
            case .notDetermined:
                self.center.requestAuthorization(
                    options: [.alert, .badge, .sound],
                    completionHandler: {success, error in
                        completion(success && (error == nil))
                    }
                )
            case .denied:
                completion(false)
            @unknown default:
                fatalError()
            }
        })
    }
    
    public func addNotification(_ title: String, body: String, after: TimeInterval) -> UUID? {
        guard authed else {return nil}
        let id = UUID()
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: after, repeats: false)
        let content = UNMutableNotificationContent()
        content.title = title
        //content.subtitle = ""
        content.body = body
        content.sound = .default
        let request = UNNotificationRequest(
            identifier: id.uuidString,
            content: content,
            trigger: trigger)
        center.add(request, withCompletionHandler: nil)
        return id
    }
    
    public func removeNotification(_ id: [UUID]) {
        if id.isEmpty {return}
        center.removePendingNotificationRequests(
            withIdentifiers: id.map({$0.uuidString})
        )
    }
    
    public func test() -> UUID? {
//        var granted = false
//        let sema = DispatchSemaphore(value: 0)
//        checkAuth({result in
//            granted = result
//            sema.signal()
//        })
//        sema.wait()
//        guard granted else {return nil}
        guard authed else {return nil}
        let id = UUID()
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let content = UNMutableNotificationContent()
        content.title = "title"
        content.subtitle = "sub"
        content.body = ""
        content.sound = .default
        let request = UNNotificationRequest(
            identifier: id.uuidString,
            content: content,
            trigger: trigger)
        center.add(request, withCompletionHandler: nil)
        return id
    }
}

