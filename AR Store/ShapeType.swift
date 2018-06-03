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
  //case Plane = 0
  case Poster = 0
  case Cube
  case LateralFootnote
  case LateralFootnoteWithoutImage
  case Footnote
  case FootnoteWithoutImage
  case Arrow
  
  static func createCubeShape(image: UIImage, text: String) -> SCNGeometry {
    let geometry = SCNBox(width: 100, height: 100, length: 100, chamferRadius: 0)
    
    let bgMaterial = SCNMaterial()
    
    let planeMaterial = SCNMaterial()
    planeMaterial.diffuse.contents = image
    planeMaterial.isDoubleSided = true
    
    let layer = CALayer()
    layer.frame = CGRect(x: 0, y: 0, width: 1000, height: 1000)
    layer.backgroundColor = UIColor.yellow.cgColor
    
    let textLayer = CATextLayer()
    textLayer.frame = layer.bounds
    let font = UIFont(name: "Futura", size: 100)
    textLayer.font = font
    textLayer.fontSize = 100
    textLayer.string = text
    textLayer.shouldRasterize = false
    
    textLayer.truncationMode = kCATruncationNone
    textLayer.isWrapped = true
    
    textLayer.alignmentMode = kCAAlignmentCenter
    textLayer.foregroundColor = UIColor.black.cgColor
    textLayer.display()
    textLayer.frame = CGRect(x: layer.bounds.origin.x + 50, y: ((layer.bounds.height - textLayer.fontSize) / 2) - 500, width: layer.bounds.width - 100, height: layer.bounds.height)
    
    layer.addSublayer(textLayer)
    let textMaterial = SCNMaterial()
    textMaterial.diffuse.contents = layer
    textMaterial.isDoubleSided = true
    
    geometry.materials = [textMaterial, planeMaterial, textMaterial, planeMaterial, bgMaterial, bgMaterial]
    
    return geometry
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
  
  static func createLateralFootnoteTitleShape(period: String, width: Int, size: CGFloat = 10) -> SCNGeometry {
    let text = SCNText(string: period, extrusionDepth: 0.02)
    let font = UIFont(name: "Futura", size: size)
    text.font = font
    text.alignmentMode = kCAAlignmentCenter
    text.firstMaterial?.diffuse.contents = UIColor.white
    text.firstMaterial?.specular.contents = UIColor.white
    text.firstMaterial?.isDoubleSided = true
    text.chamferRadius = 0.01
    text.truncationMode = kCATruncationNone
    text.isWrapped = true
    
    text.containerFrame = CGRect(origin: .zero, size: CGSize(width: width, height: 20))
    
    return text
  }
  
  static func createLateralFootnoteTextShape(specialOffer: String, width: Int, size: CGFloat = 12) -> SCNGeometry {
    let text = SCNText(string: specialOffer, extrusionDepth: 0.02)
    let font = UIFont(name: "Futura", size: size)
    text.font = font
    text.alignmentMode = kCAAlignmentLeft
    text.firstMaterial?.diffuse.contents = UIColor.white
    text.firstMaterial?.specular.contents = UIColor.white
    text.firstMaterial?.isDoubleSided = true
    text.chamferRadius = 0.01
    text.truncationMode = kCATruncationNone
    text.isWrapped = true
    
    text.containerFrame = CGRect(origin: .zero, size: CGSize(width: width, height: 100))
    
    return text
  }
  
  static func createFootnoteTitleShape(period: String, width: Int, size: CGFloat = 10) -> SCNGeometry {
    let text = SCNText(string: period, extrusionDepth: 0.02)
    let font = UIFont(name: "Futura", size: size)
    text.font = font
    text.alignmentMode = kCAAlignmentCenter
    text.firstMaterial?.diffuse.contents = UIColor.white
    text.firstMaterial?.specular.contents = UIColor.white
    text.firstMaterial?.isDoubleSided = true
    text.chamferRadius = 0.01
    text.truncationMode = kCATruncationNone
    text.isWrapped = true
    
    text.containerFrame = CGRect(origin: .zero, size: CGSize(width: width, height: 20))
    
    return text
  }
  
  static func createFootnoteTextShape(specialOffer: String, width: Int, size: CGFloat = 12) -> SCNGeometry {
    let text = SCNText(string: specialOffer, extrusionDepth: 0.02)
    let font = UIFont(name: "Futura", size: size)
    text.font = font
    text.alignmentMode = kCAAlignmentCenter
    text.firstMaterial?.diffuse.contents = UIColor.white
    text.firstMaterial?.specular.contents = UIColor.white
    text.firstMaterial?.isDoubleSided = true
    text.chamferRadius = 0.01
    text.truncationMode = kCATruncationNone
    text.isWrapped = true
    
    text.containerFrame = CGRect(origin: .zero, size: CGSize(width: width, height: 100))
    
    return text
  }
  
  static func createArrowTitleShape(period: String) -> SCNGeometry {
    let text = SCNText(string: period, extrusionDepth: 0.02)
    let font = UIFont(name: "Futura", size: 10)
    text.font = font
    text.alignmentMode = kCAAlignmentLeft
    text.firstMaterial?.diffuse.contents = UIColor.black
    text.firstMaterial?.specular.contents = UIColor.black
    text.firstMaterial?.isDoubleSided = true
    text.chamferRadius = 0.01
    text.truncationMode = kCATruncationNone
    text.isWrapped = true
    
    text.containerFrame = CGRect(origin: .zero, size: CGSize(width: 200, height: 20))
    
    return text
  }
  
  static func createArrowTextShape(specialOffer: String) -> SCNGeometry {
    let text = SCNText(string: specialOffer, extrusionDepth: 0.02)
    let font = UIFont(name: "Futura", size: 12)
    text.font = font
    text.alignmentMode = kCAAlignmentLeft
    text.firstMaterial?.diffuse.contents = UIColor.black
    text.firstMaterial?.specular.contents = UIColor.black
    text.firstMaterial?.isDoubleSided = true
    text.chamferRadius = 0.01
    text.truncationMode = kCATruncationNone
    text.isWrapped = true
    
    text.containerFrame = CGRect(origin: .zero, size: CGSize(width: 200, height: 100))
    
    return text
  }
}

