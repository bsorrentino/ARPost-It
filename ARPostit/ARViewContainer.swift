//
//  ARViewContainer.swift
//  ARPostit
//
//  Created by Bartolomeo Sorrentino on 25/07/23.
//

import SwiftUI
import ARKit
import RealityKit

extension CGPoint: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

struct ARViewContainer: View {
    @StateObject private var notesStorage = NotesStorage()
    @State private var notes: [String: [CGPoint]] = [:]
    
    var body: some View {
        ARViewContainerRepresentable(notes: $notes)
            .environmentObject(notesStorage)
            .onAppear {
                notes = notesStorage.savedNotes
            }
            .overlay(
                ZStack {
                    ForEach(notes.keys.sorted(), id: \.self) { key in
                        Group {
                            if let positions = notes[key] {
                                ForEach(positions, id: \.self) { position in
                                    TextNoteView(text: key)
                                        .position(position)
                                }
                            }
                        }
                    }
                }
            )
    }
}

struct ARViewContainerRepresentable: UIViewRepresentable {
    @Binding var notes: [String: [CGPoint]]

    let arView = ARView(frame: .zero)
    let configuration = ARWorldTrackingConfiguration()
    
    
    func makeUIView(context: Context) -> ARView {
        
        configuration.planeDetection = [.vertical]
        arView.session.run(configuration)

        let tapGesture = UITapGestureRecognizer(target: context.coordinator,
                                                action: #selector(context.coordinator.addNoteToWall(_:)))
        /*
        let tapGesture = UITapGestureRecognizer(target: context.coordinator,
                                                action: #selector(context.coordinator.handleTap(_:)))
         */
        arView.addGestureRecognizer(tapGesture)
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: ARViewContainerRepresentable
        
        init(_ parent: ARViewContainerRepresentable) {
            self.parent = parent
        }
        
// FROM PHIND
//
//        @objc func handleTap(_ sender: UITapGestureRecognizer) {
//            let location = sender.location(in: parent.arView)
//            let results = parent.arView.raycast(from: location,
//                                                     allowing: .estimatedPlane,
//                                                     alignment: .vertical)
//
//            if let firstResult = results.first {
//                let anchor = ARAnchor(name: "text", transform: firstResult.worldTransform)
//                parent.arView.session.add(anchor: anchor)
//            }
//        }

        @objc func addNoteToWall(_ sender: UITapGestureRecognizer) {
            let arView = parent.arView
            let tapLocation = sender.location(in: arView)
            if let hitTestResult = arView.hitTest(tapLocation, types: .existingPlane).first {
                let position = SCNVector3(hitTestResult.worldTransform.columns.3.x,
                                         hitTestResult.worldTransform.columns.3.y,
                                         hitTestResult.worldTransform.columns.3.z)
                
                let anchor = ARAnchor(name: "Note", transform: hitTestResult.worldTransform)
                arView.session.add(anchor: anchor)
                
                let noteText = "New Note"
                if var existingNotes = parent.notes[noteText] {
                    existingNotes.append(CGPoint(x: CGFloat(position.x), y: CGFloat(position.y)))
                    parent.notes[noteText] = existingNotes
                } else {
                    parent.notes[noteText] = [CGPoint(x: CGFloat(position.x), y: CGFloat(position.y))]
                }
            }
        }
    }
}

    //extension ARViewContainerRepresentable {
    //    var arView: ARView {
    //        (UIApplication.shared.windows.first?.rootViewController as! UIHostingController<ARViewContainer>).arView
    //    }
    //}

#Preview {
    ARViewContainer()
}
