//
//  GridEntity.swift
//  ARPostit
//
//  Created by Bartolomeo Sorrentino on 27/07/23.
//
import RealityKit
import ARKit

class GridEntity: Entity, HasModel, HasAnchoring {
    var planeAnchor: ARPlaneAnchor
    var planeGeometry: MeshResource!
    
    init(planeAnchor: ARPlaneAnchor) {
        self.planeAnchor = planeAnchor
        super.init()
        self.didSetup()
    }
    
    fileprivate func didSetup() {
        
        do {
            let texture  = MaterialParameters.Texture( try .load(named: "grid") )

            self.planeGeometry = .generatePlane(width: planeAnchor.planeExtent.width, depth: planeAnchor.planeExtent.height)
            var material = UnlitMaterial()
            material.color = .init(tint: .white.withAlphaComponent(0.999), texture: texture )
            let model = ModelEntity(mesh: planeGeometry, materials: [material])
            model.position = [planeAnchor.center.x, 0, planeAnchor.center.z]
            self.addChild(model)

            self.transform.matrix = planeAnchor.transform
        }
        catch {
            print( "GRID SETUP ERROR: \(error)")
        }
        
        
    }
    
    func didUpdate(anchor: ARPlaneAnchor) {
        
        self.transform.matrix = planeAnchor.transform
        
        self.planeGeometry = .generatePlane(width:  planeAnchor.planeExtent.width, depth: planeAnchor.planeExtent.height)
        let pose: SIMD3<Float> = [anchor.center.x, 0, anchor.center.z]
        let model = self.children[0] as! ModelEntity
        model.position = pose
    }
    
    required init() {
        fatalError("Hasn't been implemented yet")
    }
}

