//
//  PrefsView.swift
//  RESET
//
//  Created by Wangyiwei on 2021/5/22.
//

import SwiftUI
import StoreKit

struct PrefsView: View {
    
    @Environment(\.presentationMode) var mode
    @Environment(\.colorScheme) private var colorScheme
    @State private var preferredColor = defs.integer(forKey: "_COLOR")
    @State private var showsMail = false
    @State private var showsEditor = false
    @State private var titleText = defs.string(forKey: "_TITLE") ?? ""
    var updateOutside: (()->Void)? = nil
    
    var body: some View {
        ZStack {
            VStack {
                Text("Preferences")
                    .font(.largeTitle)
                    .foregroundColor(Color(userColors[preferredColor]))
                    .padding(.top)
                ScrollView(.vertical, showsIndicators: true, content: {
                    VStack {
                        ColorConfig()
                            .padding(.bottom)
                        CustomTitler()
                        //SampleConfig()
                        //DebugButtons()
                        VersInfo()
                        BtmButtons()
                    }
                })
            }
            DismissButton()
            if showsEditor {TitleEditor()}
        }.fullScreenCover(isPresented: $showsMail, content: {MailView()})
    }
    
    @ViewBuilder
    func ColorConfig() -> some View {
        //MARK: User Color
        HStack {
            Text("Color scheme")
                .font(.title2)
                .padding([.leading, .top])
            Spacer()
        }
        HStack {
            ForEach(0..<userColors.count, id: \.self) {id in
                Button(action: {
                    preferredColor = id
                    defs.set(id, forKey: "_COLOR")
                    updateOutside?()
                }, label: {
                    Color(userColors[id])
                        .frame(width: 40, height: 40, alignment: .center)
                        .cornerRadius(20)
                        .overlay(
                            (preferredColor == id ? Color.white : Color.clear)
                                .frame(width: 16, height: 16, alignment: .center)
                                .cornerRadius(8)
                        )
                })
            }
        }
    }
    
    @ViewBuilder
    func DismissButton() -> some View {
        VStack {
            HStack {
                Button(action: {
                    mode.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "chevron.left")
                        .font(.title)
                        .foregroundColor(Color(userColors[preferredColor]))
                        .frame(height: 56, alignment: .center)
                        .padding(.leading)
                        .padding(.top, 10)
                })
                Spacer()
            }
            Spacer()
        }
    }
    
    @ViewBuilder
    func SampleConfig() -> some View {
        //Config 1
        Toggle(isOn: .constant(true), label: {
            Text("pref1").font(.title2)
        }).toggleStyle(
            SwitchToggleStyle(tint: Color(userColors[preferredColor]))
        ).padding([.horizontal, .top])
        //Config 2
        Toggle(isOn: .constant(true), label: {
            Text("pref2").font(.title2)
        }).toggleStyle(
            SwitchToggleStyle(tint: Color(userColors[preferredColor]))
        ).padding([.horizontal, .top])
        //Config 3
        Toggle(isOn: .constant(false), label: {
            Text("pref3").font(.title2)
        }).toggleStyle(
            SwitchToggleStyle(tint: Color(userColors[preferredColor]))
        ).padding([.horizontal, .top])
        //Config 4
        Toggle(isOn: .constant(false), label: {
            Text("pref4").font(.title2)
        }).toggleStyle(
            SwitchToggleStyle(tint: Color(userColors[preferredColor]))
        ).padding([.horizontal, .top])
    }
    
    @ViewBuilder
    func BtmStyledLabel(_ systemName: String) -> some View {
        Image(systemName: systemName)
            .font(.title3)
            .frame(maxWidth: .infinity, minHeight: 50, alignment: .center)
            .foregroundColor(.white)
            .background(Color(userColors[preferredColor]))
            .cornerRadius(20)
            .padding(.bottom)
    }
    
    @ViewBuilder
    func BtmButtons() -> some View {
        HStack {
            Color.clear.frame(width: 20, alignment: .center)
            Button {
                showsMail = true
            } label: {
                BtmStyledLabel("envelope.fill")
            }
            Button {
                SKStoreReviewController.requestReview()
            } label: {
                BtmStyledLabel("star.fill")
            }
            Button {
                UIApplication.shared.open(
                    URL(string: UIApplication.openSettingsURLString)!,
                    options: [:], completionHandler: nil
                )
            } label: {
                BtmStyledLabel("gearshape.fill")
            }
            Color.clear.frame(width: 20, alignment: .center)
        }
    }
    
    @ViewBuilder
    func DebugButtons() -> some View {
        Button("Debug") {
            print("debug action")
            print(NCHelper.shared.test() ?? "no return value")
        }
    }
    
    @ViewBuilder
    func VersInfo() -> some View {
        HStack {
            Text("v\(ver) (\(build))  •")
                .foregroundColor(.gray)
            Image(systemName: "swift")
                .foregroundColor(.gray)
                .offset(y: -1)
            Text("SwiftUI")
                .foregroundColor(.gray)
        }.padding(.top)
    }
    
    @ViewBuilder
    func CustomTitler() -> some View {
        HStack {
            Text("Custom title").font(.title2)
            Spacer()
            Button(action: {
                withAnimation(.easeOut(duration: 0.15)) {
                    showsEditor = true
                }
            }, label: {
                Text("Edit").font(.title2)
                    .foregroundColor(Color(userColors[preferredColor]))
            })
        }.padding([.horizontal, .top])
    }
    
    @ViewBuilder
    func TitleEditor() -> some View {
        ZStack {
            //Blank View to prevent touch
            Color(.sRGB, white: 0, opacity: 0.3)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .edgesIgnoringSafeArea([.top, .bottom])
            ZStack {
                if colorScheme == .light {
                    Color.white
                        .cornerRadius(35)
                        .shadow(color: .gray, radius: 10, x: 0.0, y: 5.0)
                } else {
                    Color(.sRGB, white: 0.2, opacity: 1.0)
                        .cornerRadius(35)
                }
                VStack {
                    //Buttons
                    HStack {
                        Button(action: {
                            withAnimation(.easeOut(duration: 0.15)) {
                                showsEditor = false
                            }
                            titleText = defs.string(forKey: "_TITLE") ?? ""
                        }, label: {
                            Image(systemName: "xmark")
                                .resizable()
                                .frame(width: 18, height: 18, alignment: .center)
                                .scaledToFit()
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40, alignment: .center)
                                .background(Color.gray)
                                .cornerRadius(20)
                            
                        })//.padding(15)
                        Spacer()
                        Text("Title").font(.title2)
                        Spacer()
                        Button(action: {
                            if titleText == "" {defs.removeObject(forKey: "_TITLE")}
                            else {defs.set(titleText, forKey: "_TITLE")}
                            updateOutside?()
                            withAnimation(.easeOut(duration: 0.15)) {
                                showsEditor = false
                            }
                        }, label: {
                            Image(systemName: "checkmark")
                                .resizable()
                                .frame(width: 18, height: 18, alignment: .center)
                                .scaledToFit()
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40, alignment: .center)
                                .background(Color(userColors[preferredColor]))
                                .cornerRadius(20)
                        })//.padding(15)
                    }.padding([.horizontal, .top], 15)
                    //TextField
                    TextField("Resetable Items", text: $titleText)
                        .submitLabel(.done)
                        .font(.title)
                        .frame(height: 60)
                        .padding(.horizontal, 10)
                    Spacer()
                }
            }
            .frame(height: 150, alignment: .center)
            .padding(.horizontal, 10)
        }
        .transition(.opacity)
    }
}

struct PrefsView_Previews: PreviewProvider {
    static var previews: some View {
        PrefsView()
            
    }
}
