//
//  ContentView.swift
//  UdemyTutorials
//
//  Created by Rob Enriquez on 12/19/23.
//

import SwiftUI

extension Image {
    func imageModifier() -> some View {
        self
            .resizable()
            .scaledToFit()
    }
    
    func iconModifier() -> some View {
        self
            .imageModifier()
            .frame(maxWidth: 128)
            .foregroundColor(.purple)
            .opacity(0.5)
    }
}

struct ContentView: View {
    var body: some View {
        CardView()
    }
}

#Preview {
    ContentView()
}
