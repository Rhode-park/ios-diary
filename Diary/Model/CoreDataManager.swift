//
//  CoreDataManager.swift
//  Diary
//
//  Created by Jinah Park on 2023/05/01.
//

import CoreData
import Foundation

class CoreDataManager {
    static var shared: CoreDataManager = CoreDataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Diary")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    var diaryEntity: NSEntityDescription? {
        return  NSEntityDescription.entity(forEntityName: "Entity", in: context)
    }
    
    func createDiary(_ diary: Diary) -> Bool {
        if let entity = diaryEntity {
            let managedObject = NSManagedObject(entity: entity, insertInto: context)
            managedObject.setValue(diary.title, forKey: "title")
            managedObject.setValue(diary.body, forKey: "body")
            managedObject.setValue(diary.date, forKey: "date")
            
            do {
                try self.context.save()
                return true
            } catch {
                print(error.localizedDescription)
                return false
            }
        } else {
            return false
        }
    }
    
    func fetchDiary() -> [Diary]? {
        let readRequest = NSFetchRequest<NSManagedObject>(entityName: "Entity")
        guard let diaryData = try? context.fetch(readRequest) else { return nil }
        var diaries = [Diary]()
        
        for diary in diaryData {
            guard let title = diary.value(forKey: "title") as? String,
                  let body = diary.value(forKey: "body") as? String,
                  let date = diary.value(forKey: "date") as? Double else { return nil }
            
            diaries.append(Diary(title: title, body: body, date: date))
        }
        
        return diaries
    }
}
