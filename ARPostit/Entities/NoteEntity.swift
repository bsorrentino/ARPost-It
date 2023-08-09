//
//  NoteEntity.swift
//  ARPostit
//
//  Created by Bartolomeo Sorrentino on 27/07/23.
//

import RealityKit
import ARKit
import SwiftUI


/// An Entity which has an anchoring component and a screen space view component, where the screen space view is a StickyNoteView.
public class NoteEntity: Entity, HasModel, HasAnchoring {
    
    var anchoring: AnchorEntity

    /// Initializes a new StickyNoteEntity and assigns the specified transform.
    /// Also automatically initializes an associated StickyNoteView with the specified frame.
    init(anchor: AnchorEntity, text: String) {
        self.anchoring = anchor
        super.init()
        didSetup( text: text )
    }
    
    fileprivate func didSetup( text: String ) {
        let planeGeometry = MeshResource.generatePlane(width: 0.20 /* meters */, height: 0.10 /* meters */)
        var material = SimpleMaterial()
        material.color = .init(tint: .white,
                            texture: .init(try! .load(named: "postit")))
        let model = ModelEntity(mesh: planeGeometry, materials: [material])
//        model.position = [0, 0, 0]
//        model.transform.matrix = anchor.transform
//        model.transform.scale = SIMD3<Float>(1, 1, 1)
        model.transform.rotation = simd_quatf(angle: .pi / 2, axis: [-1, 0, 0])

        self.anchoring.addChild(model)

    }
        
    fileprivate func didUpdate(anchor: ARPlaneAnchor) {
    }

    
    required init() {
        fatalError("init() has not been implemented")
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
    
    static func addNew( on anchor: AnchorEntity, text: String ) -> NoteEntity {
        
        let note = NoteEntity(anchor: anchor, text: text)
        
        notes.append( note )
        
        return note
    }
    
}

