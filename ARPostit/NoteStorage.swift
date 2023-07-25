//
//  NoteStorage.swift
//  ARPostit
//
//  Created by Bartolomeo Sorrentino on 25/07/23.
//

import Foundation
import Combine

class NotesStorage: ObservableObject {
    @Published var savedNotes: [String: [CGPoint]] {
        didSet {
            UserDefaults.standard.setValue(savedNotes, forKey: "SavedNotes")
        }
    }
    
    init() {
        if let notes = UserDefaults.standard.value(forKey: "SavedNotes") as? [String: [CGPoint]] {
            self.savedNotes = notes
        } else {
            self.savedNotes = [:]
        }
    }
}
