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

func convertToDictionary(from text: String) -> [String: String] {
  guard let data = text.data(using: .utf8) else { return [:] }
  let anyResult: Any? = try? JSONSerialization.jsonObject(with: data, options: [])
  return anyResult as? [String: String] ?? [:]
}


//Class to manage a list of shapes to be view in Augmented Reality including spawning, managing a list and saving/retrieving from persistent memory using JSON
class ShapeManager {
  
  private var scnScene: SCNScene!
  private var scnView: SCNView!
  private var dbManager: NSManagedObjectContext!
  
  private var shapePositions: [SCNVector3] = []
  private var shapeTypes: [ShapeType] = []
  private var shapeNodes: [SCNNode] = []
  private var shapeAttributes: [[String: String]] = []
  
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
      let attributes: [String: String] = convertToDictionary(from: item["shape"]!["attributes"]!)
      let type: ShapeType = ShapeType(rawValue: Int(item["shape"]!["style"]!)!)!
      shapePositions.append(position)
      shapeTypes.append(type)
      shapeNodes.append(createShape(position: position, type: type))
      shapeAttributes.append(attributes)

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
    for node in shapeNodes {
      node.geometry!.firstMaterial!.normal.contents = nil
      node.geometry!.firstMaterial!.diffuse.contents = nil
    }
    shapeNodes.removeAll()
    shapePositions.removeAll()
    shapeTypes.removeAll()
  }
  
  func spawnPlaneShape(position: SCNVector3, image: UIImage) {
    placePlaneShape(position: position, image: image)
  }
  
  func spawnRandomShape(position: SCNVector3) {
    
    let shapeType: ShapeType = ShapeType.random()
    placeShape(position: position, type: shapeType)
  }
  
  func placePlaneShape (position: SCNVector3, image: UIImage) {
    
    let geometryNode: SCNNode = createPlaneShape(position: position, image: image)
    
    shapePositions.append(position)
    shapeTypes.append(ShapeType.Plane)
    shapeNodes.append(geometryNode)
    
    var attributes: [String: String] = [:]
    
    //let imageData:NSData = UIImagePNGRepresentation(image)! as NSData
    //let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
   // attributes["image"] = strBase64
    shapeAttributes.append(attributes)
    
    scnScene.rootNode.addChildNode(geometryNode)
    shapesDrawn = true
  }
  
  func placeShape (position: SCNVector3, type: ShapeType) {
    
    let geometryNode: SCNNode = createShape(position: position, type: type)
    
    shapePositions.append(position)
    shapeTypes.append(type)
    shapeNodes.append(geometryNode)
    
    let attributes: [String: String] = [:]
    shapeAttributes.append(attributes)
    
    scnScene.rootNode.addChildNode(geometryNode)
    shapesDrawn = true
  }
  
  func createPlaneShape(position: SCNVector3, image: UIImage) -> SCNNode {
    let geometry:SCNGeometry = ShapeType.createPlaneShape(image: image)
    
    let geometryNode = SCNNode(geometry: geometry)
    geometryNode.position = position
    geometryNode.scale = SCNVector3(x:0.1, y:0.1, z:0.1)
    
    return geometryNode
  }
  
  func createShape (position: SCNVector3, type: ShapeType) -> SCNNode {
    let geometry:SCNGeometry = ShapeType.generateGeometry(s_type: type)
    let color = generateRandomColor()
    geometry.materials.first?.diffuse.contents = color
    
    let geometryNode = SCNNode(geometry: geometry)
    geometryNode.position = position
    geometryNode.scale = SCNVector3(x:0.1, y:0.1, z:0.1)
    
    return geometryNode
  }
  
  
}
