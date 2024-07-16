//
//  ViewController.swift
//  AR Ruler
//
//  Created by administrator on 16/07/2024.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    var dotNodes = [SCNNode]()
    var textNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        sceneView.autoenablesDefaultLighting = true
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
        
        if let touchLocatin = touches.first?.location(in: sceneView) {
            if let query =  sceneView.raycastQuery(from: touchLocatin, allowing: .estimatedPlane, alignment: .any) {
                let hitTestResults = sceneView.session.raycast(query)
                if let hitResult = hitTestResults.first  {
                    addDot(at: hitResult)
                }
            }
        }
    }
    
    
    func addDot(at hitResult: ARRaycastResult){
        let dotGeomatery = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        dotGeomatery.materials = [ material]
        let dotNode = SCNNode(geometry: dotGeomatery)
        
        dotNode.position = SCNVector3(x: hitResult.worldTransform.columns.3.x, y: hitResult.worldTransform.columns.3.y, z: hitResult.worldTransform.columns.3.z)
        
        sceneView.scene.rootNode.addChildNode(dotNode)
        
        dotNodes.append(dotNode)
        
        if dotNodes.count >= 2 {
            calculate()
        }
    }
    
    
    
    func calculate(){
        let start = dotNodes[0]
        let end = dotNodes[1]

        //distance = (x2-x1)^2 + (y2-y1)^2 + (z2-z1)^2
        let distance = sqrt(
            pow(end.position.x - start.position.x, 2) +
            pow(end.position.y - start.position.y, 2) +
            pow(end.position.z - start.position.z, 2)
        )
        //print(abs(distance))
       // String(format: "%.0f", result)
       // result.formatted(.number.precision(.fractionLength(0)))
        let result = String(format: "%0.2f", (abs(distance) * 100))
        updateText(text: "\(result) CM", atPostion: end.position)
    }
    
    
    func updateText(text: String, atPostion postion: SCNVector3) {
        textNode.removeFromParentNode()
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        textNode = SCNNode(geometry: textGeometry)
        textNode.position = SCNVector3(postion.x, postion.y + 0.01, postion.z)
        textNode.scale = SCNVector3(x: 0.01, y: 0.01, z: 0.01)
        sceneView.scene.rootNode.addChildNode(textNode)
    }
    
    
    
    
    
}
