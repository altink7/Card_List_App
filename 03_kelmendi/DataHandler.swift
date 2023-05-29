//
//  DataHandler.swift
//  03_kelmendi
//
//  Created by Altin Kelmendi on 28.05.23.
//

import Foundation
import CoreData

class DataHandler {
    static let shared = DataHandler()

    public let persistentContainer: NSPersistentContainer

    init() {
        persistentContainer = NSPersistentContainer(name: "ItemModel")
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to initialize Core Data: \(error)")
            }
        }
    }

    func save() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                fatalError("Failed to save Core Data context: \(error)")
            }
        }
    }

    func delete(_ object: NSManagedObject) {
        let context = persistentContainer.viewContext
        context.delete(object)
        save()
    }

    func fetchItems() -> [Card] {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Card> = Card.fetchRequest()

        do {
            let items = try context.fetch(fetchRequest)
            return items
        } catch {
            fatalError("Failed to fetch items from Core Data: \(error)")
        }
    }

    func createItem() -> Card {
        let context = persistentContainer.viewContext
        let newItem = Card(context: context)
        return newItem
    }
}


