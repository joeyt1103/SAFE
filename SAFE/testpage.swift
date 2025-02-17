//
//  testpage.swift
//  SAFE
//
//  Created by Kevin Gualano on 9/27/24.
//

import SwiftUI

struct TestView: View {
    var body: some View {
        VStack {
            Text("Outer VStack - Top")
                .font(.title)
                .padding()

            HStack {
                VStack {
                    Text("Inner VStack - Left")
                    Text("Text 1")
                    Text("Text 2")
                }
                .padding()

                VStack {
                    Text("Inner VStack - Right")
                    Text("Text 3")
                    Text("Text 4")
                }
                .padding()
            }
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)

            Text("Outer VStack - Bottom")
                .padding()
        }
        .padding()
    }
}

struct TesttView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
