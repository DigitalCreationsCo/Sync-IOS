//
//  Persistence.swift
//  messageflow
//
//  Created by Bryant's MBP on 5/23/24.
//

import CoreData
import UserNotifications
import UIKit

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "messageflow")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func archiveMessage(_ message: String, from sender: String) {
        let context = container.viewContext
        let archivedMessage = ArchivedMessage(context: context)
        archivedMessage.content = message
        archivedMessage.sender = sender
        archivedMessage.dateReceived = Date()

        saveContext()
    }
    
    func forwardMessage(_ message: String) {
        let activityViewController = UIActivityViewController(activityItems: [message], applicationActivities: nil)
        if let topController = UIApplication.shared.keyWindow?.rootViewController {
            topController.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    func muteNotifications(for sender: String) {
        // Logic to mute notifications from the specific sender
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }

            let muteAction = UNNotificationAction(identifier: "MUTE_ACTION", title: "Mute", options: [])
            let category = UNNotificationCategory(identifier: "MESSAGE_CATEGORY", actions: [muteAction], intentIdentifiers: [], options: [])
            center.setNotificationCategories([category])
        }
    }
    
    func deferNotification(for message: String, until date: Date) {
        let content = UNMutableNotificationContent()
        content.body = message
        content.categoryIdentifier = "MESSAGE_CATEGORY"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: date.timeIntervalSinceNow, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}
