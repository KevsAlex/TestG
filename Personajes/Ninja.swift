
import Foundation
import SpriteKit

class Ninja : SKSpriteNode{
  
  init() {
    let texture = SKTexture(imageNamed: "player")
    super.init(texture: texture, color: UIColor.red, size: texture.size())
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  init(ninjaType:String) {
    let texture = SKTexture(imageNamed: ninjaType)
    let color = UIColor.black
    let size = texture.size()
    super.init(texture: texture, color: color, size: size)
  }
  
}
