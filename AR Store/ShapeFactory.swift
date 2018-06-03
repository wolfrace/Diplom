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
    switch type {
    case .Poster:
      return createPoster(position: position, attributes: attributes)
    case .Cube:
      return createCube(position: position, attributes: attributes)
    case .LateralFootnote:
      return createLateralFootnote(position: position, attributes: attributes)
    case .LateralFootnoteWithoutImage:
      return createLateralFootnoteWithoutImage(position: position, attributes: attributes)
    case .Footnote:
      return createFootnote(position: position, attributes: attributes)
    case .FootnoteWithoutImage:
      return createFootnoteWithoutImage(position: position, attributes: attributes)
    case .Arrow:
      return createArrow(position: position, attributes: attributes)
    }
  }
  
  func updateShape(node: SCNNode, type: ShapeType, attributes: [String: String]) {
    if let periodNode = node.childNodes[0].geometry as? SCNText {
      periodNode.string = attributes["period"]
    }
    
    if let specialOfferNode = node.childNodes[1].geometry as? SCNText {
      specialOfferNode.string = attributes["specialOffer"]
    }
  }
  
//  func createPlaneShape(position: SCNVector3, attributes: [String: String]) -> SCNNode {
//    let imageBase64 = attributes["image"]!
//    let dataDecoded : Data = Data(base64Encoded: imageBase64, options: .ignoreUnknownCharacters)!
//    let image = UIImage(data: dataDecoded)!
//    let period = attributes["period"]!
//    let specialOffer = attributes["specialOffer"]!
//    let pov = SCNVector3Make(Float(attributes["lookAt.x"]!)!, position.y, Float(attributes["lookAt.z"]!)!)
//
//    var relativePosition = SCNVector3Make(0, 0, 0)
//    let planeNode = SCNNode(geometry: ShapeType.createPlaneShape(image: image))
//    planeNode.position = relativePosition
//
//    let periodNode = SCNNode(geometry: ShapeType.createPeriodTextShape(period: period))
//    periodNode.scale = SCNVector3Make(0.01, 0.01, 0.01)
//    relativePosition.x += 0.75
//    relativePosition.y += 0.2
//    periodNode.position = relativePosition
//
//    let specialOfferNode = SCNNode(geometry: ShapeType.createSpecialOfferTextShape(specialOffer: specialOffer))
//    specialOfferNode.scale = SCNVector3Make(0.01, 0.01, 0.01)
//    relativePosition.y -= 1
//    specialOfferNode.position = relativePosition
//
//    let posterNode = SCNNode()
//    posterNode.position = position
//    posterNode.look(at: pov)
//    posterNode.addChildNode(periodNode)
//    posterNode.addChildNode(specialOfferNode)
//    posterNode.addChildNode(planeNode)
//
//    //posterNode.scale = SCNVector3(x:0.1, y:0.1, z:0.1)
//
//    return posterNode
//  }
  
  func createCube(position: SCNVector3, attributes: [String: String]) -> SCNNode {
    let imageBase64 = attributes["image"]!
    let dataDecoded : Data = Data(base64Encoded: imageBase64, options: .ignoreUnknownCharacters)!
    let image = UIImage(data: dataDecoded)!
    let period = attributes["period"]!
    let specialOffer = attributes["specialOffer"]!
    let pov = SCNVector3Make(Float(attributes["lookAt.x"]!)!, position.y, Float(attributes["lookAt.z"]!)!)
    
    let relativePosition = SCNVector3Make(0, 0, 0)
    
    let boxNode = SCNNode(geometry: ShapeType.createCubeShape(image: image, text: period + "\n" + specialOffer))
    boxNode.position = relativePosition
    boxNode.scale = SCNVector3(x:0.01, y:0.01, z:0.01)
    //boxNode.position.z -= 0.01
    
    let cubeNode = SCNNode()
    cubeNode.position = position
    cubeNode.look(at: pov)
    cubeNode.addChildNode(boxNode)
    cubeNode.scale = SCNVector3(x:0.4, y:0.4, z:0.4)

    let rotate = SCNAction.rotateBy(x: 0, y: 1, z: 0, duration: 5)
    rotate.timingMode = .linear
    let moveSequence = SCNAction.sequence([rotate])
    let moveLoop = SCNAction.repeatForever(moveSequence)
    cubeNode.runAction(moveLoop)
    
    return cubeNode
  }
  
  func createFootnote(position: SCNVector3, attributes: [String: String]) -> SCNNode {
    let imageBase64 = attributes["image"]!
    let dataDecoded : Data = Data(base64Encoded: imageBase64, options: .ignoreUnknownCharacters)!
    let image = UIImage(data: dataDecoded)!
    let period = attributes["period"]!
    let specialOffer = attributes["specialOffer"]!
    let pov = SCNVector3Make(Float(attributes["lookAt.x"]!)!, position.y, Float(attributes["lookAt.z"]!)!)
    
    var relativePosition = SCNVector3Make(0, 0, 0)
    let planeNode = SCNNode(geometry: ShapeType.createPlaneShape(image: image))
    planeNode.position = relativePosition
    //planeNode.position.x -= 0.22
    planeNode.position.y += 0.35
    planeNode.scale = SCNVector3(x:0.5, y:0.5, z:0.5)
    
    let bgNode = SCNNode(geometry: ShapeType.createPlaneShape(image: UIImage(named: "footnote_vertical.png")!))
    bgNode.position = relativePosition
    //planeNode.scale = SCNVector3(x:1.5, y:1.5, z:1.5)
    bgNode.position.z -= 0.01
    
    let periodNode = SCNNode(geometry: ShapeType.createFootnoteTitleShape(period: period, width: 200, size: 12))
    periodNode.scale = SCNVector3Make(0.005, 0.005, 0.005)
    relativePosition.x -= 0.5
    relativePosition.y -= 0.1
    periodNode.position = relativePosition
    
    let specialOfferNode = SCNNode(geometry: ShapeType.createFootnoteTextShape(specialOffer: specialOffer, width: 200, size: 15))
    specialOfferNode.scale = SCNVector3Make(0.005, 0.005, 0.005)
    relativePosition.y -= 0.5
    specialOfferNode.position = relativePosition
    
    let posterNode = SCNNode()
    posterNode.position = position
    //posterNode.position.x += 0.5
    posterNode.look(at: pov)
    posterNode.addChildNode(bgNode)
    posterNode.addChildNode(periodNode)
    posterNode.addChildNode(specialOfferNode)
    posterNode.addChildNode(planeNode)
    
    posterNode.scale = SCNVector3(x:0.4, y:0.4, z:0.4)
    
    return posterNode
  }
  
  func createFootnoteWithoutImage(position: SCNVector3, attributes: [String: String]) -> SCNNode {
    let period = attributes["period"]!
    let specialOffer = attributes["specialOffer"]!
    let pov = SCNVector3Make(Float(attributes["lookAt.x"]!)!, position.y, Float(attributes["lookAt.z"]!)!)
    
    var relativePosition = SCNVector3Make(0, 0, 0)
    
    let bgNode = SCNNode(geometry: ShapeType.createPlaneShape(image: UIImage(named: "footnote_vertical.png")!))
    bgNode.position = relativePosition
    //planeNode.scale = SCNVector3(x:1.5, y:1.5, z:1.5)
    bgNode.position.z -= 0.01
    
    let periodNode = SCNNode(geometry: ShapeType.createFootnoteTitleShape(period: period, width: 200, size: 15))
    periodNode.scale = SCNVector3Make(0.005, 0.005, 0.005)
    relativePosition.x -= 0.5
    relativePosition.y += 0.4
    periodNode.position = relativePosition
    
    let specialOfferNode = SCNNode(geometry: ShapeType.createFootnoteTextShape(specialOffer: specialOffer, width: 200, size: 17))
    specialOfferNode.scale = SCNVector3Make(0.005, 0.005, 0.005)
    relativePosition.y -= 0.6
    specialOfferNode.position = relativePosition
    
    let posterNode = SCNNode()
    posterNode.position = position
    //posterNode.position.x += 0.5
    posterNode.look(at: pov)
    posterNode.addChildNode(bgNode)
    posterNode.addChildNode(periodNode)
    posterNode.addChildNode(specialOfferNode)
    
    posterNode.scale = SCNVector3(x:0.4, y:0.4, z:0.4)
    
    return posterNode
  }
  
  
  func createLateralFootnoteWithoutImage(position: SCNVector3, attributes: [String: String]) -> SCNNode {
    let period = attributes["period"]!
    let specialOffer = attributes["specialOffer"]!
    let pov = SCNVector3Make(Float(attributes["lookAt.x"]!)!, position.y, Float(attributes["lookAt.z"]!)!)
    
    var relativePosition = SCNVector3Make(0, 0, 0)
    
    let bgNode = SCNNode(geometry: ShapeType.createPlaneShape(image: UIImage(named: "footnote.png")!))
    bgNode.position = relativePosition
    bgNode.position.z -= 0.01
    
    let periodNode = SCNNode(geometry: ShapeType.createLateralFootnoteTitleShape(period: period, width: 180, size: 15))
    periodNode.scale = SCNVector3Make(0.005, 0.005, 0.005)
    relativePosition.x -= 0.4
    relativePosition.y += 0.15
    periodNode.position = relativePosition
    
    let specialOfferNode = SCNNode(geometry: ShapeType.createLateralFootnoteTextShape(specialOffer: specialOffer, width: 180, size: 15))
    specialOfferNode.scale = SCNVector3Make(0.005, 0.005, 0.005)
    relativePosition.y -= 0.6
    specialOfferNode.position = relativePosition
    
    let posterNode = SCNNode()
    posterNode.position = position
    posterNode.look(at: pov)
    posterNode.addChildNode(bgNode)
    posterNode.addChildNode(periodNode)
    posterNode.addChildNode(specialOfferNode)
    
    posterNode.scale = SCNVector3(x:0.4, y:0.4, z:0.4)
    
    return posterNode
  }
  
  func createLateralFootnote(position: SCNVector3, attributes: [String: String]) -> SCNNode {
    let imageBase64 = attributes["image"]!
    let dataDecoded : Data = Data(base64Encoded: imageBase64, options: .ignoreUnknownCharacters)!
    let image = UIImage(data: dataDecoded)!
    let period = attributes["period"]!
    let specialOffer = attributes["specialOffer"]!
    let pov = SCNVector3Make(Float(attributes["lookAt.x"]!)!, position.y, Float(attributes["lookAt.z"]!)!)
    
    var relativePosition = SCNVector3Make(0, 0, 0)
    let planeNode = SCNNode(geometry: ShapeType.createPlaneShape(image: image))
    planeNode.position = relativePosition
    planeNode.position.x -= 0.22
    planeNode.scale = SCNVector3(x:0.4, y:0.4, z:0.4)
    
    let bgNode = SCNNode(geometry: ShapeType.createPlaneShape(image: UIImage(named: "footnote.png")!))
    bgNode.position = relativePosition
    //planeNode.scale = SCNVector3(x:1.5, y:1.5, z:1.5)
    bgNode.position.z -= 0.01
    
    let periodNode = SCNNode(geometry: ShapeType.createLateralFootnoteTitleShape(period: period, width: 100))
    periodNode.scale = SCNVector3Make(0.005, 0.005, 0.005)
    relativePosition.x -= 0.02
    relativePosition.y += 0.1
    periodNode.position = relativePosition
    
    let specialOfferNode = SCNNode(geometry: ShapeType.createLateralFootnoteTextShape(specialOffer: specialOffer, width: 100))
    specialOfferNode.scale = SCNVector3Make(0.005, 0.005, 0.005)
    relativePosition.y -= 0.5
    specialOfferNode.position = relativePosition
    
    let posterNode = SCNNode()
    posterNode.position = position
    //posterNode.position.x += 0.5
    posterNode.look(at: pov)
    posterNode.addChildNode(bgNode)
    posterNode.addChildNode(periodNode)
    posterNode.addChildNode(specialOfferNode)
    posterNode.addChildNode(planeNode)
    
    posterNode.scale = SCNVector3(x:0.4, y:0.4, z:0.4)
    
    return posterNode
  }
  
  func createPoster(position: SCNVector3, attributes: [String: String]) -> SCNNode {
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
    
    //posterNode.scale = SCNVector3(x:0.1, y:0.1, z:0.1)
    
    return posterNode
  }
  
  func createArrow(position: SCNVector3, attributes: [String: String]) -> SCNNode {
    let period = attributes["period"]!
    let specialOffer = attributes["specialOffer"]!
    let pov = SCNVector3Make(Float(attributes["lookAt.x"]!)!, position.y, Float(attributes["lookAt.z"]!)!)
    
    var relativePosition = SCNVector3Make(0, 0, 0)
    
    let bgNode = SCNNode(geometry: ShapeType.createPlaneShape(image: UIImage(named: "arrow.png")!))
    bgNode.position = relativePosition
    //planeNode.scale = SCNVector3(x:1.5, y:1.5, z:1.5)
    bgNode.position.z -= 0.01
    
    let periodNode = SCNNode(geometry: ShapeType.createArrowTitleShape(period: period))
    periodNode.scale = SCNVector3Make(0.005, 0.005, 0.005)
    relativePosition.x -= 0.4
    relativePosition.y += 0.05
    periodNode.position = relativePosition
    
    let specialOfferNode = SCNNode(geometry: ShapeType.createArrowTextShape(specialOffer: specialOffer))
    specialOfferNode.scale = SCNVector3Make(0.005, 0.005, 0.005)
    relativePosition.y -= 0.5
    specialOfferNode.position = relativePosition
    
    let posterNode = SCNNode()
    posterNode.position = position
    //posterNode.position.x += 0.5
    posterNode.look(at: pov)
    posterNode.addChildNode(bgNode)
    posterNode.addChildNode(periodNode)
    posterNode.addChildNode(specialOfferNode)
    
    posterNode.scale = SCNVector3(x:0.7, y:0.7, z:0.7)
    
    return posterNode
  }
  
}
