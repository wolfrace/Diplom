//
//  DatabaseManager.swift
//  PlacenoteSDKExample
//
//  Created by Admin on 20.05.2018.
//  Copyright © 2018 Vertical. All rights reserved.
//

import Foundation
import CoreData

class DatabaseManager {
  private var context: NSManagedObjectContext!
  
  init(dbObjectContext: NSManagedObjectContext) {
    context = dbObjectContext
  }
  
  func getAttributes(id: Int64) -> [String: String] {
    var attributes: [String: String] = [:]
    
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Attributes")
    request.predicate = NSPredicate(format: "objectId == %d", id)
    request.returnsObjectsAsFaults = false
    
    do {
      let result = try self.context.fetch(request)
      for data in result as! [Attributes] {
        attributes =  jsonToDictionary(from: data.data!)
      }
    } catch {
      print("Failed")
    }
    
    return attributes
  }
  
  func updateAttributes(id: Int64, attributes: [String: String]) {
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Attributes")
    request.predicate = NSPredicate(format: "objectId == %d", id)
    request.returnsObjectsAsFaults = false
    
    do {
      let result = try self.context.fetch(request)
      let resultData = result as! [Attributes]
      if resultData.count != 0 {
        let managedObject = resultData[0]
        managedObject.data = dictionaryToJson(from: attributes)
        try self.context.save()
      }
    } catch {
      print("Failed")
    }
  }
  
  func deleteAttributes(id: Int64) {
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Attributes")
    request.predicate = NSPredicate(format: "objectId == %d", id)
    
    do {
      let result = try! self.context.fetch(request)
      let resultData = result as! [Attributes]
      for object in resultData {
        self.context.delete(object)
      }
      try self.context.save()
    } catch {
      print("Failed")
    }
  }
  
  func saveAttributes(attributes: [String: String]) -> Int64 {
    let nextAttributesId = getAutoIncremenet()
    let entity = NSEntityDescription.entity(forEntityName: "Attributes", in: self.context)
    let newAttributes = Attributes(entity: entity!, insertInto: self.context)
    
    newAttributes.objectId = nextAttributesId
    newAttributes.data = dictionaryToJson(from: attributes)
    
    do {
      try self.context.save()
    } catch {
      print("Failed saving")
    }
    
    return nextAttributesId
  }
  
  private func getAutoIncremenet() -> Int64   {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Attributes")
    let sortDescriptor = NSSortDescriptor(key: "objectId", ascending: true, selector: #selector(NSString.compare(_:)))
    fetchRequest.sortDescriptors = [sortDescriptor]
    
    var newID:Int64 = 0
    do {
      let result = try self.context.fetch(fetchRequest).last
      if result != nil {
        newID = ((result! as AnyObject).value(forKey: "objectId") as! Int64) + 1
      }
    } catch let error as NSError {
      NSLog("Unresolved error \(error)")
    }
    
    return newID
  }
  
  private func jsonToDictionary(from text: String) -> [String: String] {
    guard let data = text.data(using: .utf8) else { return [:] }
    let anyResult: Any? = try? JSONSerialization.jsonObject(with: data, options: [])
    return anyResult as? [String: String] ?? [:]
  }
  
  private func dictionaryToJson(from dictionary: [String: String]) -> String {
    let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: [])
    let jsonString = String(data: jsonData!, encoding: .utf8)
    return jsonString!
  }
  
}
