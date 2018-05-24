//
//  ShapeFactory.swift
//  PlacenoteSDKExample
//
//  Created by Admin on 20.05.2018.
//  Copyright © 2018 Vertical. All rights reserved.
//

import Foundation
import SceneKit

class ShapeFactory {
  
  func createShape(position: SCNVector3, type: ShapeType, attributes: [String: String]) -> SCNNode {
    if (type == ShapeType.Plane) {
      return createPlaneShape(position: position, attributes: attributes)
    } else if (type == ShapeType.InformationTable) {
      return createInformationTableShape(position: position, attributes: attributes)
    }
    
    return SCNNode()
  }
  
  func updateShape(node: SCNNode, type: ShapeType, attributes: [String: String]) {
    switch type {
    case ShapeType.Plane:
      if let periodNode = node.childNodes[0].geometry as? SCNText {
        periodNode.string = attributes["period"]
      }
      
      if let specialOfferNode = node.childNodes[1].geometry as? SCNText {
        specialOfferNode.string = attributes["specialOffer"]
      }
    default: break
      // not implemented
    }
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
  
  func createInformationTableShape(position: SCNVector3, attributes: [String: String]) -> SCNNode {
    let imageBase64 = attributes["image"]!
    let dataDecoded : Data = Data(base64Encoded: imageBase64, options: .ignoreUnknownCharacters)!
    let image = UIImage(data: dataDecoded)!
    let period = attributes["period"]!
    let specialOffer = attributes["specialOffer"]!
    let pov = SCNVector3Make(Float(attributes["lookAt.x"]!)!, position.y, Float(attributes["lookAt.z"]!)!)
    
    var relativePosition = SCNVector3Make(0, 0, 0)
    let planeNode = SCNNode(geometry: ShapeType.createPlaneShape(image: image))
    planeNode.position = relativePosition
    planeNode.position.y += 0.3
    planeNode.scale = SCNVector3(x:0.8, y:0.8, z:0.8)
    
    let bgNode = SCNNode(geometry: ShapeType.createInformationTableBgShape())
    bgNode.position = relativePosition
    bgNode.position.z -= 0.1
    
    let periodNode = SCNNode(geometry: ShapeType.createInformationTableTitleShape(period: period))
    periodNode.scale = SCNVector3Make(0.01, 0.01, 0.01)
    relativePosition.x -= 0.5
    relativePosition.y += 0.7
    periodNode.position = relativePosition
    
    let specialOfferNode = SCNNode(geometry: ShapeType.createInformationTableTextShape(specialOffer: specialOffer))
    specialOfferNode.scale = SCNVector3Make(0.01, 0.01, 0.01)
    relativePosition.y -= 1.8
    specialOfferNode.position = relativePosition
    
    let posterNode = SCNNode()
    posterNode.position = position
    posterNode.look(at: pov)
    posterNode.addChildNode(bgNode)
    posterNode.addChildNode(periodNode)
    posterNode.addChildNode(specialOfferNode)
    posterNode.addChildNode(planeNode)
    
    posterNode.scale = SCNVector3(x:0.1, y:0.1, z:0.1)
    
    return posterNode
  }
  
}
