//
//  HelpView.swift
//  RESET
//
//  Created by Wangyiwei on 2021/6/11.
//

import SwiftUI

struct HelpView: View {
    var body: some View {
        VStack {
            HStack {
                Text("↓ Swipe to dismiss")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding()
                Spacer()
            }
            ScrollView {
                Text("No help available")
                Text("v\(ver) (\(build))")
            }
        }
    }
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView()
    }
}
