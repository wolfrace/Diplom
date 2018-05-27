//
//  ViewController.swift
//  Shape Dropper (Placenote SDK iOS Sample)
//
//  Created by Prasenjit Mukherjee on 2017-09-01.
//  Copyright © 2017 Vertical AI. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import SceneKit
import ARKit
import PlacenoteSDK

class ViewController
  : UIViewController
  , UIImagePickerControllerDelegate
  , UINavigationControllerDelegate
  , ARSCNViewDelegate
  , ARSessionDelegate
  , UITableViewDelegate
  , UITableViewDataSource
  , PNDelegate
  , CLLocationManagerDelegate {


  //UI Elements
  @IBOutlet var scnView: ARSCNView!

  @IBOutlet var mapTable: UITableView!
  @IBOutlet var newMapButton: RoundButton!
  @IBOutlet var pickMapButton: RoundButton!
  @IBOutlet var statusLabel: DarkLabel!
  @IBOutlet var fileTransferLabel: UILabel!
  
  //AR Scene
  private var scnScene: SCNScene!

  //Status variables to track the state of the app with respect to libPlacenote
  private var trackingStarted: Bool = false;
  private var mappingStarted: Bool = false;
  private var mappingComplete: Bool = false;
  private var localizationStarted: Bool = false;
  private var reportDebug: Bool = false

  //Application related variables
  private var shapeManager: ShapeManager!
  private var tapRecognizer: UITapGestureRecognizer? = nil //initialized after view is loaded


  //Variables to manage PlacenoteSDK features and helpers
  private var maps: [(String, [String: Any]?)] = [("Sample Map", [:])]
  private var camManager: CameraManager? = nil;
  private var ptViz: FeaturePointVisualizer? = nil;
  private var planesVizAnchors = [ARAnchor]();
  private var planesVizNodes = [UUID: SCNNode]();
  
  private var showFeatures: Bool = true
  private var planeDetection: Bool = true

  private var locationManager: CLLocationManager!
  private var lastLocation: CLLocation? = nil

  private var pose: SCNVector3!
  private var shapeType: ShapeType!
  
  //Setup view once loaded
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    setupScene()

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = appDelegate.persistentContainer.viewContext
    
    //App Related initializations
    shapeManager = ShapeManager(scene: scnScene, view: scnView, dbObjectContext: context)
    tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
    tapRecognizer!.numberOfTapsRequired = 1
    tapRecognizer!.isEnabled = false
    scnView.addGestureRecognizer(tapRecognizer!)

    //IMPORTANT: need to run this line to subscribe to pose and status events
    //Declare yourself to be one of the delegates of PNDelegate to receive pose and status updates
    LibPlacenote.instance.multiDelegate += self;

    //Initialize tableview for the list of maps
    mapTable.delegate = self
    mapTable.dataSource = self
    mapTable.allowsSelection = true
    mapTable.isUserInteractionEnabled = true
    mapTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

    //UI Updates
    newMapButton.isEnabled = false
    
    locationManager = CLLocationManager()
    locationManager.requestWhenInUseAuthorization()

    if CLLocationManager.locationServicesEnabled() {
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        locationManager.startUpdatingLocation()
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  //Initialize view and scene
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    configureSession();
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    // Pause the view's session
    scnView.session.pause()
  }

  //Function to setup the view and setup the AR Scene including options
  func setupView() {
    scnView = self.view as! ARSCNView
    scnView.showsStatistics = true
    scnView.autoenablesDefaultLighting = true
    scnView.delegate = self
    scnView.session.delegate = self
    scnView.isPlaying = true
    scnView.debugOptions = []
    mapTable.isHidden = true //hide the map list until 'Load Map' is clicked
  }

  //Function to setup AR Scene
  func setupScene() {
    scnScene = SCNScene()
    scnView.scene = scnScene
    ptViz = FeaturePointVisualizer(inputScene: scnScene);
    ptViz?.enableFeaturePoints()

    if let camera: SCNNode = scnView?.pointOfView {
      camManager = CameraManager(scene: scnScene, cam: camera)
    }
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    scnView.frame = view.bounds
  }

  // MARK: - PNDelegate functions

  //Receive a pose update when a new pose is calculated
  func onPose(_ outputPose: matrix_float4x4, _ arkitPose: matrix_float4x4) -> Void {
  }

  //Receive a status update when the status changes
  func onStatusChange(_ prevStatus: LibPlacenote.MappingStatus, _ currStatus: LibPlacenote.MappingStatus) {
    if prevStatus != LibPlacenote.MappingStatus.running && currStatus == LibPlacenote.MappingStatus.running { //just localized draw shapes you've retrieved
      print ("Just localized, drawing view")
      shapeManager.drawView(parent: scnScene.rootNode) //just localized redraw the shapes
      if mappingStarted {
       statusLabel.text = "Tap anywhere to add Shapes, Move Slowly"
      }
      else if localizationStarted {
        statusLabel.text = "Map Found!"
      }
      tapRecognizer?.isEnabled = true
      
      //As you are localized, the camera has been moved to match that of Placenote's Map. Transform the planes
      //currently being drawn from the arkit frame of reference to the Placenote map's frame of reference.
      for (_, node) in planesVizNodes {
        node.transform = LibPlacenote.instance.processPose(pose: node.transform);
      }
    }

    if prevStatus == LibPlacenote.MappingStatus.running && currStatus != LibPlacenote.MappingStatus.running { //just lost localization
      print ("Just lost")
      if mappingStarted {
        statusLabel.text = "Moved too fast. Map Lost"
      }
      tapRecognizer?.isEnabled = false
    }

  }

  //Receive list of maps after it is retrieved. This is only fired when fetchMapList is called (see updateMapTable())
  func onMapList(success: Bool, mapList: [String: Any]) -> Void {
    maps.removeAll()
    if (!success) {
      print ("failed to fetch map list")
      statusLabel.text = "Map List not retrieved"
      return
    }

    print ("map List received")
    for place in mapList {
      maps.append((place.key, place.value as? [String: Any]))
      print ("place:" + place.key + ", metadata: ")
      print (place.value)
    }

    statusLabel.text = "Map List"
    self.mapTable.reloadData() //reads from maps array (see: tableView functions)
    self.mapTable.isHidden = false
    self.tapRecognizer?.isEnabled = false
  }

  // MARK: - UI functions

  @IBAction func newSaveMapButton(_ sender: Any) {
    if (trackingStarted && !mappingStarted) { //ARKit is enabled, start mapping
      print ("New Map")
      mappingStarted = true
      
      LibPlacenote.instance.stopSession()
      LibPlacenote.instance.startSession()
      
      if (reportDebug) {
        LibPlacenote.instance.startReportRecord(uploadProgressCb: {(completed: Bool, faulted: Bool, percentage: Float) -> Void in
          if (completed) {
            self.statusLabel.text = "Dataset Upload Complete"
            self.fileTransferLabel.text = ""
          } else if (faulted) {
            self.statusLabel.text = "Dataset Upload Faulted"
            self.fileTransferLabel.text = ""
          } else {
            self.fileTransferLabel.text = "Dataset Upload: " + String(format: "%.3f", percentage) + "/1.0"
          }
        })
        print ("Started Debug Report")
      }

      localizationStarted = false
      pickMapButton.setTitle("Load Map", for: .normal)
      newMapButton.setTitle("Save Map", for: .normal)
      statusLabel.text = "Mapping: Tap to add shapes!"
      tapRecognizer?.isEnabled = true
      mapTable.isHidden = true
      shapeManager.clearShapes() //creating new map, remove old shapes.
    }
    else if (mappingStarted) { //mapping been running, save map
      print("Saving Map")
      statusLabel.text = "Saving Map"
      mappingStarted = false
      mappingComplete = true
      saveMap()
      newMapButton.setTitle("New Map", for: .normal)
      tapRecognizer?.isEnabled = false
    }
  }
  
  @IBAction func pickMap(_ sender: Any) {
    if (localizationStarted) { // currently a map is loaded. StopSession and clearView
      shapeManager.clearShapes()
      ptViz?.reset()
      LibPlacenote.instance.stopSession()
      localizationStarted = false
      pickMapButton.setTitle("Load Map", for: .normal)
      statusLabel.text = "Cleared"
      planeDetection = false
      configureSession()
      return
    }
    
    if (mapTable.isHidden) { //fetch map list and show table of maps
      updateMapTable()
      pickMapButton.setTitle("Cancel", for: .normal)
      newMapButton.isEnabled = false
      statusLabel.text = "Fetching Map List"

    }
    else { //map load/localization session cancelled
      mapTable.isHidden = true
      pickMapButton.setTitle("Load Map", for: .normal)
      newMapButton.isEnabled = true
      statusLabel.text = "Map Load cancelled"
    }
  }

  @IBAction func onShowFeatureChange(_ sender: Any) {
    showFeatures = !showFeatures
    if (showFeatures) {
      ptViz?.enableFeaturePoints()
    }
    else {
      ptViz?.disableFeaturePoints()
    }
  }
  
  func configureSession() {
    // Create a session configuration
    let configuration = ARWorldTrackingConfiguration()
    configuration.worldAlignment = ARWorldTrackingConfiguration.WorldAlignment.gravity //TODO: Maybe not heading?
    
    if (planeDetection) {
      if #available(iOS 11.3, *) {
        configuration.planeDetection = [.horizontal, .vertical]
      } else {
        configuration.planeDetection = [.horizontal]
      }
    }
    else {
      for (_, node) in planesVizNodes {
        node.removeFromParentNode()
      }
      for (anchor) in planesVizAnchors { //remove anchors because in iOS versions <11.3, the anchors are not automatically removed when plane detection is turned off.
        scnView.session.remove(anchor: anchor)
      }
      planesVizNodes.removeAll()
      configuration.planeDetection = []
    }
    // Run the view's session
    scnView.session.run(configuration)
  }
  

  // MARK: - UITableViewDelegate and UITableviewDataSource to manage retrieving, viewing, deleting and selecting maps on a TableView

  //Return count of maps
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    print(String(format: "Map size: %d", maps.count))
    return maps.count
  }

  //Label Map rows
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let map = self.maps[indexPath.row]
    var cell:UITableViewCell? = mapTable.dequeueReusableCell(withIdentifier: map.0)
    if cell==nil {
      cell =  UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: map.0)
    }
    cell?.textLabel?.text = map.0

    var subtitle = "Distance Unknown"

    var location = map.1?["location"] as? [String: Any]

    if (lastLocation == nil) {
        subtitle = "User location unknown"
    } else if (location == nil) {
        subtitle = "Map location unknown"
    } else {
        let distance = lastLocation!.distance(from: CLLocation(
            latitude: location!["latitude"] as! Double,
            longitude: location!["longitude"] as! Double))
        subtitle = String(format: "Distance: %0.3fkm", distance / 1000)
    }

    cell?.detailTextLabel?.text = subtitle

    return cell!
  }
  
  //Map selected
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    print(String(format: "Retrieving row: %d", indexPath.row))
    print("Retrieving mapId: " + maps[indexPath.row].0)
    statusLabel.text = "Retrieving mapId: " + maps[indexPath.row].0

    loadMap(mapId: maps[indexPath.row].0, data: maps[indexPath.row].1)
  }

  //Make rows editable for deletion
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }

  //Delete Row and its corresponding map
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if (editingStyle == UITableViewCellEditingStyle.delete) {
      statusLabel.text = "Deleting Map:" + maps[indexPath.row].0
      LibPlacenote.instance.deleteMap(mapId: maps[indexPath.row].0, deletedCb: {(deleted: Bool) -> Void in
        if (deleted) {
          print("Deleting: " + self.maps[indexPath.row].0)
          self.statusLabel.text = "Deleted Map: " + self.maps[indexPath.row].0
          self.maps.remove(at: indexPath.row)
          self.mapTable.reloadData()
        }
        else {
          print ("Can't Delete: " + self.maps[indexPath.row].0)
          self.statusLabel.text = "Can't Delete: " + self.maps[indexPath.row].0
        }
      })
    }
  }

  func updateMapTable() {
    LibPlacenote.instance.fetchMapList(listCb: onMapList)
  }

  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
    
    dismiss(animated: false, completion: {
      switch self.shapeType! {
      case ShapeType.Poster:
        self.fillPosterAttributes(image: chosenImage)
        //
      case ShapeType.Cube:
        self.fillCubeAttributes(image: chosenImage)
        //
      case ShapeType.Footnote:
        self.fillFootnoteAttributes(image: chosenImage)
        //
      case ShapeType.LateralFootnote:
        self.fillLateralFootnoteAttributes(image: chosenImage)
        //
      case .LateralFootnoteWithoutImage: break
      case .FootnoteWithoutImage: break
      case .Arrow: break
      }
    })
  }
  
  private func fillPosterAttributes(image: UIImage) {
    if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "PosterAttributesEditorViewController") {
      viewController.modalPresentationStyle = .overFullScreen
      let posterAttributesEditorViewController = viewController as! PosterAttributesEditorViewController
      posterAttributesEditorViewController.doOnEditFinished { [weak self] (period: String, specialOffer: String) in
        self?.shapeManager.spawnPoster(position: self!.pose, image: image, period: period, specialOffer: specialOffer)
      }
      self.present(viewController, animated: false, completion: nil)
    }
  }
  
  private func fillCubeAttributes(image: UIImage) {
    if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "PosterAttributesEditorViewController") {
      viewController.modalPresentationStyle = .overFullScreen
      let posterAttributesEditorViewController = viewController as! PosterAttributesEditorViewController
      posterAttributesEditorViewController.doOnEditFinished { [weak self] (period: String, specialOffer: String) in
        self?.shapeManager.spawnCube(position: self!.pose, image: image, period: period, specialOffer: specialOffer)
      }
      self.present(viewController, animated: false, completion: nil)
    }
  }
  
  private func fillFootnoteAttributes(image: UIImage) {
    if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "PosterAttributesEditorViewController") {
      viewController.modalPresentationStyle = .overFullScreen
      let posterAttributesEditorViewController = viewController as! PosterAttributesEditorViewController
      posterAttributesEditorViewController.doOnEditFinished { [weak self] (period: String, specialOffer: String) in
        self?.shapeManager.spawnFootnote(position: self!.pose, image: image, period: period, specialOffer: specialOffer)
      }
      self.present(viewController, animated: false, completion: nil)
    }
  }
  
  private func fillFootnoteWithoutImageAttributes() {
    if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "PosterAttributesEditorViewController") {
      viewController.modalPresentationStyle = .overFullScreen
      let posterAttributesEditorViewController = viewController as! PosterAttributesEditorViewController
      posterAttributesEditorViewController.doOnEditFinished { [weak self] (period: String, specialOffer: String) in
        self?.shapeManager.spawnFootnoteWithoutImage(position: self!.pose, period: period, specialOffer: specialOffer)
      }
      self.present(viewController, animated: false, completion: nil)
    }
  }
  
  private func fillLateralFootnoteAttributes(image: UIImage) {
    if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "PosterAttributesEditorViewController") {
      viewController.modalPresentationStyle = .overFullScreen
      let posterAttributesEditorViewController = viewController as! PosterAttributesEditorViewController
      posterAttributesEditorViewController.doOnEditFinished { [weak self] (period: String, specialOffer: String) in
        self?.shapeManager.spawnLateralFootnote(position: self!.pose, image: image, period: period, specialOffer: specialOffer)
      }
      self.present(viewController, animated: false, completion: nil)
    }
  }
  
  private func fillLateralFootnoteWithoutImageAttributes() {
    if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "PosterAttributesEditorViewController") {
      viewController.modalPresentationStyle = .overFullScreen
      let posterAttributesEditorViewController = viewController as! PosterAttributesEditorViewController
      posterAttributesEditorViewController.doOnEditFinished { [weak self] (period: String, specialOffer: String) in
        self?.shapeManager.spawnLateralFootnoteWithoutImage(position: self!.pose, period: period, specialOffer: specialOffer)
      }
      self.present(viewController, animated: false, completion: nil)
    }
  }
  
  private func fillArrowAttributes() {
    if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "PosterAttributesEditorViewController") {
      viewController.modalPresentationStyle = .overFullScreen
      let posterAttributesEditorViewController = viewController as! PosterAttributesEditorViewController
      posterAttributesEditorViewController.doOnEditFinished { [weak self] (period: String, specialOffer: String) in
        self?.shapeManager.spawnArrow(position: self!.pose, period: period, specialOffer: specialOffer)
      }
      self.present(viewController, animated: false, completion: nil)
    }
  }
  
  @objc func handleTap(sender: UITapGestureRecognizer) {
    let tapLocation = sender.location(in: scnView)
    let hitTestResults = scnView.hitTest(tapLocation, types: .featurePoint)
    if let result = hitTestResults.first {
      let pose = LibPlacenote.instance.processPose(pose: result.worldTransform)
      
      let alert = UIAlertController(title: "Choose shape", message: nil, preferredStyle: .actionSheet)
      let addPoster = UIAlertAction(title: "Poster", style: .default) { [weak self] action in
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .savedPhotosAlbum
        self?.pose = pose.position()
        self?.shapeType = ShapeType.Poster
        self?.present(imagePicker, animated:true, completion: nil)
      }
      let addCube = UIAlertAction(title: "Cube", style: .default) { [weak self] action in
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .savedPhotosAlbum
        self?.pose = pose.position()
        self?.shapeType = ShapeType.Cube
        self?.present(imagePicker, animated:true, completion: nil)
      }
      let addLateralFootnote = UIAlertAction(title: "Lateral Footnote with image", style: .default) { [weak self] action in
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .savedPhotosAlbum
        self?.pose = pose.position()
        self?.shapeType = ShapeType.LateralFootnote
        self?.present(imagePicker, animated:true, completion: nil)
      }
      let addLateralFootnoteWithoutImage = UIAlertAction(title: "Lateral Footnote", style: .default) { [weak self] action in
        self?.pose = pose.position()
        self?.shapeType = ShapeType.LateralFootnoteWithoutImage
        self?.fillLateralFootnoteWithoutImageAttributes()
      }
      let addFootnote = UIAlertAction(title: "Footnote with image", style: .default) { [weak self] action in
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .savedPhotosAlbum
        self?.pose = pose.position()
        self?.shapeType = ShapeType.Footnote
        self?.present(imagePicker, animated:true, completion: nil)
      }
      let addFootnoteWithoutImage = UIAlertAction(title: "Footnote", style: .default) { [weak self] action in
        self?.pose = pose.position()
        self?.shapeType = ShapeType.FootnoteWithoutImage
        self?.fillFootnoteWithoutImageAttributes()
      }
      let addArrow = UIAlertAction(title: "Arrow", style: .default) { [weak self] action in
        self?.pose = pose.position()
        self?.shapeType = ShapeType.Arrow
        self?.fillArrowAttributes()
      }
      let addCancel = UIAlertAction(title: "Cancel", style: .default) { [] action in
        // do nothing
      }
      alert.addAction(addPoster)
      alert.addAction(addCube)
      alert.addAction(addLateralFootnote)
      alert.addAction(addLateralFootnoteWithoutImage)
      alert.addAction(addFootnote)
      alert.addAction(addFootnoteWithoutImage)
      alert.addAction(addArrow)
      
      alert.addAction(addCancel)
      
      self.present(alert, animated: true, completion: nil)
    }
  }
  
  // MARK: - ARSCNViewDelegate

  // Override to create and configure nodes for anchors added to the view's session.
  func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
    let node = SCNNode()
    return node
  }
  
  func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
    
    // Create a SceneKit plane to visualize the plane anchor using its position and extent.
    let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
    let planeNode = SCNNode(geometry: plane)
    planeNode.simdPosition = float3(planeAnchor.center.x, 0, planeAnchor.center.z)
    
    node.transform = LibPlacenote.instance.processPose(pose: node.transform); //transform through
    planesVizNodes[anchor.identifier] = node; //keep track of plane nodes so you can move them once you localize to a new map.
    
    /*
     `SCNPlane` is vertically oriented in its local coordinate space, so
     rotate the plane to match the horizontal orientation of `ARPlaneAnchor`.
     */
    planeNode.eulerAngles.x = -.pi / 2
    
    // Make the plane visualization semitransparent to clearly show real-world placement.
    planeNode.opacity = 0.25
    
    /*
     Add the plane visualization to the ARKit-managed node so that it tracks
     changes in the plane anchor as plane estimation continues.
     */
    node.addChildNode(planeNode)
  }
  
  func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
    // Update content only for plane anchors and nodes matching the setup created in `renderer(_:didAdd:for:)`.
    guard let planeAnchor = anchor as?  ARPlaneAnchor,
      let planeNode = node.childNodes.first,
      let plane = planeNode.geometry as? SCNPlane
      else { return }
    
    // Plane estimation may shift the center of a plane relative to its anchor's transform.
    planeNode.simdPosition = float3(planeAnchor.center.x, 0, planeAnchor.center.z)
    
    /*
     Plane estimation may extend the size of the plane, or combine previously detected
     planes into a larger one. In the latter case, `ARSCNView` automatically deletes the
     corresponding node for one plane, then calls this method to update the size of
     the remaining plane.
     */
    plane.width = CGFloat(planeAnchor.extent.x)
    plane.height = CGFloat(planeAnchor.extent.z)
    
    node.transform = LibPlacenote.instance.processPose(pose: node.transform)
  }

  // MARK: - ARSessionDelegate

  //Provides a newly captured camera image and accompanying AR information to the delegate.
  func session(_ session: ARSession, didUpdate: ARFrame) {
    let image: CVPixelBuffer = didUpdate.capturedImage
    let pose: matrix_float4x4 = didUpdate.camera.transform

    if (!LibPlacenote.instance.initialized()) {
      print("SDK is not initialized")
      return
    }

    if (mappingStarted || localizationStarted) {
      LibPlacenote.instance.setFrame(image: image, pose: pose)
    }
  }


  //Informs the delegate of changes to the quality of ARKit's device position tracking.
  func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
    var status = "Loading.."
    switch camera.trackingState {
    case ARCamera.TrackingState.notAvailable:
      status = "Not available"
    case ARCamera.TrackingState.limited(.excessiveMotion):
      status = "Excessive Motion."
    case ARCamera.TrackingState.limited(.insufficientFeatures):
      status = "Insufficient features"
    case ARCamera.TrackingState.limited(.initializing):
      status = "Initializing"
    case ARCamera.TrackingState.limited(.relocalizing):
      status = "Relocalizing"
    case ARCamera.TrackingState.normal:
      if (!trackingStarted) {
        trackingStarted = true
        print("ARKit Enabled, Start Mapping")
        newMapButton.isEnabled = true
        newMapButton.setTitle("New Map", for: .normal)
      }
      status = "Ready"
    }
    statusLabel.text = status
  }
  
  func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
    for (anchor) in anchors {
      planesVizAnchors.append(anchor)
    }
  }

  // MARK: - CLLocationManagerDelegate

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    lastLocation = locations.last
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    let touch = touches.first!
    if let hit = scnView.hitTest(touch.location(in: scnView), options: nil).first {
      if let shape = shapeManager.findShape(node: hit.node) {
        let alert = UIAlertController(title: "Choose action", message: nil, preferredStyle: .actionSheet)
        let editAction = UIAlertAction(title: "Edit", style: .default) { [weak self] action in
          var attributes = self?.shapeManager.getShapeAttributes(node: shape)!
          
          if let viewController = self?.storyboard?.instantiateViewController(withIdentifier: "PosterAttributesEditorViewController") {
            viewController.modalPresentationStyle = .overFullScreen
            let posterAttributesEditorViewController = viewController as! PosterAttributesEditorViewController
            posterAttributesEditorViewController.initData(period: attributes!["period"]!, specialOffer: attributes!["specialOffer"]!)
            posterAttributesEditorViewController.doOnEditFinished { [weak self] (period: String, specialOffer: String) in
              attributes!["period"] = period
              attributes!["specialOffer"] = specialOffer
              self?.shapeManager.updateShapeAttributes(node: shape, attributes: attributes!)
            }
            self?.present(viewController, animated: false, completion: nil)
          }
        }
        let deleteAction = UIAlertAction(title: "Delete", style: .default) { [weak self] action in
          self?.shapeManager.deleteShape(node: shape)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { [] action in
          // do nothing
        }
        alert.addAction(editAction)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
      }
    }
  }
  
  ////////////////////////////////////////
  
  func saveMap() {
    LibPlacenote.instance.saveMap(
      savedCb: {(mapId: String?) -> Void in
        if (mapId != nil) {
          self.statusLabel.text = "Saved Id: " + mapId! //update UI
          LibPlacenote.instance.stopSession()
          
          var metadata: [String: Any] = [:]
          if (self.lastLocation != nil) {
            metadata["location"] = ["latitude": self.lastLocation!.coordinate.latitude,
                                    "longitude": self.lastLocation!.coordinate.longitude,
                                    "altitude": self.lastLocation!.altitude]
          }
          metadata["shapeArray"] = self.shapeManager.getShapeArray()
          
          let jsonData = try? JSONSerialization.data(withJSONObject: metadata)
          let jsonString = String.init(data: jsonData!, encoding: String.Encoding.utf8)
          if (!LibPlacenote.instance.setMapMetadata(mapId: mapId!, metadataJson: jsonString!)) {
            print ("Failed to set map metadata")
          }
          self.planeDetection = false
          self.configureSession()
        } else {
          NSLog("Failed to save map")
        }
    },
      uploadProgressCb: {(completed: Bool, faulted: Bool, percentage: Float) -> Void in
        if (completed) {
          print ("Uploaded!")
          self.fileTransferLabel.text = ""
        } else if (faulted) {
          print ("Couldnt upload map")
        } else {
          print ("Progress: " + percentage.description)
          self.fileTransferLabel.text = "Map Upload: " + String(format: "%.3f", percentage) + "/1.0"
        }
    }
    )
  }
  
  func loadMap(mapId: String, data: [String: Any]?) {
    LibPlacenote.instance.loadMap(mapId: mapId,
      downloadProgressCb: {(completed: Bool, faulted: Bool, percentage: Float) -> Void in
        if (completed) {
          self.mappingStarted = false
          self.mappingComplete = false
          self.localizationStarted = true
          self.mapTable.isHidden = true
          self.pickMapButton.setTitle("Stop/Clear", for: .normal)
          self.newMapButton.isEnabled = true
          
          if (self.shapeManager.loadShapeArray(shapeArray: data?["shapeArray"] as? [[String: [String: String]]])) {
            self.statusLabel.text = "Map Loaded. Look Around"
          }
          else {
            self.statusLabel.text = "Map Loaded. Shape file not found"
          }
          LibPlacenote.instance.startSession()
          
          if (self.reportDebug) {
            LibPlacenote.instance.startReportRecord (uploadProgressCb: ({(completed: Bool, faulted: Bool, percentage: Float) -> Void in
              if (completed) {
                self.statusLabel.text = "Dataset Upload Complete"
                self.fileTransferLabel.text = ""
              } else if (faulted) {
                self.statusLabel.text = "Dataset Upload Faulted"
                self.fileTransferLabel.text = ""
              } else {
                self.fileTransferLabel.text = "Dataset Upload: " + String(format: "%.3f", percentage) + "/1.0"
              }
            })
            )
            print ("Started Debug Report")
          }
          
          self.tapRecognizer?.isEnabled = true
        } else if (faulted) {
          print ("Couldnt load map: " + mapId)
          self.statusLabel.text = "Load error Map Id: " +  mapId
        } else {
          print ("Progress: " + percentage.description)
        }
    }
    )
  }
  
}

