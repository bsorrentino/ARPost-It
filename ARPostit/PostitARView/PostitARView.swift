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
    
    
    /// Places a new post-it note on a specified ARAnchor with the provided text.
    ///
    /// This function creates an AnchorEntity from the provided ARAnchor, adds it to the scene, and then creates a new NoteEntity with the provided text.
    ///
    /// - Parameters:
    ///   - anchor: The ARAnchor on which to place the new post-it note.
    ///   - text: The text to be displayed on the new post-it note.
    ///
    /// - Note:
    ///   The NoteEntity.addNew(on:text:) function is assumed to create a new NoteEntity and attach it to the specified AnchorEntity.

    func placePostit( on anchor: ARAnchor, text: String  ) {
        let anchorEntity = AnchorEntity(world: anchor.transform)
        self.scene.addAnchor(anchorEntity)

        let _ = NoteEntity.addNew( on: anchorEntity, text: "New Note" )
        
    }

    
    fileprivate func placePostit3( on anchor: ARAnchor, text: String )  {
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
    

}
