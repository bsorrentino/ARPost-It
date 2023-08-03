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
    
    
    internal func addNoteEntityToWall( at location: CGPoint, worldTransform: simd_float4x4 ) {
        
        let note = NoteEntity.addNew( at: location, worldTransform: worldTransform, text: "New Note" )
        
        self.scene.addAnchor(note)
        
        guard let view = note.view else { return }
        
        self.addSubview(view)
        
    }
    
    //        func addNoteViewToWall( worldTransform: simd_float4x4 ) {
    //
    //            let position = SCNVector3(worldTransform.columns.3.x,
    //                                     worldTransform.columns.3.y,
    //                                     worldTransform.columns.3.z)
    //
    //            let anchor = ARAnchor(name: "Note", transform: worldTransform)
    //            parent.arView.session.add(anchor: anchor)
    //
    //            let noteText = "New Note"
    //            let point = CGPoint(x: CGFloat(position.x), y: CGFloat(position.y))
    //
    //            if var existingNotes = parent.notes[noteText] {
    //                existingNotes.append(point)
    //                parent.notes[noteText] = existingNotes
    //            } else {
    //                parent.notes[noteText] = [point]
    //            }
    //
    //        }


}
