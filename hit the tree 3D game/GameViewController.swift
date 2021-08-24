//
//  GameViewController.swift
//  hit the tree 3D game
//
//  Created by Osman Solomon on 24/08/2021.
//

import UIKit
import SceneKit

class GameViewController: UIViewController {
    var sceneView : SCNView!
    var scene : SCNScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
    }
    
    func setupScene(){
        sceneView = self.view as? SCNView
        sceneView.allowsCameraControl = true
        scene = SCNScene(named: "art.scnassets/mainScene.scn")
        sceneView.scene = scene
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
