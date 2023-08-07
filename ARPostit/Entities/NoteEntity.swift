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
public class NoteEntity: Entity {
    
    var view:UIView?
    
    var projectedPoint: CGPoint?
    var isVisible = true
    
    /// Initializes a new StickyNoteEntity and assigns the specified transform.
    /// Also automatically initializes an associated StickyNoteView with the specified frame.
    init(text: String, frame: CGRect, worldTransform: simd_float4x4) {
        super.init()
        self.transform.matrix = worldTransform
        if __USE_COMPOSITE_MODEL {
            
//            self.anchoring = AnchoringComponent(.plane(.vertical, classification: .wall, minimumBounds: SIMD2<Float>(1.0, 2.0) ))
            let textModel = ModelEntity( mesh: .generateText(text,
                                                             extrusionDepth: 0.01,
                                                             font: .systemFont(ofSize: 0.2),
                                                             containerFrame: .zero,
                                                             alignment: .left,
                                                             lineBreakMode: .byWordWrapping),
                                         materials: [SimpleMaterial( color: .white, isMetallic: false)] )
            // Create a parent entity to hold the box and text entities
            
            addChild(textModel)
        }
        else {
            
            let controller = UIHostingController(rootView: NoteView( text: text ) )
            view = controller.view
            
            setPositionCenter( frame.origin )
            
        }
    }
    required init() {
        fatalError("init() has not been implemented")
    }
    
    // Returns the center point of the enity's screen space view
    fileprivate func getCenterPoint(_ point: CGPoint) -> CGPoint {
        guard let view else {
//            fatalError("Called getCenterPoint(_point:) on a screen space component with no view.")
            return .zero
        }
        let xCoord = CGFloat(point.x) - (view.frame.width) / 2
        let yCoord = CGFloat(point.y) - (view.frame.height) / 2
        return CGPoint(x: xCoord, y: yCoord)
    }
    
    // Centers the entity's screen space view on the specified screen location.
    fileprivate func setPositionCenter(_ position: CGPoint) {
        
        guard let view  else {
//            fatalError("Called centerOnHitLocation(_hitLocation:) on a screen space component with no view.")
            return
        }
        let centerPoint = getCenterPoint(position)
        view.frame.origin = CGPoint(x: centerPoint.x, y: centerPoint.y)
        
        // Updating the lastFrame of the StickyNoteView
//        view.lastFrame = view.frame
    }
    
    func updateScreenPosition( ) {
        guard let projectedPoint else { return }
        
        view?.isHidden = !isVisible

        setPositionCenter(projectedPoint)

    }
}


extension SIMD4 {
    
    var xyz: SIMD3<Scalar> {
        return self[SIMD3(0, 1, 2)]
    }
    
}

extension NoteEntity {
    
    static var notes: [NoteEntity] = []
    
    static func updateScene( arView: ARView ) {
        
        //let notesToUpdate = notes.compactMap { !$0.isEditing && !$0.isDragging ? $0 : nil }
        for note in notes {
            // Gets the 2D screen point of the 3D world point.
            guard let projectedPoint = arView.project(note.position) else { return }
            
            // Calculates whether the note can be currently visible by the camera.
            let cameraForward = arView.cameraTransform.matrix.columns.2.xyz
            let cameraToWorldPointDirection = normalize(note.transform.translation - arView.cameraTransform.translation)
            let dotProduct = dot(cameraForward, cameraToWorldPointDirection)
            let isVisible = dotProduct < 0
            
            // Updates the screen position of the note based on its visibility
            note.projectedPoint = projectedPoint
            note.isVisible = isVisible
            
            note.updateScreenPosition()
        }
    }
    
    static func addNew( at location: CGPoint, worldTransform: simd_float4x4, text: String ) -> NoteEntity {
        
        let frame = CGRect(origin: location, size: CGSize(width: 200, height: 200))
        
        let note = NoteEntity(text: text, frame: frame, worldTransform: worldTransform)
        
        notes.append( note )
        
        return note
    }

}

