//
//  PrefsView.swift
//  RESET
//
//  Created by Wangyiwei on 2021/5/22.
//

import SwiftUI

struct PrefsView: View {
    
    @Environment(\.presentationMode) var mode
    
    var body: some View {
        ZStack {
            VStack {
                Text("Preferences").font(.largeTitle).padding(.top)
                ScrollView(.vertical, showsIndicators: true, content: {
                    VStack {
                        //Config 1
                        Toggle(isOn: .constant(true), label: {
                            Text("pref1").font(.title2)
                        }).padding()
                        //Config 2
                        Toggle(isOn: .constant(true), label: {
                            Text("pref2").font(.title2)
                        }).padding()
                        //Config 3
                        Toggle(isOn: .constant(true), label: {
                            Text("pref3").font(.title2)
                        }).padding()
                        //Config 4
                        Toggle(isOn: .constant(true), label: {
                            Text("pref4").font(.title2)
                        }).padding()
                        //Config 5
                        Toggle(isOn: .constant(true), label: {
                            Text("pref5").font(.title2)
                        }).padding()
                    }
                })
            }
            VStack {
                Spacer()
                Button(action: {
                    mode.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 18, height: 18, alignment: .center)
                        .scaledToFit()
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56, alignment: .center)
                        .background(Color(.sRGBLinear, white: 0, opacity: 0.3))
                        .cornerRadius(28)
                        .padding(.bottom)
                })
            }
        }
    }
}

struct PrefsView_Previews: PreviewProvider {
    static var previews: some View {
        PrefsView()
    }
}
