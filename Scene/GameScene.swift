import SpriteKit


func +(left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func -(left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func *(point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func /(point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
func sqrt(a: CGFloat) -> CGFloat {
  return CGFloat(sqrtf(Float(a)))
}
#endif

extension CGPoint {
  func length() -> CGFloat {
    return sqrt(x*x + y*y)
  }
  
  func normalized() -> CGPoint {
    return self / length()
  }
}

struct PhysicsCategory {
  static let none      : UInt32 = 0
  static let all       : UInt32 = UInt32.max
  static let monster   : UInt32 = 0b1
  static let projectile: UInt32 = 0b10
}

class GameScene: SKScene {
  
  var player : Ninja?
  var ninja2 : Ninja?
  
  override func didMove(to view: SKView) {
    let gray = #colorLiteral(red: 0.5741485357, green: 0.5741624236, blue: 0.574154973, alpha: 1)
    backgroundColor = gray
    player = Ninja(ninjaType: "player")
    ninja2 = Ninja(ninjaType: "player")
    player?.position = CGPoint(x: size.width / 2 , y: size.height / 6)
    ninja2?.position = CGPoint(x: size.width / 2, y: size.height - size.height / 6)
    addChild(player!)
    addChild(ninja2!)
    
    physicsWorld.gravity = .zero
    physicsWorld.contactDelegate = self
    
    run(SKAction.repeatForever(
      SKAction.sequence([
        SKAction.run(addMonster),
        SKAction.wait(forDuration: 1.0)
        ])
    ))
  }
  
  func projectileDidCollideWithMonster(projectile: SKSpriteNode, monster: SKSpriteNode) {
    print("le pinchis pegué")
    projectile.removeFromParent()
    monster.removeFromParent()
  }
  
  func random() -> CGFloat {
    return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
  }
  
  func random(min: CGFloat, max: CGFloat) -> CGFloat {
    return random() * (max - min) + min
  }
  
  func addMonster() {
    let monster = SKSpriteNode(imageNamed: "monster")
    
    let actualY = random(min: monster.size.height/2, max: size.height - monster.size.height/2)
    monster.position = CGPoint(x: size.width + monster.size.width, y: actualY)
    monster.size = CGSize(width: 40, height: 40)
    monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size)
    monster.physicsBody?.isDynamic = true
    monster.physicsBody?.categoryBitMask = PhysicsCategory.monster
    monster.physicsBody?.contactTestBitMask = PhysicsCategory.projectile
    monster.physicsBody?.collisionBitMask = PhysicsCategory.none
    addChild(monster)
    // Agregando el cuerpo del pinchi monstruo
    
    
    let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
    let actionMove = SKAction.move(to: CGPoint(x: -monster.size.width, y: actualY),
                                   duration: 2.0)
    
    let actionMoveDone = SKAction.removeFromParent()
    monster.run(SKAction.sequence([actionMove, actionMoveDone]))
  }
  
  func launchProyectile (initWith touchLocation :CGPoint){
    let projectile = SKSpriteNode(imageNamed: "projectile")
    projectile.position = (player?.position)!
    
    projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
    projectile.physicsBody?.isDynamic = true
    projectile.physicsBody?.categoryBitMask = PhysicsCategory.projectile
    projectile.physicsBody?.contactTestBitMask = PhysicsCategory.monster
    projectile.physicsBody?.collisionBitMask = PhysicsCategory.none
    projectile.physicsBody?.usesPreciseCollisionDetection = true
    let offset = touchLocation - projectile.position
    //if offset.x < 0 { return }
    addChild(projectile)
    let direction = offset.normalized()
    let realDest = (direction * 1000) + CGPoint(x: 80, y: 80)
    let actionMove = SKAction.move(to: realDest, duration: 2.0)
    let actionMoveDone = SKAction.removeFromParent()
    projectile.run(SKAction.sequence([actionMove, actionMoveDone]))
    
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else {
      return
    }
    let touchLocation = touch.location(in: self)
    self.launchProyectile(initWith: touchLocation)
  }
  
}

//---------------------------------
//MARK:SKPhysics Delegate
//---------------------------------
extension GameScene: SKPhysicsContactDelegate {
  
  func didBegin(_ contact: SKPhysicsContact) {
    var firstBody: SKPhysicsBody
    var secondBody: SKPhysicsBody
    if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
      firstBody = contact.bodyA
      secondBody = contact.bodyB
    } else {
      firstBody = contact.bodyB
      secondBody = contact.bodyA
    }
    
    if (firstBody.categoryBitMask & PhysicsCategory.monster != 0) && (secondBody.categoryBitMask & PhysicsCategory.projectile != 0) {
      if let monster = firstBody.node as? SKSpriteNode,
        let projectile = secondBody.node as? SKSpriteNode {
        projectileDidCollideWithMonster(projectile: projectile, monster: monster)
      }
    }
  }
  
}

//---------------------------------
//MARK:Implementación de los touches
//---------------------------------
extension GameScene{
  
  /**
   Mueve al pinchi ninja a la derecha
   **/
  func moveNinjaRight(ninja : SKSpriteNode){
    
    let screenSizeX = self.view?.frame.width
    let distance = CGFloat(screenSizeX! - ninja.frame.width)
    //let moveX = SKAction.moveTo(x: -(ninja.frame.origin.x - distance), duration: 1)
    let moveX = SKAction.moveBy(x: ninja.size.width / 2, y: 0, duration: 1)
    //let actionMove = SKAction.move(to: CGPoint(x: -ninja.size.width, y: 0),duration: 2.0)
    let actionMove = SKAction.sequence([moveX])
    ninja.run(actionMove)
  }
  
  /**
   Mueve al pinchi ninja a la derecha
   **/
  func moveNinjaLeft(ninja : SKSpriteNode){
    
    let screenSizeX = self.view?.frame.width
    let distance = CGFloat(screenSizeX! - ninja.frame.width)
    //let moveX = SKAction.moveTo(x: -(ninja.frame.origin.x - distance), duration: 1)
    let moveX = SKAction.moveBy(x: -ninja.size.width / 2, y: 0, duration: 1)
    //let actionMove = SKAction.move(to: CGPoint(x: -ninja.size.width, y: 0),duration: 2.0)
    let actionMove = SKAction.sequence([moveX])
    ninja.run(actionMove)
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    for touch in touches{
      print("touch \(touch.location(in: self))")
      if touch.location(in: view).x < size.width * 0.3{
        print("IS LEFT")
        moveNinjaLeft(ninja: player!)
      }else if touch.location(in: view).x > size.width * 0.6{
        print("IS RIGHT")
        moveNinjaRight(ninja: player!)
        
      }else {
        print("IS CENTER")
      }
    }
  }
}






