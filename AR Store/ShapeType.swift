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
  
  case Plane = 0
  case InformationTable // информационная доска
  case Poster // постер
  case Tag // бирка
  case LateralFootnote // боковая выноска
  
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
  
  static func createInformationTableBgShape() -> SCNGeometry {
    let geometry = SCNPlane(width: 1, height: 2)
    let planeMaterial = SCNMaterial()
    geometry.firstMaterial = planeMaterial
    geometry.firstMaterial!.isDoubleSided = true
    geometry.firstMaterial!.diffuse.contents = UIColor.red.cgColor
    
    return geometry
  }
  
  static func createPosterShape(image: UIImage) -> SCNGeometry {
    let imageRatio = image.size.height / image.size.width
    let desiredPlaneWidth: CGFloat = 1
    
    let geometry = SCNPlane(width: desiredPlaneWidth, height: desiredPlaneWidth * imageRatio)
    let planeMaterial = SCNMaterial()
    planeMaterial.diffuse.contents = image
    planeMaterial.isDoubleSided = true
    geometry.firstMaterial = planeMaterial
    
    return geometry
  }
  
  static func createTagShape(image: UIImage) -> SCNGeometry {
    let imageRatio = image.size.height / image.size.width
    let desiredPlaneWidth: CGFloat = 1
    
    let geometry = SCNPlane(width: desiredPlaneWidth, height: desiredPlaneWidth * imageRatio)
    let planeMaterial = SCNMaterial()
    planeMaterial.diffuse.contents = image
    planeMaterial.isDoubleSided = true
    geometry.firstMaterial = planeMaterial
    
    return geometry
  }
  
  static func createLateralFootnoteShape(image: UIImage) -> SCNGeometry {
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
  
  static func createInformationTableTitleShape(period: String) -> SCNGeometry {
    let text = SCNText(string: period, extrusionDepth: 0.02)
    let font = UIFont(name: "Futura", size: 10)
    text.font = font
    text.alignmentMode = kCAAlignmentCenter
    text.firstMaterial?.diffuse.contents = UIColor.white
    text.firstMaterial?.specular.contents = UIColor.white
    text.firstMaterial?.isDoubleSided = true
    text.chamferRadius = 0.01
    text.truncationMode = kCATruncationNone
    text.isWrapped = true
    
    text.containerFrame = CGRect(origin: .zero, size: CGSize(width: 100, height: 20))
    
    return text
  }
  
  static func createInformationTableTextShape(specialOffer: String) -> SCNGeometry {
    let text = SCNText(string: specialOffer, extrusionDepth: 0.02)
    let font = UIFont(name: "Futura", size: 15)
    text.font = font
    text.alignmentMode = kCAAlignmentCenter
    text.firstMaterial?.diffuse.contents = UIColor.white
    text.firstMaterial?.specular.contents = UIColor.white
    text.firstMaterial?.isDoubleSided = true
    text.chamferRadius = 0.01
    text.truncationMode = kCATruncationNone
    text.isWrapped = true
    
    text.containerFrame = CGRect(origin: .zero, size: CGSize(width: 100.0, height: 100))
    
    return text
  }
  
  static func createLateralFootnoteTitleShape(period: String) -> SCNGeometry {
    let text = SCNText(string: period, extrusionDepth: 0.02)
    let font = UIFont(name: "Futura", size: 10)
    text.font = font
    text.alignmentMode = kCAAlignmentLeft
    text.firstMaterial?.diffuse.contents = UIColor.white
    text.firstMaterial?.specular.contents = UIColor.white
    text.firstMaterial?.isDoubleSided = true
    text.chamferRadius = 0.01
    text.truncationMode = kCATruncationNone
    text.isWrapped = true
    
    text.containerFrame = CGRect(origin: .zero, size: CGSize(width: 100, height: 20))
    
    return text
  }
  
  static func createLateralFootnoteTextShape(specialOffer: String) -> SCNGeometry {
    let text = SCNText(string: specialOffer, extrusionDepth: 0.02)
    let font = UIFont(name: "Futura", size: 12)
    text.font = font
    text.alignmentMode = kCAAlignmentLeft
    text.firstMaterial?.diffuse.contents = UIColor.white
    text.firstMaterial?.specular.contents = UIColor.white
    text.firstMaterial?.isDoubleSided = true
    text.chamferRadius = 0.01
    text.truncationMode = kCATruncationNone
    text.isWrapped = true
    
    text.containerFrame = CGRect(origin: .zero, size: CGSize(width: 100.0, height: 100))
    
    return text
  }
}

