//
//  DBUtil.swift
//  DYJW
//
//  Created by FlyKite on 2020/10/1.
//  Copyright © 2020 Doge Studio. All rights reserved.
//

import UIKit
import CoreData

class DBUtil {
    static let context: NSManagedObjectContext? = getContext()
    
    private static func getContext() -> NSManagedObjectContext? {
        var url = URL(fileURLWithPath: NSHomeDirectory())
        url.appendPathComponent("Library")
        url.appendPathComponent("DYJW.sqlite")
        
        guard let modelUrl = Bundle.main.url(forResource: "DYJW", withExtension: "momd") else {
            return nil
        }
        guard let model = NSManagedObjectModel(contentsOf: modelUrl) else {
            return nil
        }
        
        let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch {
            print(error)
            return nil
        }
        
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        return context
    }
}
