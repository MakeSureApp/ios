//
//  View+Ext.swift
//  MakeSure
//
//  Created by Macbook Pro on 30.06.2023.
//

import SwiftUI
import Foundation

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
    
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
            
            ZStack(alignment: alignment) {
                placeholder().opacity(shouldShow ? 1 : 0)
                self
            }
        }
    func customAlert(isPresented: Binding<Bool>, title: String, btnText: String, placeholder: String = "", onDone: @escaping (String) -> Void) -> some View {
        @State var text: String = ""
        
        return ZStack {
            self
            
            if isPresented.wrappedValue {
                // Semi-transparent background
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        isPresented.wrappedValue = false
                    }
                
                // Custom alert view
                VStack(spacing: 20) {
                    Text(title)
                        .font(.headline)
                        .padding()
                    
                    TextField(placeholder, text: $text)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding([.horizontal, .bottom])
                    
                    Button(btnText) {
                        onDone(text)
                        isPresented.wrappedValue = false
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
                .frame(width: 300)
                .background(Color.white)
                .cornerRadius(15)
                .shadow(radius: 10)
                .transition(.opacity)
                .animation(.easeInOut)
            }
        }
    }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
