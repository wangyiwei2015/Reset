//
//  WelcomeView.swift
//  RESET
//
//  Created by Wangyiwei on 2021/6/13.
//

import SwiftUI

struct WelcomeView: View {
    
    @Environment(\.presentationMode) var mode
    
    var body: some View {
        VStack {
            Text("Welcome")
                .font(.largeTitle)
                .padding(40)
            //Image()
            Text(welcomeMsg)
                .font(.body)
                .padding()
            Spacer()
            Button(action: {
                mode.wrappedValue.dismiss()
            }, label: {
                Text("Enter Reset")
                    .font(.title)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(16.0)
                    .padding([.horizontal, .bottom], 20)
            })
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
