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

//Class to manage a list of shapes to be view in Augmented Reality including spawning, managing a list and saving/retrieving from persistent memory using JSON
class ShapeManager {
  
  private var scnScene: SCNScene!
  private var scnView: SCNView!
  private var dbManager: DatabaseManager!
  
  private var shapePositions: [SCNVector3] = []
  private var shapeTypes: [ShapeType] = []
  private var shapeNodes: [SCNNode] = []
  private var shapeAttributes: [Int64] = []
  
  public var shapesDrawn: Bool! = false
  
  init(scene: SCNScene, view: SCNView, dbObjectContext: NSManagedObjectContext) {
    scnScene = scene
    scnView = view
    dbManager = DatabaseManager(dbObjectContext: dbObjectContext)
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
      let attributes = dbManager.getAttributes(id: attributesId)
      
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
    
    let attributesId = dbManager.saveAttributes(attributes: attributes)
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
    
    posterNode.scale = SCNVector3(x:0.1, y:0.1, z:0.1)
    
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
  
  func findShape(node: SCNNode) -> SCNNode? {
    var localNode = node
    if (localNode.parent != nil) {
      localNode = localNode.parent!
    }
    
    if shapeNodes.index(of: localNode) != nil {
      return localNode
    }
    
    return nil
  }
  
  func getShapeAttributes(node: SCNNode) -> [String: String]? {
    if let index = shapeNodes.index(of: node) {
      return dbManager.getAttributes(id: Int64(index))
    }
    return nil
  }
  
  func updateShapeAttributes(node: SCNNode, attributes: [String: String]) {
    if let index = shapeNodes.index(of: node) {
      dbManager.updateAttributes(id: Int64(index), attributes: attributes)
    }
  }
  
  func deleteShape(node: SCNNode) {
    if let index = shapeNodes.index(of: node) {
      let dbIndex = shapeAttributes[index]
      dbManager.deleteAttributes(id: dbIndex)
      
      shapeNodes[index].removeFromParentNode()
      shapeNodes.remove(at: index)
      shapeTypes.remove(at: index)
      shapePositions.remove(at: index)
      shapeAttributes.remove(at: index)
    }
  }
}
