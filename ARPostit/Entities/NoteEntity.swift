//
//  NoteEntity.swift
//  ARPostit
//
//  Created by Bartolomeo Sorrentino on 27/07/23.
//

import RealityKit
import ARKit


func makeNoteEntity( text: String ) -> ModelEntity {
            
    let textMesh = MeshResource.generateText(text,
                                             extrusionDepth: 1,
                                             font: .systemFont(ofSize: 0.1),
                                             containerFrame: CGRect.zero,
                                             alignment: .center,
                                             lineBreakMode: .byTruncatingTail)
    
    let textMaterial = SimpleMaterial(color: .yellow,
                                      isMetallic: false)
    
    return ModelEntity(mesh: textMesh, materials: [textMaterial])
    
}
