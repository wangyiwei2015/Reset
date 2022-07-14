//
//  ListItemView.swift
//  RESET
//
//  Created by Wangyiwei on 2021/5/20.
//

import SwiftUI

struct ListItemView: View {
    
    @State var itemTitle: String
    @State var itemResetDate: Date
    @State var itemIconIndex: Int
    @State var itemResetState: Int
    @State var btnAction: (()->Void)
    //@Binding
    
    var body: some View {
        ZStack {
            Color.clear.frame(height: 64, alignment: .center)

            HStack {
                Image(systemName: images[itemIconIndex])
                    .resizable().scaledToFit()
                    .frame(width: 36, height: 36, alignment: .center)
                    .padding(.leading)
                
                VStack {
                    HStack {
                        Text(itemTitle)
                            .font(.title3)
                            .frame(height: 22, alignment: .leading)
                            .lineLimit(1)
                        Spacer()
                    }
                    HStack {
                        Text(resetFormatter.string(from: itemResetDate))
                            .frame(height: 22, alignment: .center)
                            .font(.footnote)
                            .foregroundColor(.gray)
                        Spacer()
                        Text(texts[itemResetState])
                            .foregroundColor(colors[itemResetState])
                            .frame(height: 22, alignment: .center)
                    }
                }
                
//                Button(action: btnAction, label: {
//                    Image(systemName: "goforward")
//                        .resizable().scaledToFit()
//                        .foregroundColor(Color.secondary)
//                        .frame(width: 32, height: 32, alignment: .center)
//                        .padding(.horizontal)
//                })//.onLongPressGesture(perform: btnAction)
            }.padding(.trailing)
            .background()
        }
    }
}

private let resetFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "YYYY-MM-dd | HH:mm:ss"
    return formatter
}()

struct ListItemView_Previews: PreviewProvider {
//    @State static var t = "Test Title"
//    @State static var r = Date()
//    @State static var i = 0
//    @State static var s = 1
//    @State static var a: (()->Void) = {}
    static var previews: some View {
        ListItemView(
            itemTitle: "Test-title",
            itemResetDate: Date(),
            itemIconIndex: 0,
            itemResetState: 1,
            btnAction: {}
        )
    }
}
