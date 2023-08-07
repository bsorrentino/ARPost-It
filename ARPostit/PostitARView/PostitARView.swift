//
//  PostitARView.swift
//  ARPostit
//
//  Created by Bartolomeo Sorrentino on 03/08/23.
//

import ARKit
import RealityKit
import Combine


class PostitARView : ARView {
    
    
    func placePostit2(on anchor: ARAnchor, text: String) {
        let planeGeometry = MeshResource.generatePlane(width: 1, height: 1)
        var material = SimpleMaterial()
        material.color = .init(tint: .white,
                            texture: .init(try! .load(named: "postit")))
        let model = ModelEntity(mesh: planeGeometry, materials: [material])
        model.position = [0, 0, 0]
        model.transform.matrix = anchor.transform
        
        let anchorEntity = AnchorEntity(anchor: anchor)
        anchorEntity.addChild(model)
        
        self.scene.addAnchor(anchorEntity)
    }
    
    func placePostit( on anchor: ARAnchor, text: String )  {
        let entity = ModelEntity( mesh: .generateText(text,
                                                         extrusionDepth: 0.01,
                                                         font: .systemFont(ofSize: 0.2),
                                                         containerFrame: .zero,
                                                         alignment: .left,
                                                         lineBreakMode: .byWordWrapping),
                                     materials: [SimpleMaterial( color: .white, isMetallic: false)] )

        let anchorEntity = AnchorEntity(anchor: anchor)
        anchorEntity.addChild(entity)
        self.scene.addAnchor(anchorEntity)
    }
    
    func addNoteEntityToWall( on anchor: ARPlaneAnchor, at location: CGPoint, worldTransform: simd_float4x4 ) {
        
        let note = NoteEntity.addNew( on: anchor, worldTransform: worldTransform, text: "New Note" )
        
        self.scene.addAnchor(note)
        
    }

}
