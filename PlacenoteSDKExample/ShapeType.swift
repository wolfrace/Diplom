//
//  ShapeType.swift
//  Shape Dropper (Placenote SDK iOS Sample)
//
//  Created by Prasenjit Mukherjee on 2017-08-27.
//  Copyright © 2017 Vertical AI. All rights reserved.
//

import Foundation
import SceneKit

public enum ShapeType:Int {
  
  case Box = 0
  case Sphere
  case Pyramid
  case Torus
  case Capsule
  case Cylinder
  case Cone
  case Tube
  case Plane
  
  static func random() -> ShapeType {
    let maxValue = Tube.rawValue
    let rand = arc4random_uniform(UInt32(maxValue+1))
    return ShapeType(rawValue: Int(rand))!
  }
  
  static func createPlaneShape(image: UIImage) -> SCNGeometry {
    let imageRatio = image.size.height / image.size.width
    let desiredPlaneWidth: CGFloat = 1
    
    let geometry = SCNPlane(width: desiredPlaneWidth, height: desiredPlaneWidth * imageRatio)
    let planeMaterial = SCNMaterial()
    planeMaterial.diffuse.contents = image
    planeMaterial.isDoubleSided = true
    geometry.firstMaterial = planeMaterial
    
    return geometry
  }
  
  static func createPeriodTextShape(period: String) -> SCNGeometry {
    let text = SCNText(string: period, extrusionDepth: 0.02)
    let font = UIFont(name: "Futura", size: 10)
    text.font = font
    text.alignmentMode = kCAAlignmentLeft
    text.firstMaterial?.diffuse.contents = UIColor.yellow
    text.firstMaterial?.specular.contents = UIColor.white
    text.firstMaterial?.isDoubleSided = true
    text.chamferRadius = 0.01
    text.truncationMode = kCATruncationNone
    text.isWrapped = true
    
    text.containerFrame = CGRect(origin: .zero, size: CGSize(width: 200, height: 20))
    
    return text
  }
  
  static func createSpecialOfferTextShape(specialOffer: String) -> SCNGeometry {
    let text = SCNText(string: specialOffer, extrusionDepth: 0.02)
    let font = UIFont(name: "Futura", size: 15)
    text.font = font
    text.alignmentMode = kCAAlignmentLeft
    text.firstMaterial?.diffuse.contents = UIColor.red
    text.firstMaterial?.specular.contents = UIColor.white
    text.firstMaterial?.isDoubleSided = true
    text.chamferRadius = 0.01
    text.truncationMode = kCATruncationNone
    text.isWrapped = true
    
    text.containerFrame = CGRect(origin: .zero, size: CGSize(width: 200.0, height: 100))
    
    return text
  }
  
  static func generateGeometry(s_type:ShapeType) -> SCNGeometry {
    
    let geometry: SCNGeometry
    
    switch s_type {
    case ShapeType.Sphere: //
      geometry = SCNSphere(radius: 1.0)
    case ShapeType.Capsule:
      geometry = SCNCapsule(capRadius:0.5, height:1.0)
    case ShapeType.Cone:
      geometry = SCNCone(topRadius:0, bottomRadius:0.5, height:1.0)
    case ShapeType.Cylinder:
      geometry = SCNCylinder(radius:0.5, height:1.0)
    case ShapeType.Pyramid:
      geometry = SCNPyramid(width:1.0, height:1.0, length:1.0)
    case ShapeType.Torus:
      geometry = SCNTorus(ringRadius:1.0, pipeRadius:0.1)
    case ShapeType.Plane:
      geometry = SCNPlane(width:1.0, height:1.0)
    case ShapeType.Box: //
      fallthrough
    default:
      geometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.1)
    }
    
    return geometry
  }
}

