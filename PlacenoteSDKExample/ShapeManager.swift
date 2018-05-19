//
//  ShapeManager.swift
//  Shape Dropper (Placenote SDK iOS Sample)
//
//  Created by Prasenjit Mukherjee on 2017-10-20.
//  Copyright © 2017 Vertical AI. All rights reserved.
//

import Foundation
import CoreData
import SceneKit

extension String {
  func appendLineToURL(fileURL: URL) throws {
    try (self + "\n").appendToURL(fileURL: fileURL)
  }
  
  func appendToURL(fileURL: URL) throws {
    let data = self.data(using: String.Encoding.utf8)!
    try data.append(fileURL: fileURL)
  }
}


extension Data {
  func append(fileURL: URL) throws {
    if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
      defer {
        fileHandle.closeFile()
      }
      fileHandle.seekToEndOfFile()
      fileHandle.write(self)
    }
    else {
      try write(to: fileURL, options: .atomic)
    }
  }
}

func generateRandomColor() -> UIColor {
  let hue : CGFloat = CGFloat(arc4random() % 256) / 256 // use 256 to get full range from 0.0 to 1.0
  let saturation : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.3 // from 0.3 to 1.0 to stay away from white
  let brightness : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.3 // from 0.3 to 1.0 to stay away from black
  
  return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
}

func jsonToDictionary(from text: String) -> [String: String] {
  guard let data = text.data(using: .utf8) else { return [:] }
  let anyResult: Any? = try? JSONSerialization.jsonObject(with: data, options: [])
  return anyResult as? [String: String] ?? [:]
}

func dictionaryToJson(from dictionary: [String: String]) -> String {
  let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: [])
  let jsonString = String(data: jsonData!, encoding: .utf8)
  return jsonString!
}

//Class to manage a list of shapes to be view in Augmented Reality including spawning, managing a list and saving/retrieving from persistent memory using JSON
class ShapeManager {
  
  private var scnScene: SCNScene!
  private var scnView: SCNView!
  private var dbManager: NSManagedObjectContext!
  
  private var shapePositions: [SCNVector3] = []
  private var shapeTypes: [ShapeType] = []
  private var shapeNodes: [SCNNode] = []
  private var shapeAttributes: [Int64] = []
  
  public var shapesDrawn: Bool! = false

  
  init(scene: SCNScene, view: SCNView, dbObjectContext: NSManagedObjectContext) {
    scnScene = scene
    scnView = view
    dbManager = dbObjectContext
  }
  
  func getAutoIncremenet() -> Int64   {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Attributes")
    let sortDescriptor = NSSortDescriptor(key: "objectId", ascending: true, selector: #selector(NSString.compare(_:)))
    fetchRequest.sortDescriptors = [sortDescriptor]
    
    var newID:Int64 = 0
    do {
      let result = try self.dbManager.fetch(fetchRequest).last
      if result != nil {
        newID = ((result! as AnyObject).value(forKey: "objectId") as! Int64) + 1
      }
    } catch let error as NSError {
      NSLog("Unresolved error \(error)")
    }
    
    return newID
  }
  
  func getShapeArray() -> [[String: [String: String]]] {
    var shapeArray: [[String: [String: String]]] = []
    if (shapePositions.count > 0) {
      for i in 0...(shapePositions.count-1) {
        shapeArray.append([
          "shape": [
            "style": "\(shapeTypes[i].rawValue)",
            "attributes": "\(shapeAttributes[i])",
            "x": "\(shapePositions[i].x)",  "y": "\(shapePositions[i].y)",  "z": "\(shapePositions[i].z)"
          ]
          ])
      }
    }
    return shapeArray
  }

  // Load shape array
  func loadShapeArray(shapeArray: [[String: [String: String]]]?) -> Bool {
    clearShapes() //clear currently viewing shapes and delete any record of them.

    if (shapeArray == nil) {
        print ("Shape Manager: No shapes for this map")
        return false
    }

    for item in shapeArray! {
      let x_string: String = item["shape"]!["x"]!
      let y_string: String = item["shape"]!["y"]!
      let z_string: String = item["shape"]!["z"]!
      let position: SCNVector3 = SCNVector3(x: Float(x_string)!, y: Float(y_string)!, z: Float(z_string)!)
      let attributesId: Int64 = Int64(item["shape"]!["attributes"]!)!
      let type: ShapeType = ShapeType(rawValue: Int(item["shape"]!["style"]!)!)!
      let attributes = getAttributes(id: attributesId)
      
      shapePositions.append(position)
      shapeTypes.append(type)
      shapeNodes.append(createShape(position: position, type: type, attributes: attributes))
      shapeAttributes.append(attributesId)

      print ("Shape Manager: Retrieved " + String(describing: type) + " type at position" + String (describing: position))
    }

    print ("Shape Manager: retrieved " + String(shapePositions.count) + " shapes")
    return true
  }

  func clearView() { //clear shapes from view
    for shape in shapeNodes {
      shape.removeFromParentNode()
    }
    shapesDrawn = false
  }
  
  func drawView(parent: SCNNode) {
    guard !shapesDrawn else {return}
    for shape in shapeNodes {
      parent.addChildNode(shape)
    }
    shapesDrawn = true
  }
  
  func clearShapes() { //delete all nodes and record of all shapes
    clearView()
//    for node in shapeNodes {
//      node.geometry!.firstMaterial!.normal.contents = nil
//      node.geometry!.firstMaterial!.diffuse.contents = nil
//    }
    shapeNodes.removeAll()
    shapePositions.removeAll()
    shapeTypes.removeAll()
  }
  
  func spawnPlaneShape(position: SCNVector3, image: UIImage, period: String, specialOffer: String) {
    placePlaneShape(position: position, image: image, period: period, specialOffer: specialOffer)
  }
  
  func spawnRandomShape(position: SCNVector3) {
    
    let shapeType: ShapeType = ShapeType.random()
    placeShape(position: position, type: shapeType, attributes: [:])
  }
  
  func getAttributes(id: Int64) -> [String: String] {
    var attributes: [String: String] = [:]
    
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Attributes")
    request.predicate = NSPredicate(format: "objectId == %d", id)
    request.returnsObjectsAsFaults = false
    
    do {
      let result = try self.dbManager.fetch(request)
      for data in result as! [NSManagedObject] {
        attributes = jsonToDictionary(from: (data.value(forKey: "data") as! String))
      }
    } catch {
      print("Failed")
    }
    
    return attributes
  }
  
  func deleteAttributes(id: Int64) {
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Attributes")
    request.predicate = NSPredicate(format: "objectId == %d", id)
    
    do {
      let result = try! self.dbManager.fetch(request)
      let resultData = result as! [Attributes]
      for object in resultData {
        self.dbManager.delete(object)
      }
      try self.dbManager.save()
    } catch {
      print("Failed")
    }
  }
  
  func saveAttributes(attributes: [String: String]) -> Int64 {
    let nextAttributesId = getAutoIncremenet()
    let entity = NSEntityDescription.entity(forEntityName: "Attributes", in: self.dbManager)
    let newAttributes = NSManagedObject(entity: entity!, insertInto: self.dbManager)
    
    newAttributes.setValue(nextAttributesId, forKey: "objectId")
    newAttributes.setValue(dictionaryToJson(from: attributes), forKey: "data")
    
    do {
      try self.dbManager.save()
    } catch {
      print("Failed saving")
    }
    
    return nextAttributesId
  }
  
  func placePlaneShape (position: SCNVector3, image: UIImage, period: String, specialOffer: String) {
    var attributes: [String: String] = [:]
    
    let imageData:NSData = UIImagePNGRepresentation(image)! as NSData
    let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
    attributes["image"] = strBase64
    attributes["period"] = period
    attributes["specialOffer"] = specialOffer
    
    var pov = (scnView.pointOfView?.position)!
    pov.y = position.y
    pov.z = 2 * position.z - pov.z
    pov.x = 2 * position.x - pov.x
    attributes["lookAt.x"] = String(pov.x)
    attributes["lookAt.z"] = String(pov.z)
    
    placeShape(position: position, type: ShapeType.Plane, attributes: attributes)
  }
  
  func placeShape (position: SCNVector3, type: ShapeType, attributes: [String: String]) {
    
    let geometryNode: SCNNode = createShape(position: position, type: type, attributes: attributes)
    
    shapePositions.append(position)
    shapeTypes.append(type)
    shapeNodes.append(geometryNode)
    
    let attributesId = saveAttributes(attributes: attributes)
    shapeAttributes.append(attributesId)
    
    scnScene.rootNode.addChildNode(geometryNode)
    shapesDrawn = true
  }
  
  func createPlaneShape(position: SCNVector3, attributes: [String: String]) -> SCNNode {
    let imageBase64 = attributes["image"]!
    let dataDecoded : Data = Data(base64Encoded: imageBase64, options: .ignoreUnknownCharacters)!
    let image = UIImage(data: dataDecoded)!
    let period = attributes["period"]!
    let specialOffer = attributes["specialOffer"]!
    let pov = SCNVector3Make(Float(attributes["lookAt.x"]!)!, position.y, Float(attributes["lookAt.z"]!)!)
    
    var relativePosition = SCNVector3Make(0, 0, 0)
    let planeNode = SCNNode(geometry: ShapeType.createPlaneShape(image: image))
    planeNode.position = relativePosition
    
    let periodNode = SCNNode(geometry: ShapeType.createPeriodTextShape(period: period))
    periodNode.scale = SCNVector3Make(0.01, 0.01, 0.01)
    relativePosition.x += 0.75
    relativePosition.y += 0.2
    periodNode.position = relativePosition
    
    let specialOfferNode = SCNNode(geometry: ShapeType.createSpecialOfferTextShape(specialOffer: specialOffer))
    specialOfferNode.scale = SCNVector3Make(0.01, 0.01, 0.01)
    relativePosition.y -= 1
    specialOfferNode.position = relativePosition
    
    let posterNode = SCNNode()
    posterNode.position = position
    posterNode.look(at: pov)
    posterNode.addChildNode(periodNode)
    posterNode.addChildNode(specialOfferNode)
    posterNode.addChildNode(planeNode)
    
    //posterNode.scale = SCNVector3(x:0.1, y:0.1, z:0.1)
    
    return posterNode
  }
  
  func createShape (position: SCNVector3, type: ShapeType, attributes: [String: String]) -> SCNNode {
    if (type == ShapeType.Plane) {
      return createPlaneShape(position: position, attributes: attributes)
    }
    
    let geometry:SCNGeometry = createGeometry(type: type, attributes: attributes)
    
    let geometryNode = SCNNode(geometry: geometry)
    geometryNode.position = position
    
    return geometryNode
  }
  
  func createGeometry(type: ShapeType, attributes: [String: String]) -> SCNGeometry {
    switch type {
    case ShapeType.Plane:
      let imageBase64 = attributes["image"]!
      let dataDecoded : Data = Data(base64Encoded: imageBase64, options: .ignoreUnknownCharacters)!
      let image = UIImage(data: dataDecoded)!
      return ShapeType.createPlaneShape(image: image)
    default:
      let geometry = ShapeType.generateGeometry(s_type: type)
      let color = generateRandomColor()
      geometry.materials.first?.diffuse.contents = color
      return geometry
    }
  }
  
  func deleteShape(node: SCNNode) {
    var localNode = node
    if (localNode.parent != nil) {
      localNode = localNode.parent!
    }
    
    if let index = shapeNodes.index(of: localNode) {
      deleteShapeImpl(index: index)
    }
  }
  
  private func deleteShapeImpl(index: Int) {
    let dbIndex = shapeAttributes[index]
    deleteAttributes(id: dbIndex)
    
    shapeNodes[index].removeFromParentNode()
    shapeNodes.remove(at: index)
    shapeTypes.remove(at: index)
    shapePositions.remove(at: index)
    shapeAttributes.remove(at: index)
  }
}
