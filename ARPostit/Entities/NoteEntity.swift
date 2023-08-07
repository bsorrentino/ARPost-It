//
//  NoteEntity.swift
//  ARPostit
//
//  Created by Bartolomeo Sorrentino on 27/07/23.
//

import RealityKit
import ARKit
import SwiftUI

let __USE_COMPOSITE_MODEL = true

/// An Entity which has an anchoring component and a screen space view component, where the screen space view is a StickyNoteView.
public class NoteEntity: Entity, HasModel, HasAnchoring{
    
    var planeAnchor: ARPlaneAnchor
    var planeGeometry: MeshResource!

    /// Initializes a new StickyNoteEntity and assigns the specified transform.
    /// Also automatically initializes an associated StickyNoteView with the specified frame.
    init(anchor: ARPlaneAnchor, text: String, worldTransform: simd_float4x4) {
        self.planeAnchor = anchor
        super.init()
        self.transform.matrix = worldTransform
        didSetup( text: text )
    }
    
    fileprivate func didSetup( text: String ) {
        
//        let model = ModelEntity( mesh: .generateText(text,
//                                                         extrusionDepth: 0.01,
//                                                         font: .systemFont(ofSize: 0.2),
//                                                         containerFrame: .zero,
//                                                         alignment: .left,
//                                                         lineBreakMode: .byWordWrapping),
//                                     materials: [SimpleMaterial( color: .white, isMetallic: false)] )

        self.planeGeometry = .generatePlane(width: planeAnchor.extent.x,
                                            height: planeAnchor.extent.z)
        var material = SimpleMaterial()
        material.color = .init(tint: .white,
                            texture: .init(try! .load(named: "postit")))
        let model = ModelEntity(mesh: planeGeometry, materials: [material])
        model.position = [planeAnchor.center.x, 0, planeAnchor.center.z]
        self.addChild(model)

    }
        
        fileprivate func didUpdate(anchor: ARPlaneAnchor) {
            self.planeGeometry = .generatePlane(width: anchor.extent.x,
                                                height: anchor.extent.z)
            let pose: SIMD3<Float> = [anchor.center.x, 0, anchor.center.z]
            let model = self.children[0] as! ModelEntity
            model.position = pose
        }

    
    required init() {
        fatalError("init() has not been implemented")
    }
    
}


extension SIMD4 {
    
    var xyz: SIMD3<Scalar> {
        return self[SIMD3(0, 1, 2)]
    }
    
}

extension NoteEntity {
    
    static var notes: [NoteEntity] = []
    
    static func updateScene( arView: ARView, on anchor: ARPlaneAnchor ) {
        
        //let notesToUpdate = notes.compactMap { !$0.isEditing && !$0.isDragging ? $0 : nil }
        for note in notes {
            note.didUpdate(anchor: anchor)
        }
    }
    
    static func addNew( on anchor: ARPlaneAnchor, worldTransform: simd_float4x4, text: String ) -> NoteEntity {
        
        let note = NoteEntity(anchor: anchor, text: text, worldTransform: worldTransform)
        
        notes.append( note )
        
        return note
    }
    
}

