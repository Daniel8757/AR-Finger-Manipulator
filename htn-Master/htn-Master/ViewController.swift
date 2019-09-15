//
//  ViewController.swift
//  htn-Master
//
//  Created by Dan Li on 2019-09-14.
//  Copyright © 2019 Dan Li. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import SwiftSocket
import Foundation

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var client = UDPServer(address: "10.33.130.134", port: 5200)
    var fingerLoc = [0, 0]
    var counter = 0
    
    @objc func updateStuff() {
        var a = [UInt8]()
        a.append(0)
        a.append(0)
        let (byteArray, senderIPAddress, senderPort) = client.recv(1024)
        let string = String(bytes: byteArray ?? a , encoding: .utf8)
        var fingerLoc = string?.components(separatedBy: ",")
        fingerLoc![0] = fingerLoc![0].replacingOccurrences(of:"[", with: "")
        fingerLoc![0] = fingerLoc![0].replacingOccurrences(of:"\"", with: "")
        fingerLoc![0] = fingerLoc![0].replacingOccurrences(of:"(", with: "")
        fingerLoc![0] = fingerLoc![0].replacingOccurrences(of:")", with: "")
        fingerLoc![1] = fingerLoc![1].replacingOccurrences(of:" ", with: "")
        fingerLoc![1] = fingerLoc![1].replacingOccurrences(of:"]", with: "")
        fingerLoc![1] = fingerLoc![1].replacingOccurrences(of:"\"", with: "")
        fingerLoc![1] = fingerLoc![1].replacingOccurrences(of:")", with: "")
        fingerLoc![1] = fingerLoc![1].replacingOccurrences(of:" ", with: "")
        fingerLoc![2] = fingerLoc![2].replacingOccurrences(of:" ", with: "")
        fingerLoc![2] = fingerLoc![2].replacingOccurrences(of:"]", with: "")
        fingerLoc![2] = fingerLoc![2].replacingOccurrences(of:"\"", with: "")
        fingerLoc![2] = fingerLoc![2].replacingOccurrences(of:")", with: "")
        fingerLoc![2] = fingerLoc![2].replacingOccurrences(of:" ", with: "")
        tracker.frame = CGRect(x: Int(fingerLoc![0])!, y: (Int(fingerLoc![1])!), width: 30, height: 30)
        
        if(fingerLoc![2] == "1"){
            tracker.image = UIImage(named:"mouse")
        } else {
            tracker.image = UIImage(named:"click")
        }
        
        print(fingerLoc)

        if(Int(fingerLoc![2])! == 0){
            counter = counter+1;
        } else {
            counter = 0
        }

        if(counter == 3){
            hold = false
            createObject(x: Int(fingerLoc![0])!, y: Int(fingerLoc![1])!)
            counter = 0
        }
    
        if(hold){
            objects[objects.count-1].position = SCNVector3(x: Float(fingerLoc![0])!/3800, y: -Float(fingerLoc![1])!/3800+350/3800, z: -0.5)
        }
        
        print(hold)
        
    }
    
    var hold = false
    var objects = [SCNNode]()
    var stat = false
    
    func createObject(x: Int, y: Int){
        
        if (myMenu.alpha>0.2 && x>850){
            if(y>240 && y < 431){
                print("c")
                let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
                
                if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true){
                    diceNode.position = SCNVector3(x: 0, y: 0, z: -0.1) // 3 is position
                    sceneView.scene.rootNode.addChildNode(diceNode)
                    objects.append(diceNode)
                    hold = true
                }
                1`-0=-011`0-0-1`1`0-0--1`0-11`0---------------===============9119999990-==9999990=
                
            } else if (y<633) {
                //chair
                print("chair")
                
                let diceScene = SCNScene(named: "art.scnassets/chair.scn")!
                
                if let diceNode = diceScene.rootNode.childNode(withName: "Cube_009", recursively: true){
                    diceNode.position = SCNVector3(x: 0, y: 0, z: -0.1) // 3 is position
                    sceneView.scene.rootNode.addChildNode(diceNode)
                    print("lol")
                    objects.append(diceNode)
                    hold = true
                }
                
            } else {
                //table
                print("group_0")
                let diceScene = SCNScene(named: "art.scnassets/Table.scn")! // SketchUp
                if let diceNode = diceScene.rootNode.childNode(withName: "group_0", recursively: true){
                    diceNode.position = SCNVector3(x: 0, y: 0, z: -0.1) // 3 is position
                    sceneView.scene.rootNode.addChildNode(diceNode)
                    print("lol2")
                    objects.append(diceNode)
                    hold = true
                }
                
            }
        
        }
        
        if(x>850 && y<230){
            print("zzz")
            showMenu()
        }
    }
    
    @IBOutlet weak var tracker: UIImageView!
    
    @IBOutlet weak var tester: UIImageView!
    
    override func viewDidLoad() {

        
        super.viewDidLoad()
            var dataTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(ViewController.updateStuff), userInfo: nil, repeats: true)
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        // Set the view's delegate
        sceneView.delegate = self
        //Create object
        /*
        let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "art.scnassets/mercury.jpg")
        cube.materials = [material]
        let node = SCNNode()
        node.position = SCNVector3(0, 0.1, -0.5)
        node.geometry = cube
        
        sceneView.scene.rootNode.addChildNode(node)
         */
        sceneView.autoenablesDefaultLighting = true
 
    }
    
    @IBOutlet weak var myMenu: UIView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    @IBOutlet weak var textShow: UILabel!
    
    func showMenu(){
        if(myMenu.alpha < 0.2){
            myMenu.alpha = 0.4
            textShow.text = "Close Menu"
        } else {
            myMenu.alpha = 0
            textShow.text = "Open Menu"
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self.view)
        
        if(location.x>850 && location.y<230){
            showMenu()
        }
        
        
        /*
        if let touch = touches.first{
            let touchLocation = touch.location(in: sceneView)
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)

            if let hitResult = results.first {
                // Create a new scene
                let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
                
                if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true){
                    
                    diceNode.position = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y+diceNode.boundingSphere.radius/*bring up to plane*/, hitResult.worldTransform.columns.3.z) // 3 is position
                    
                    sceneView.scene.rootNode.addChildNode(diceNode)
                }
            }
        } */
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor{
            
            let planeAnchor = anchor as! ARPlaneAnchor
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            let planeNode = SCNNode()
            
            planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
            
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            
            let gridMaterial = SCNMaterial()
            
            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            
            plane.materials = [gridMaterial]
            planeNode.geometry = plane
            
            node.addChildNode(planeNode)
            
        } else{
            return
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
