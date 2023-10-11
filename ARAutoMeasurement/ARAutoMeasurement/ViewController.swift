//
//  ViewController.swift
//  ARAutoMeasurement
//
//  Created by Donald Dang on 10/10/23.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    private var dotNodes = [SCNNode]()
    private var textNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        //show feature points that will be used to calculate start and end points
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if dotNodes.count >= 2 {
            for dot in dotNodes {
                dot.removeFromParentNode()
            }
            dotNodes = [SCNNode]()
        }
        //grab location of origin touch
        if let touchLocation = touches.first?.location(in: sceneView) {
            /*
            //set origin point for red dot
            let originPointForRed = sceneView.hitTest(touchLocation, types: .featurePoint)
            if let originPoint = originPointForRed.first {
                addDot(at: originPoint)
            }*/
            if let query = sceneView.raycastQuery(from: touchLocation, allowing: .estimatedPlane, alignment: .any) {
                if let originPoint = sceneView.session.raycast(query).first {
                    addDot(at: originPoint)
                }
            }
        }
        //create dot for radius
        func addDot(at originPoint: ARRaycastResult) {
            let dotRadius = SCNSphere(radius: 0.01)
            let dotMat = SCNMaterial()
            
            dotMat.diffuse.contents = UIColor.blue
            
            dotRadius.materials = [dotMat]
            
            let dotNode = SCNNode(geometry: dotRadius)
            
            dotNode.position = SCNVector3(originPoint.worldTransform.columns.3.x, originPoint.worldTransform.columns.3.y, originPoint.worldTransform.columns.3.z)
            
            sceneView.scene.rootNode.addChildNode(dotNode)
            
            dotNodes.append(dotNode)
            
            if dotNodes.count >= 2 {
                calculatePoint()
            }
        }
        
        func calculatePoint() {
            let start = dotNodes[0]
            let end = dotNodes[1]
            
            let dist = sqrt(pow(end.position.x - start.position.x, 2) + pow(end.position.y - start.position.y, 2) + pow(end.position.z - start.position.z, 2))
            
            update3DText(text: "\(abs(dist))", atPosition: end.position)
        }
        
        func update3DText(text: String, atPosition position: SCNVector3) {
            
            textNode.removeFromParentNode()
            
            let textGeo = SCNText(string: text, extrusionDepth: 1.0)
            
            textGeo.firstMaterial?.diffuse.contents = UIColor.blue
            
            textNode = SCNNode(geometry: textGeo)
            
            textNode.position = SCNVector3(position.x, position.y + 0.01, position.z)
            
            textNode.scale = SCNVector3(0.01, 0.01, 0.01)
            
            sceneView.scene.rootNode.addChildNode(textNode)
        }
        
    }
}
