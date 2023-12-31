//
//  NoteView.swift
//  ARPostit
//
//  Created by Bartolomeo Sorrentino on 25/07/23.
//

import SwiftUI

struct NoteView: View {
    let text: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.yellow)
                .frame(width: 150, height: 100)
            Text(text)
                .multilineTextAlignment(.center)
                .padding()
        }
    }
}

#Preview {
    NoteView(text: "my note")
}
