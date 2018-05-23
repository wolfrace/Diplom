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
  private var dropboxController: DropboxController = DropboxController()
  
  init(dbObjectContext: NSManagedObjectContext) {
    context = dbObjectContext
  }
  
  func saveDatabaseOnDropbox(completion: (() -> Void)? = nil, progressHandler: ((_ progress: Progress) -> Void)? = nil) {
    let attributesJson = getAllAttributesInJson()
    dropboxController.uploadData(data: attributesJson.string!.data(using: .utf8, allowLossyConversion: false)!,
                                 completion: completion,
                                 progressHandler: progressHandler)
  }
  
  func loadDatabaseFromDropbox() {
    dropboxController.downloadData{ [weak self](data: Data?) in
      if(data != nil) {
        self!.deleteAllData()
        
        let backToString = String(data: data!, encoding: .utf8) as String?
        let attributesJson = self!.jsonToArray(from: backToString!)
        for record in attributesJson {
          let dict = self!.jsonToDictionaryAny(from: record)
          let id = dict["objectId"] as! Int64
          let attributes = self!.jsonToDictionaryString(from: dict["data"]! as! String)
          self!.saveAttributesImpl(id: id, attributes: attributes)
        }
      }
    }
  }
  
  private func getAllAttributesInJson() -> [String] {
    var attributesInJson:[String] = []
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Attributes")
    do {
      let result = try self.context.fetch(request)
      for data in result as! [Attributes] {
        attributesInJson.append(data.toJSON()!)
      }
    } catch {
      print("Failed")
    }    
    return attributesInJson
  }
  
  func getAttributes(id: Int64) -> [String: String] {
    var attributes: [String: String] = [:]
    
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Attributes")
    request.predicate = NSPredicate(format: "objectId == %d", id)
    request.returnsObjectsAsFaults = false
    
    do {
      let result = try self.context.fetch(request)
      for data in result as! [Attributes] {
        attributes =  jsonToDictionaryString(from: data.data!)
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
  
  private func deleteAllData()
  {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Attributes")
    fetchRequest.returnsObjectsAsFaults = false
    
    do {
      let results = try context.fetch(fetchRequest)
      for managedObject in results {
        let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
        context.delete(managedObjectData)
      }
    } catch let error as NSError {
      print("Detele all data in Attributes error : \(error) \(error.userInfo)")
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
  
  private func saveAttributesImpl(id: Int64, attributes: [String: String]) {
    let entity = NSEntityDescription.entity(forEntityName: "Attributes", in: self.context)
    let newAttributes = Attributes(entity: entity!, insertInto: self.context)
    
    newAttributes.objectId = id
    newAttributes.data = dictionaryToJson(from: attributes)
    
    do {
      try self.context.save()
    } catch {
      print("Failed saving")
    }
  }
  
  func saveAttributes(attributes: [String: String]) -> Int64 {
    let nextAttributesId = getAutoIncremenet()
    saveAttributesImpl(id: nextAttributesId, attributes: attributes)
    
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
  
  private func jsonToDictionaryString(from text: String) -> [String: String] {
    guard let data = text.data(using: .utf8) else { return [:] }
    let anyResult: Any? = try? JSONSerialization.jsonObject(with: data, options: [])
    return anyResult as? [String: String] ?? [:]
  }
  
  private func jsonToDictionaryAny(from text: String) -> [String: Any] {
    guard let data = text.data(using: .utf8) else { return [:] }
    let anyResult: Any? = try? JSONSerialization.jsonObject(with: data, options: [])
    return anyResult as? [String: Any] ?? [:]
  }
  
  private func dictionaryToJson(from dictionary: [String: String]) -> String {
    let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: [])
    let jsonString = String(data: jsonData!, encoding: .utf8)
    return jsonString!
  }
 
  private func jsonToArray(from text:String) -> [String] {
    guard let data = text.data(using: .utf8) else { return [] }
    let anyResult: Any? = try? JSONSerialization.jsonObject(with: data, options: [])
    return anyResult as? [String] ?? []
  }
}

extension Array {
  var string: String? {
    do {
      let data = try JSONSerialization.data(withJSONObject: self, options: [])
      return String(data: data, encoding: .utf8)
    } catch {
      return nil
    }
  }
}

extension NSManagedObject {
  func toJSON() -> String? {
    let keys = Array(self.entity.attributesByName.keys)
    let dict = self.dictionaryWithValues(forKeys: keys)
    do {
      let jsonData = try JSONSerialization.data(withJSONObject: dict, options: [])
      let reqJSONStr = String(data: jsonData, encoding: .utf8)
      return reqJSONStr
    }
    catch{}
    return nil
  }
}
