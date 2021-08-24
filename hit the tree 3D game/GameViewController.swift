//
//  GameViewController.swift
//  hit the tree 3D game
//
//  Created by Osman Solomon on 24/08/2021.
//

import UIKit
import SceneKit

class GameViewController: UIViewController {
    let treeCategory = 2
    var sceneView : SCNView!
    var scene : SCNScene!
    var ballNode:SCNNode!
    var selfiStickNode:SCNNode!
    var motion = MotionHelper()
    var motionForce = SCNVector3(0, 0, 0)
    var sounds:[String:SCNAudioSource] = [: ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        setupNodes()
        setupSounds()
    }
    
    func setupScene(){
        sceneView = self.view as? SCNView
        scene = SCNScene(named: "art.scnassets/mainScene.scn")
        sceneView.scene = scene
        scene.physicsWorld.contactDelegate = self
        let recognizer = UITapGestureRecognizer()
        recognizer.numberOfTouchesRequired = 1
        recognizer.numberOfTapsRequired = 1
        recognizer.addTarget(self, action: #selector(GameViewController.sceneViewTapped(recognizer:)))
        sceneView.addGestureRecognizer(recognizer)
    }
    
    func setupNodes(){
        ballNode = scene.rootNode.childNode(withName: "ball", recursively: true)!
        selfiStickNode = scene.rootNode.childNode(withName: "selfiStick", recursively: true)!
        sceneView.delegate = self
        ballNode.categoryBitMask = treeCategory
    }
    
    func setupSounds(){
        let sawSound = SCNAudioSource(fileNamed: "chainsaw.wav")!
        let jumpSound = SCNAudioSource(fileNamed: "jump.wav")!
        sawSound.load()
        jumpSound.load()
        sawSound.volume = 0.3
        jumpSound.volume = 0.4
        
        sounds["saw"] = sawSound
        sounds["jump"] = jumpSound
        
        let backgroundMusic = SCNAudioSource(fileNamed: "background.mp3")!
        backgroundMusic.volume = 0.1
        backgroundMusic.loops = true
        backgroundMusic.load()
        let musicPlayer = SCNAudioPlayer(source: backgroundMusic)
        ballNode.addAudioPlayer(musicPlayer)
        
    }
    
   @objc func sceneViewTapped(recognizer:UITapGestureRecognizer) {
        let location = recognizer.location(in: sceneView)
        let hitResult = sceneView.hitTest(location, options: nil)
        
        if hitResult.count > 0 {
            let result = hitResult.first
            if let node = result?.node {
                if node.name == "ball"{
                    let jumpSound = sounds["jump"]!
                    ballNode.runAction(SCNAction.playAudio(jumpSound, waitForCompletion: false))
                    ballNode.physicsBody?.applyForce(SCNVector3(0, 4, -2), asImpulse: true)
                }
            }
        }
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

extension GameViewController:SCNSceneRendererDelegate{
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        let ball = ballNode.presentation
        let ballPosition = ball.position
        
        let target = SCNVector3(ballPosition.x, ballPosition.y + 5, ballPosition.z + 5 )
        var cameraPosition = selfiStickNode.position
        let camDaming:Float = 0.3
        
        let xComponent = cameraPosition.x * (1 - camDaming) + target.x * camDaming
        let yComponent = cameraPosition.y * (1 - camDaming) + target.y * camDaming
        let zComponent = cameraPosition.z * (1 - camDaming) + target.z * camDaming
        
        cameraPosition = SCNVector3(xComponent, yComponent, zComponent)
        selfiStickNode.position = cameraPosition
        
        motion.getAccelerometerData { x, y, z in
            self.motionForce = SCNVector3(x * 0.05, 0, (y + 0.8) * -0.05)
        }
        
        ballNode.physicsBody?.velocity += motionForce
        
    }
}

extension GameViewController:SCNPhysicsContactDelegate{
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        var contactNode:SCNNode!
        if contact.nodeA.name == "ball"{
            contactNode = contact.nodeB
        } else {
            contactNode = contact.nodeB
        }
        
        if contactNode.physicsBody?.contactTestBitMask == treeCategory {
            contactNode.isHidden = true
            
            let sawSounds = sounds["saw"]!
            ballNode.runAction(SCNAction.playAudio(sawSounds, waitForCompletion: false))
            
            let waitAction = SCNAction.wait(duration: 15)
            let unHideAction = SCNAction.run { node in
                node.isHidden = false
            }
            
            let actionSequence = SCNAction.sequence([waitAction,unHideAction])
            contactNode.runAction(actionSequence)
            
        }
    }
}
