//
//  GameViewController.swift
//  barnesWorking
//
//  Created by Eder Martins on 6/25/14.
//  Copyright (c) 2014 diamondApps. All rights reserved.
//


// Contact me:
//
// twitter.com/dedehmartins


import UIKit
import QuartzCore
import SceneKit
import SpriteKit
import Foundation



var NUMBODIES = 23
let DISPLAY:Float = 10.0
let THETA:Float = 0.5
let COLLISION_DISTANCE:Float = 0.0001
let G:Float = 0.000001
let min:Coordinate = Coordinate(x: -DISPLAY/2,y: -DISPLAY/2,z: -DISPLAY/2)
let max:Coordinate = Coordinate(x: DISPLAY/2, y: DISPLAY/2, z: DISPLAY/2)
var printStruct:Bool=false
var addHandlerTap:Bool = true
var paused:Bool = false
var timer:NSTimer?
let scene = SCNScene()
let sceneMenu = SCNScene()
var arrayOfNodes: [SCNNode] = []
var arrayOfLines: [SCNNode] = []

var buttonBack = UIButton(frame: CGRectMake(5, 5, 50, 50))
var buttonPauseResume = UIButton(frame: CGRectMake(320-75, 5, 70, 50))


var arrayOfBodies: [Body] = []
var octTree:OctNode = OctNode(minValue: min,maxValue: max)






struct Coordinate{
    var x:Float = 0.0
    var y:Float = 0.0
    var z:Float = 0.0
}

struct Body{
    var position:Coordinate
    var speed:Coordinate
    var acceleration:Coordinate
    var force:Coordinate
    var mass:Float
    var n:Int
}

class OctNode{
    var min:Coordinate
    var max:Coordinate
    var center_of_mass:Coordinate
    var total_mass:Float
    var number_of_bodies:Int
    var Q1:OctNode?
    var Q2:OctNode?
    var Q3:OctNode?
    var Q4:OctNode?
    var Q5:OctNode?
    var Q6:OctNode?
    var Q7:OctNode?
    var Q8:OctNode?
    var arrayOfBodies: [Body]
    
    func exists()->Bool{
        return true;
    }
    
    init(minValue: Coordinate,maxValue: Coordinate){
        min = minValue
        max = maxValue
        total_mass = 0.0
        number_of_bodies = 0
        arrayOfBodies = []
        center_of_mass = Coordinate()
    }
}



class MainViewController: UIViewController {
    
    
    @IBOutlet weak var swiStruct: UISwitch!
    @IBOutlet weak var steNumBodies: UIStepper!
    @IBOutlet weak var lblNumBodies: UILabel!
    @IBOutlet weak var viewMenu: UIView!
    
    func createNewQuadrants(inout node: OctNode){
        for (index,body) in node.arrayOfBodies.enumerate(){
            if (body.position.x > (node.min.x+node.max.x)/2){ // Q5 or Q6 or Q7 or Q8
                if (body.position.y > (node.min.y+node.max.y)/2){ // Q7 or Q8
                    if (body.position.z > (node.min.z+node.max.z)/2){ // Q8
                        if (node.Q8 == nil) {
                            let min:Coordinate = Coordinate(x: (node.min.x+node.max.x)/2,y: (node.min.y+node.max.y)/2,z: (node.min.z+node.max.z)/2)
                            let max:Coordinate = Coordinate(x: node.max.x , y: node.max.y, z: node.max.z)
                            node.Q8 = OctNode(minValue: min,maxValue: max)
                            
                        }
                        node.Q8?.arrayOfBodies.append(body)
                        node.Q8?.number_of_bodies++
                    }else{ // Q7
                        if (node.Q7 == nil) {
                            let min:Coordinate = Coordinate(x: (node.min.x+node.max.x)/2,y: (node.min.y+node.max.y)/2,z: node.min.z)
                            let max:Coordinate = Coordinate(x: node.max.x , y: node.max.y, z: (node.min.z+node.max.z)/2)
                            node.Q7 = OctNode(minValue: min,maxValue: max)
                        }
                        node.Q7?.arrayOfBodies.append(body)
                        node.Q7?.number_of_bodies++;
                    }
                }else{ // Q6 or Q5
                    if (body.position.z > (node.min.z+node.max.z)/2){ // Q6
                        if (node.Q6 == nil) {
                            let min:Coordinate = Coordinate(x: (node.min.x+node.max.x)/2,y: node.min.y,z: (node.min.z+node.max.z)/2)
                            let max:Coordinate = Coordinate(x: node.max.x , y: (node.min.y+node.max.y)/2, z: node.max.z)
                            node.Q6 = OctNode(minValue: min,maxValue: max);
                        }
                        node.Q6?.arrayOfBodies.append(body)
                        node.Q6?.number_of_bodies++
                        
                    }else{ // Q5
                        if (node.Q5 == nil) {
                            let min:Coordinate = Coordinate(x: (node.min.x+node.max.x)/2,y: node.min.y,z: node.min.z)
                            let max:Coordinate = Coordinate(x: node.max.x , y: (node.min.y+node.max.y)/2, z: (node.min.z+node.max.z)/2)
                            node.Q5 = OctNode(minValue: min,maxValue: max);
                        }
                        node.Q5?.arrayOfBodies.append(body)
                        node.Q5?.number_of_bodies++
                    }
                }
            }else{ // Q1 or Q2 or Q3 or Q4
                if (body.position.y > (node.min.y+node.max.y)/2){ // Q3 or Q4
                    if (body.position.z > (node.min.z+node.max.z)/2){ // Q4
                        if (node.Q4 == nil) {
                            let min:Coordinate = Coordinate(x: node.min.x,y: (node.min.y+node.max.y)/2,z: (node.min.z+node.max.z)/2)
                            let max:Coordinate = Coordinate(x: (node.min.x+node.max.x)/2, y: node.max.y, z: node.max.z)
                            node.Q4 = OctNode(minValue: min,maxValue: max);
                        }
                        node.Q4?.arrayOfBodies.append(body)
                        node.Q4?.number_of_bodies++
                    }else{ // Q3
                        if (node.Q3 == nil){
                            let min:Coordinate = Coordinate(x: node.min.x,y: (node.min.y+node.max.y)/2,z: node.min.z)
                            let max:Coordinate = Coordinate(x: (node.min.x+node.max.x)/2, y: node.max.y, z: (node.min.z+node.max.z)/2)
                            node.Q3 = OctNode(minValue: min,maxValue: max);
                        }
                        node.Q3?.arrayOfBodies.append(body)
                        node.Q3?.number_of_bodies++
                    }
                }else{ // Q1 or Q2
                    if (body.position.z > (node.min.z+node.max.z)/2){ // Q2
                        if (node.Q2 == nil){
                            let min:Coordinate = Coordinate(x: node.min.x,y: node.min.y,z: (node.min.z+node.max.z)/2)
                            let max:Coordinate = Coordinate(x: (node.min.x+node.max.x)/2, y: (node.min.y+node.max.y)/2, z: node.max.z)
                            node.Q2 = OctNode(minValue: min, maxValue: max)
                        }
                        node.Q2?.arrayOfBodies.append(body)
                        node.Q2?.number_of_bodies++
                    }else{ // Q1
                        if (node.Q1 == nil){
                            let min:Coordinate = Coordinate(x: node.min.x,y: node.min.y,z: node.min.z)
                            let max:Coordinate = Coordinate(x: (node.min.x+node.max.x)/2, y: (node.min.y+node.max.y)/2, z: (node.min.z+node.max.z)/2)
                            node.Q1 = OctNode(minValue: min, maxValue: max)
                        }
                        node.Q1?.arrayOfBodies.append(body)
                        node.Q1?.number_of_bodies++
                    }
                }
            }
        }
        
        var auxVar:OctNode
        if node.Q1 != nil {
            auxVar = node.Q1!
            if auxVar.number_of_bodies>1 { createNewQuadrants(&auxVar); }
        }
        if node.Q2 != nil {
            auxVar = node.Q2!
            if auxVar.number_of_bodies>1 { createNewQuadrants(&auxVar); }
        }
        if node.Q3 != nil {
            auxVar = node.Q3!
            if auxVar.number_of_bodies>1 { createNewQuadrants(&auxVar); }
        }
        if node.Q4 != nil {
            auxVar = node.Q4!
            if auxVar.number_of_bodies>1 { createNewQuadrants(&auxVar); }
        }
        if node.Q5 != nil {
            auxVar = node.Q5!
            if auxVar.number_of_bodies>1 { createNewQuadrants(&auxVar); }
        }
        if node.Q6 != nil {
            auxVar = node.Q6!
            if auxVar.number_of_bodies>1 { createNewQuadrants(&auxVar); }
        }
        if node.Q7 != nil {
            auxVar = node.Q7!
            if auxVar.number_of_bodies>1 { createNewQuadrants(&auxVar); }
        }
        if node.Q8 != nil {
            auxVar = node.Q8!
            if auxVar.number_of_bodies>1 { createNewQuadrants(&auxVar); }
        }
    }
    
    
    func stillOnThatOct(b: Body,node: OctNode) -> Bool{
        return !((b.position.x > node.max.x) || (b.position.x < node.min.x) || (b.position.y > node.max.y) || (b.position.y < node.min.y) || (b.position.z > node.max.z) || (b.position.z < node.min.z))
    }
    
    
    func buildOct() -> Bool{
        let min:Coordinate = Coordinate(x: -DISPLAY/2,y: -DISPLAY/2,z: -DISPLAY/2)
        let max:Coordinate = Coordinate(x: DISPLAY/2, y: DISPLAY/2, z: DISPLAY/2)
        octTree = OctNode(minValue: min,maxValue: max)
        for (index,body) in arrayOfBodies.enumerate(){
            if ( stillOnThatOct(body, node: octTree) ){
                octTree.arrayOfBodies.append(body)
                octTree.number_of_bodies++
            }
        }
        if octTree.number_of_bodies == 0 { return false }
        
        if octTree.number_of_bodies > 1  { createNewQuadrants(&octTree); }
        
        return true
    }
    
    func initBodies(){
        srand(0);
        for i in 0...(NUMBODIES-1){
            var position:Coordinate = Coordinate()
            position.x = randomValue()
            position.y = randomValue()
            position.z = randomValue()
            let pBody:Body = Body(position: position,speed: Coordinate(),acceleration: Coordinate(),force: Coordinate(),mass: 100,n: i+1)
            arrayOfBodies.append(pBody)
            arrayOfNodes.append(pointNode(position))
        }
    }
    
    func itsAFinalNode(node:OctNode)->Bool{
        return (!(node.Q1 != nil) && !(node.Q2 != nil) && !(node.Q3 != nil) && !(node.Q4 != nil) && !(node.Q5 != nil) && !(node.Q6 != nil) && !(node.Q7 != nil) && !(node.Q8 != nil));
    }
    
    func distanceLowerThanTheta(b:Body,node:OctNode)->Bool{
        let rx:Float  = (b.position.x - node.center_of_mass.x); // distance in x
        let ry:Float  = (b.position.y - node.center_of_mass.y); // distance in y
        let rz:Float  = (b.position.z - node.center_of_mass.z); // distance betwen body and center of mass of octet in z
        let r:Float = rx*rx+ry*ry+rz*rz
        
        
        return ( THETA > sqrtf(r) );
    }
    
    func theBodyIsNotOnThatOct(b:Body,node:OctNode)->Bool{
        for (index,body) in node.arrayOfBodies.enumerate(){
            if(b.n == body.n){
                return false
            }
        }
        return true
    }
    
    func calculeForce(inout b:Body,node:OctNode){
        if (theBodyIsNotOnThatOct(b,node: node)){
            if (itsAFinalNode(node)||distanceLowerThanTheta(b,node: node)){
                let rx = (b.position.x - node.center_of_mass.x); // distance in x
                let ry = (b.position.y - node.center_of_mass.y); // distance in y
                let rz = (b.position.z - node.center_of_mass.z); // distance betwen body and center of mass of octet in z
                let r2:Float = rx*rx + ry*ry + rz*rz; // square of the distance
                if ( sqrtf(r2) > COLLISION_DISTANCE){ // distance to collision
                    let fabs = -(G*b.mass*node.total_mass) / r2  // absolute force ( newton formula of gravity )
                    b.force.x += fabs*rx/sqrtf(r2); // calculate the component in x of the absolute force
                    b.force.y += fabs*ry/sqrtf(r2); // calculate the component in y of the absolute force
                    b.force.z += fabs*rz/sqrtf(r2);
                }
            }else{
                if node.Q1 != nil { calculeForce(&b,node: node.Q1!) }
                if node.Q2 != nil { calculeForce(&b,node: node.Q2!) }
                if node.Q3 != nil { calculeForce(&b,node: node.Q3!) }
                if node.Q4 != nil { calculeForce(&b,node: node.Q4!) }
                if node.Q5 != nil { calculeForce(&b,node: node.Q5!) }
                if node.Q6 != nil { calculeForce(&b,node: node.Q6!) }
                if node.Q7 != nil { calculeForce(&b,node: node.Q7!) }
                if node.Q8 != nil { calculeForce(&b,node: node.Q8!) }
            }
        }else{
            if (itsAFinalNode(node)){
                // its the node of that body! do nothing
            }else{
                if node.Q1 != nil { calculeForce(&b,node: node.Q1!) }
                if node.Q2 != nil { calculeForce(&b,node: node.Q2!) }
                if node.Q3 != nil { calculeForce(&b,node: node.Q3!) }
                if node.Q4 != nil { calculeForce(&b,node: node.Q4!) }
                if node.Q5 != nil { calculeForce(&b,node: node.Q5!) }
                if node.Q6 != nil { calculeForce(&b,node: node.Q6!) }
                if node.Q7 != nil { calculeForce(&b,node: node.Q7!) }
                if node.Q8 != nil { calculeForce(&b,node: node.Q8!) }
            }
        }
    }
    
    func updForces(){
        for i in 0...arrayOfBodies.count-1{
            arrayOfBodies[i].force.x=0.0
            arrayOfBodies[i].force.y=0.0
            arrayOfBodies[i].force.z=0.0
            calculeForce(&arrayOfBodies[i],node: octTree);
        }
    }
    
    func updBodies(){
        for i in 0...arrayOfBodies.count-1{
            arrayOfBodies[i].acceleration.x = arrayOfBodies[i].force.x / arrayOfBodies[i].mass
            arrayOfBodies[i].acceleration.y = arrayOfBodies[i].force.y / arrayOfBodies[i].mass
            arrayOfBodies[i].acceleration.z = arrayOfBodies[i].force.z / arrayOfBodies[i].mass
            arrayOfBodies[i].speed.x += arrayOfBodies[i].acceleration.x;
            arrayOfBodies[i].speed.y += arrayOfBodies[i].acceleration.y;
            arrayOfBodies[i].speed.z += arrayOfBodies[i].acceleration.z;
            arrayOfBodies[i].position.x += arrayOfBodies[i].speed.x;
            arrayOfBodies[i].position.y += arrayOfBodies[i].speed.y;
            arrayOfBodies[i].position.z += arrayOfBodies[i].speed.z;
            
            arrayOfNodes[i].position.x = arrayOfBodies[i].position.x
            arrayOfNodes[i].position.y = arrayOfBodies[i].position.y
            arrayOfNodes[i].position.z = arrayOfBodies[i].position.z
            
        }
    }
    
    func calculeCenterOfMass( node:OctNode){
        if node.Q1 != nil { calculeCenterOfMass(node.Q1!) };
        if node.Q2 != nil { calculeCenterOfMass(node.Q2!) };
        if node.Q3 != nil { calculeCenterOfMass(node.Q3!) };
        if node.Q4 != nil { calculeCenterOfMass(node.Q4!) };
        if node.Q5 != nil { calculeCenterOfMass(node.Q5!) };
        if node.Q6 != nil { calculeCenterOfMass(node.Q6!) };
        if node.Q7 != nil { calculeCenterOfMass(node.Q7!) };
        if node.Q8 != nil { calculeCenterOfMass(node.Q8!) };
        node.total_mass = 0.0
        for i in 0...node.arrayOfBodies.count-1{ // calcule the total mass of that oct
            node.total_mass += node.arrayOfBodies[i].mass;
        }
        node.center_of_mass.x=0;
        node.center_of_mass.y=0;
        node.center_of_mass.z=0;
        for (index,body) in node.arrayOfBodies.enumerate(){ // and then calcule the position of the center of mass. Its the sommatory of the positions times the mass divided by the total mass.
            node.center_of_mass.x += body.position.x*body.mass/node.total_mass;
            node.center_of_mass.y += body.position.y*body.mass/node.total_mass;
            node.center_of_mass.z += body.position.z*body.mass/node.total_mass;
        }
    }
    
    func drawStruct(node:OctNode){
        // lines in X
        drawLineX(node.min.x,xf: node.max.x,yi: node.min.y,yf: node.min.y,zi: node.min.z,zf: node.min.z);
        drawLineX(node.min.x,xf: node.max.x,yi: node.max.y,yf: node.max.y,zi: node.min.z,zf: node.min.z);
        drawLineX(node.min.x,xf: node.max.x,yi: node.min.y,yf: node.min.y,zi: node.max.z,zf: node.max.z);
        drawLineX(node.min.x,xf: node.max.x,yi: node.max.y,yf: node.max.y,zi: node.max.z,zf: node.max.z);
        // lines in Y
        drawLineY(node.min.x,xf: node.min.x,yi: node.min.y,yf: node.max.y,zi: node.min.z,zf: node.min.z);
        drawLineY(node.max.x,xf: node.max.x,yi: node.min.y,yf: node.max.y,zi: node.min.z,zf: node.min.z);
        drawLineY(node.min.x,xf: node.min.x,yi: node.min.y,yf: node.max.y,zi: node.max.z,zf: node.max.z);
        drawLineY(node.max.x,xf: node.max.x,yi: node.min.y,yf: node.max.y,zi: node.max.z,zf: node.max.z);
        // lines in Z
        drawLineZ(node.min.x,xf: node.min.x,yi: node.min.y,yf: node.min.y,zi: node.min.z,zf: node.max.z);
        drawLineZ(node.max.x,xf: node.max.x,yi: node.min.y,yf: node.min.y,zi: node.min.z,zf: node.max.z);
        drawLineZ(node.min.x,xf: node.min.x,yi: node.max.y,yf: node.max.y,zi: node.min.z,zf: node.max.z);
        drawLineZ(node.max.x,xf: node.max.x,yi: node.max.y,yf: node.max.y,zi: node.min.z,zf: node.max.z);
        
        if node.Q1 != nil { drawStruct(node.Q1!) }
        if node.Q2 != nil { drawStruct(node.Q2!) }
        if node.Q3 != nil { drawStruct(node.Q3!) }
        if node.Q4 != nil { drawStruct(node.Q4!) }
        if node.Q5 != nil { drawStruct(node.Q5!) }
        if node.Q6 != nil { drawStruct(node.Q6!) }
        if node.Q7 != nil { drawStruct(node.Q7!) }
        if node.Q8 != nil { drawStruct(node.Q8!) }
        
    }
    
    func removeStruct(){
        if(arrayOfLines.count>0){
            for i in 0 ... arrayOfLines.count-1{
                arrayOfLines[i].removeFromParentNode()
            }
        }
        arrayOfLines = []
    }
    
    func drawLineX(xi:Float,xf:Float,yi:Float,yf:Float,zi:Float,zf:Float){
        let lineNode = SCNNode()
        let d:Float = xf - xi;
        lineNode.geometry = SCNBox(width: CGFloat(fabsf(d)), height: 0.01, length: 0.01, chamferRadius: 0)
        lineNode.position = SCNVector3(x: (xf+xi)/2, y: (yf+yi)/2, z: (zf+zi)/2)
        lineNode.geometry?.firstMaterial?.emission.contents = UIColor.greenColor()
        scene.rootNode.addChildNode(lineNode)
        arrayOfLines.append(lineNode)
    }
    
    func drawLineY(xi:Float,xf:Float,yi:Float,yf:Float,zi:Float,zf:Float){
        let lineNode = SCNNode()
        let d:Float = yf - yi;
        lineNode.geometry = SCNBox(width: 0.01, height: CGFloat(fabsf(d)), length: 0.01, chamferRadius: 0)
        lineNode.position = SCNVector3(x: (xf+xi)/2, y: (yf+yi)/2, z: (zf+zi)/2)
        lineNode.geometry?.firstMaterial?.emission.contents = UIColor.greenColor()
        scene.rootNode.addChildNode(lineNode)
        arrayOfLines.append(lineNode)
    }
    
    func drawLineZ(xi:Float,xf:Float,yi:Float,yf:Float,zi:Float,zf:Float){
        let lineNode = SCNNode()
        let d:Float = zf - zi;
        lineNode.geometry = SCNBox(width: 0.01, height: 0.01, length: CGFloat(fabsf(d)), chamferRadius: 0)
        lineNode.position = SCNVector3(x: (xf+xi)/2, y: (yf+yi)/2, z: (zf+zi)/2)
        lineNode.geometry?.firstMaterial?.emission.contents = UIColor.greenColor()
        scene.rootNode.addChildNode(lineNode)
        arrayOfLines.append(lineNode)
    }
    
    
    
    
    
    
    let cameraNode = SCNNode()
    var node1 = SCNNode()
    var node2 = SCNNode()
    
    func update() {
        if(buildOct()){
            calculeCenterOfMass(octTree)
            updForces()
            removeStruct()
            if printStruct{
                drawStruct(octTree)
            }
        }
        updBodies()
    }
    
    override func viewDidLoad() {

        buttonBack.setTitle("Back", forState: UIControlState.Normal)
        buttonBack.addTarget(self, action: "btnBackClicked", forControlEvents: UIControlEvents.TouchUpInside)
        buttonBack.alpha = 0
        self.view.addSubview(buttonBack)
        buttonPauseResume.setTitle("Pause", forState: UIControlState.Normal)
        buttonPauseResume.addTarget(self, action: "btnPauseResume", forControlEvents: UIControlEvents.TouchUpInside)
        buttonPauseResume.alpha = 0
        self.view.addSubview(buttonPauseResume)
        steNumBodies.value = 23;
        steNumBodies.maximumValue = 300;
        steNumBodies.minimumValue = 2;
        steNumBodies.stepValue = 1;
    }
    

    
    @IBAction func stepperValueChanged(sender: UIStepper) {
        lblNumBodies.text = NSString(format: "%.0f", sender.value) as String
        NUMBODIES = Int(sender.value)
    }

    

    @IBAction func start(sender: AnyObject) {
        
        // create and configure a material
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "texture")
        material.specular.contents = UIColor.grayColor()
        material.locksAmbientWithDiffuse = true
        
        
        // set the material to the 3d object geometry
        //boxNode.geometry.firstMaterial = material
        
        
        printStruct = false
        addHandlerTap = swiStruct.on
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        
        
        initBodies()
        timer = NSTimer.scheduledTimerWithTimeInterval(0.0001, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
        // create a new scene
        // create and add a camera to the scene
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = SCNLightTypeOmni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = SCNLightTypeAmbient
        ambientLightNode.light?.color = UIColor.darkGrayColor()
        scene.rootNode.addChildNode(ambientLightNode)
        
        
        for (index,value) in arrayOfNodes.enumerate() {
            scene.rootNode.addChildNode(value)
        }
        
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // configure the view
        scnView.backgroundColor = UIColor.blackColor()
        
        // add a tap gesture recognizer
        if(addHandlerTap){
            let tapGesture = UITapGestureRecognizer(target: self, action: "handleTap:")
            scnView.addGestureRecognizer(tapGesture)
        }
        UIView .animateWithDuration(0.5, animations: { () -> Void in
            self.viewMenu.alpha = 0.0
            buttonBack.alpha = 1.0
            buttonPauseResume.alpha = 1.0
        })
    }
    
    
    func btnBackClicked(){
        timer?.invalidate()
        arrayOfBodies = []
        for (index,value) in arrayOfNodes.enumerate() {
            value.removeFromParentNode()
        }
        arrayOfNodes = []
        UIView .animateWithDuration(0.5, animations: { () -> Void in
            self.viewMenu.alpha = 1.0
            buttonBack.alpha = 0.0
            buttonPauseResume.alpha = 0.0
        })
        
    }
    
    func btnPauseResume(){
        if paused {
            timer = NSTimer.scheduledTimerWithTimeInterval(0.0001, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
            paused = false
            buttonPauseResume.setTitle("Pause", forState: UIControlState.Normal)
        }else {
            timer?.invalidate()
            paused = true
            buttonPauseResume.setTitle("Resume", forState: UIControlState.Normal)
        }
    }
    
    


    
    
    

    
    
    func pointNode(position:Coordinate) -> SCNNode{
        let pointNode = SCNNode()
        pointNode.geometry = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.2)
        pointNode.position = SCNVector3(x: position.x, y: position.y, z: position.z)
        return pointNode
    }
    
    func randomValue() -> Float{
        return Float(rand()%601)/100 - 3.0
    }
    
    
    
    func handleTap(gestureRecognize: UIGestureRecognizer) {
            printStruct = !printStruct
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return UIInterfaceOrientationMask.AllButUpsideDown
        } else {
            return UIInterfaceOrientationMask.All
        }
    }
    
    override func didReceiveMemoryWarning() {
        printStruct = false;
    }
    
    
}