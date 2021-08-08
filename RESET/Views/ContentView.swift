//
//  ContentView.swift
//  RESET
//
//  Created by Wangyiwei on 2021/5/20.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.colorScheme) private var colorScheme
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ResetItem.lastReset!, ascending: false)],
        animation: .default)
    private var resetItems: FetchedResults<ResetItem>
    
    @State private var showsConfig: Bool = false
    @State private var showsAdding: Bool = false
    @State private var showsHelp: Bool = false
    @State private var showsPrefs: Bool = false
    @State private var refreshMain = false
    @State private var showsWelcome = !defs.bool(forKey: "_FIRST")
    
    @State private var sortRule = 0
    @State private var preferredColor = defs.integer(forKey: "_COLOR")
    @State private var titleText: String? = defs.string(forKey: "_TITLE")
    
    @State private var newTitle: String = ""
    @State private var newIcon = 0
    @State private var newNumYellow: String = "5"
    @State private var newUnitYellow = 1
    @State private var newNumRed: String = "7"
    @State private var newUnitRed = 1
    @State private var newNotes: String = ""
    @State private var newNotificationYellow = false
    @State private var newNotificationRed = false
    @State private var discardConfirm = false

    var body: some View {
        ZStack { //for alignment
            
            //MARK: Contents
            VStack {
                BigTitle()
                if refreshMain {MainContentView()}
                else {MainContentView()}
            }
            
            //MARK: Empty List Placeholder
            if resetItems.count == 0 {
                EmptyTextView()
            }
            
            //MARK: Config View
            if showsConfig {
                ConfigView()
            }
            
            //MARK: Buttons
            BottomButtons()
            
            //MARK: New-Item View
            if showsAdding {
                NewItemView()
                    .onDisappear(perform: {discardConfirm = false})
            }
        }
        //MARK: Navigation
        .fullScreenCover(isPresented: $showsPrefs) {
            PrefsView(updateOutside: {
                preferredColor = defs.integer(forKey: "_COLOR")
                titleText = defs.string(forKey: "_TITLE")
            }).onAppear(perform: {showsConfig = false})
        }
        .sheet(isPresented: $showsHelp) {
            HelpView()
        } //or .popOver
        .fullScreenCover(
            isPresented: $showsWelcome,
            onDismiss: {defs.set(true, forKey: "_FIRST")},
            content: {WelcomeView()}
        )
        //MARK: View Did Appear
        .onAppear(perform: {NCHelper.shared.updateAuth()})
    }
    
    func BigTitle() -> some View {
        Text(titleText ?? "Resetable Items")
            .font(.largeTitle)
            .foregroundColor(Color(userColors[preferredColor]))
            .padding(.top)
    }
    
    func MainContentView() -> some View {
        ScrollView(.vertical, showsIndicators: true) {
            ForEach(self.resetItems.sorted(by: sortRules[sortRule])) {item in
                let resetAction: ()->Void = {
                    item.lastReset = Date()
                    removeNotifications(for: item)
                    if item.yNCID != nil {
                        let yl = Double(Int(item.yellowLimit / 10)) * scalar[Int(item.yellowLimit) % 10]
                        item.yNCID = NCHelper.shared.addNotification("Attention: \(item.title!)", body: "", after: yl)
                    }
                    if item.rNCID != nil {
                        let rl = Double(Int(item.redLimit / 10)) * scalar[Int(item.redLimit) % 10]
                        item.rNCID = NCHelper.shared.addNotification("Warning: \(item.title!)", body: "", after: rl)
                    }
                    do {
                        try viewContext.save()
                    } catch {
                        let nsError = error as NSError
                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                    }
                    refreshMain.toggle()
                    showsConfig = false
                }
                ListItemView(
                    itemTitle: item.title!,
                    itemResetDate: item.lastReset!,
                    itemIconIndex: Int(item.icon),
                    itemResetState: colorIndex(
                        reset: item.lastReset!,
                        yellow: item.yellowLimit,
                        red: item.redLimit),
                    btnAction: resetAction
                ).contextMenu {
                    if let inotes = item.notes {
                        if inotes != "" {
                            Text(inotes)
                        }
                    }
                    Button(action: resetAction, label: {
                        Text("Reset")
                        Image(systemName: "goforward")
                    })
//                    Button(action: {
//                        //TODO: Editing
//                    }, label: {
//                        Text("Edit")
//                        Image(systemName: "doc.plaintext")
//                    })
                    Button(action: {
                        removeNotifications(for: item)
                        viewContext.delete(item)
                        do {
                            try viewContext.save()
                        } catch {
                            let nsError = error as NSError
                            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                        }
                    }, label: {
                        Image(systemName: "trash")
                        Text("Delete")
                    })
                }
                //.padding(.vertical, 10)
            }
        }
    }

    func ConfigView() -> some View {
        VStack {
            Spacer()
            HStack {
                ZStack {
                    Color(.sRGBLinear, white: 0.1, opacity: 1.0)
                            .cornerRadius(35)
                    VStack {
                        Button(action: {showsPrefs = true}, label: {
                            Text("Preferences")
                                .padding(10)
                                .frame(width: 180, height: 50, alignment: .center)
                                .foregroundColor(.white)
                                .background(Color(.sRGBLinear, white: 0, opacity: 0.3))
                                .cornerRadius(30)
                        }).padding(.top, 10)
                        
                        Button(action: {
                            (sortRule < sortRules.count - 1) ? (sortRule += 1) : (sortRule = 0)
                            refreshMain.toggle()
                        }, label: {
                            Text(sortTexts[sortRule])
                                .padding(10)
                                .frame(width: 180, height: 50, alignment: .center)
                                .foregroundColor(.white)
                                .background(Color(.sRGBLinear, white: 0, opacity: 0.3))
                                .cornerRadius(30)
                        })
                        
                        Button(action: {showsHelp = true}, label: {
                            Text("(?) Help")
                                .padding(10)
                                .frame(width: 180, height: 50, alignment: .center)
                                .foregroundColor(.white)
                                .background(Color(.sRGBLinear, white: 0, opacity: 0.3))
                                .cornerRadius(30)
                        })
                        
                        Spacer()
                        HStack{
                            Spacer()
                            Button(action: {
                                UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                                exit(0)
                            }, label: {
                                Image(systemName: "power")
                                    .resizable()
                                    .frame(width: 18, height: 18, alignment: .center)
                                    .scaledToFit()
                                    .foregroundColor(.red)
                                    .frame(width: 50, height: 50, alignment: .center)
                                    .background(Color(.sRGBLinear, white: 0, opacity: 0.2))
                                    .cornerRadius(25)
                            })
                            Button(action: {
                                UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                                showsConfig = false
                            }, label: {
                                Image(systemName: "moon")
                                    .resizable()
                                    .frame(width: 18, height: 18, alignment: .center)
                                    .scaledToFit()
                                    .foregroundColor(.gray)
                                    .frame(width: 50, height: 50, alignment: .center)
                                    .background(Color(.sRGBLinear, white: 0, opacity: 0.2))
                                    .cornerRadius(25)
                            }).padding([.vertical, .trailing], 10)
                        }
                    }
                }.frame(
                    width: 200, height: 250,
                    alignment: .bottomLeading)
                Spacer()
            }.padding(10)
        }.transition(AnyTransition.scale(scale: 0,
            anchor: UnitPoint(
                x: 30 / UIScreen.main.bounds.width,
                y: 1 - 30 / UIScreen.main.bounds.height)
            ).combined(with: .opacity)
        )
    }
    
    func BottomButtons() -> some View {
        VStack {
            Spacer()
            HStack {
                Button(action: {
                    withAnimation(.easeOut(duration: 0.15)) {
                        showsConfig.toggle()
                        showsAdding = false
                    }
                }, label: {
                    Image(systemName: "hammer.fill")
                        .resizable()
                        .frame(width: 30, height: 30, alignment: .center)
                        .scaledToFit()
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60, alignment: .center)
                        .background(Color(userColors[preferredColor]))
                        .cornerRadius(30)
                        .shadow(color: Color.init(.sRGBLinear, white: 0, opacity: 0.5), radius: 5, x: 0, y: 2)
                }).padding(15)
                Spacer()
                Button(action: {
                    withAnimation(.easeOut(duration: 0.15)) {
                        showsConfig = false
                        showsAdding.toggle()
                    }
                }, label: {
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 30, height: 30, alignment: .center)
                        .scaledToFit()
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60, alignment: .center)
                        .background(Color(userColors[preferredColor]))
                        .cornerRadius(30)
                        .shadow(color: Color.init(.sRGBLinear, white: 0, opacity: 0.5), radius: 5, x: 0, y: 2)
                })//overlay
                .padding(15)
            }
        }
    }
    
    func NewItemView() -> some View {
        ZStack {
            //Blank View to prevent touch
            Color(.sRGB, white: 0, opacity: 0.01)
                .transition(.opacity)
            //Contents
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
                    HStack {
                        Button(action: {
                            if discardConfirm || newTitle == "" {
                                withAnimation(.easeOut(duration: 0.15)) {
                                    clearEntries()
                                    showsAdding = false
                                }
                            }
                            discardConfirm.toggle()
                        }, label: {
                            if !discardConfirm {
                                Image(systemName: "xmark")
                                    .resizable()
                                    .frame(width: 18, height: 18, alignment: .center)
                                    .scaledToFit()
                                    .foregroundColor(.white)
                                    .frame(width: 60, height: 40, alignment: .center)
                                    .background(Color.gray)
                                    .cornerRadius(20)
                            } else {
                                Text("Discard?")
                                    .foregroundColor(.white)
                                    .frame(width: 100, height: 40, alignment: .center)
                                    .background(Color.red)
                                    .cornerRadius(20)
                            }
                        }).padding(15)
//                        .transition(.scale)
                        Spacer()
                        Text("New item").font(.title2)
                        Spacer()
                        Button(action: {
                            if newTitle == "" {return}
                            saveResetItem()
                            withAnimation(.easeOut(duration: 0.15)) {
                                showsAdding = false
                            }
                            clearEntries()
                        }, label: {
                            Image(systemName: "checkmark")
                                .resizable()
                                .frame(width: 18, height: 18, alignment: .center)
                                .scaledToFit()
                                .foregroundColor(.white)
                                .frame(width: 60, height: 40, alignment: .center)
                                .background(Color(userColors[preferredColor]))
                                .cornerRadius(20)
                        }).padding(15)
                    }
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        //MARK: Title Entry
                        VStack {
                            TextField("Add a title here", text: $newTitle)
                                .frame(height: 50, alignment: .center)
                                .font(.title2)
                                .padding(.horizontal, 10)
                            //Divider().padding(.horizontal)
                        }
                        //MARK: Icon Selection
                        VStack {
                            HStack {
                                Text("... and pick an icon")
                                    .padding(.leading, 10)
                                Spacer()
                            }
                            Picker("picker", selection: $newIcon) {
                                ForEach(0..<images.count) {nameID in
                                    Image(systemName: images[nameID])
                                }
                            }.pickerStyle(SegmentedPickerStyle())
                            //.pickerStyle(WheelPickerStyle())
                            .frame(height: 50, alignment: .center)
                            .padding(.bottom)
                            Divider().padding(.horizontal)
                        }
                        //MARK: Yellow Date Entry
                        VStack {
                            HStack {
                                Text("After")
                                    .font(.body)
                                    .frame(width: 50, alignment: .center)
                                    .lineLimit(1)
                                TextField("", text: $newNumYellow)
                                    .frame(width: 50, height: 30, alignment: .center)
                                    .font(.title2)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.numberPad)
                                Picker("picker", selection: $newUnitYellow) {
                                    ForEach(0..<timeScales.count) {nameID in
                                        Text(timeScales[nameID])
                                    }
                                }.pickerStyle(SegmentedPickerStyle())
                            }.padding(.vertical)
                            Text("the item will be labeled Attention.")
                                .foregroundColor(.gray)
                                .padding(.horizontal, 10)
                            Toggle("Notify me", isOn: $newNotificationYellow)
                                .foregroundColor(newNotificationYellow ? .green : .secondary)
                                .padding(.horizontal, 50)
                                .padding(.bottom)
                            Divider().padding(.horizontal)
                        }
                        //MARK: Red Date Entry
                        VStack {
                            HStack {
                                Text("After")
                                    .font(.body)
                                    .frame(width: 50, alignment: .center)
                                    .lineLimit(1)
                                Spacer()
                                TextField("", text: $newNumRed)
                                    .frame(width: 50, height: 30, alignment: .center)
                                    .font(.title2)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.numberPad)
                                Picker("picker", selection: $newUnitRed) {
                                    ForEach(0..<timeScales.count) {nameID in
                                        Text(timeScales[nameID])
                                    }
                                }.pickerStyle(SegmentedPickerStyle())
                            }.padding(.vertical)
                            Text("the item will be labeled Warning.")
                                .foregroundColor(.gray)
                                .padding(.horizontal, 10)
                            Toggle("Notify me", isOn: $newNotificationRed)
                                .foregroundColor(newNotificationRed ? .green : .secondary)
                                .padding(.horizontal, 50)
                                .padding(.bottom)
                            Divider().padding(.horizontal)
                        }
                        //MARK: Notes
                        ZStack {
                            VStack {
                                TextEditor(text: $newNotes)
                                    .frame(height: 200, alignment: .center)
                                    .padding(.horizontal)
                                Divider()
                            }
                            if newNotes == "" {
                                Text("Add notes here")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }.padding([.bottom, .horizontal], 10)
                
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 50)
        }
        .transition(
            .asymmetric(
                insertion: AnyTransition.scale(
                    scale: 0,
                    anchor: UnitPoint(
                        x: 1 - 30 / UIScreen.main.bounds.width,
                        y: 1 - 30 / UIScreen.main.bounds.height)
                ).combined(with: .opacity),
                removal: AnyTransition.scale(scale: 0.95)
                    .combined(with: .opacity)
            )
        )
    }
    
    func EmptyTextView() -> some View {
        VStack {
            Text("Nothing here")
                .font(.title)
                .foregroundColor(.gray)
            Text("Press (+) to get started")
                .font(.headline)
                .foregroundColor(.gray)
                .padding(.top)
        }
    }
    
    private func saveResetItem() {
        withAnimation {
            let newItem = ResetItem(context: viewContext)
            newItem.lastReset = Date()
            newItem.id = UUID()
            newItem.icon = Int32(newIcon)
            newItem.title = newTitle
            newItem.notes = newNotes
            let numYellow = Int(newNumYellow) ?? 1
            let numRed = Int(newNumRed) ?? 2
            newItem.yellowLimit = Int32(numYellow * 10 + newUnitYellow)
            newItem.redLimit = Int32(numRed * 10 + newUnitRed)
            //notifications
            if newNotificationYellow {
                let yl = Double(Int(newItem.yellowLimit / 10)) * scalar[Int(newItem.yellowLimit) % 10]
                newItem.yNCID = NCHelper.shared.addNotification("Attention: \(newItem.title!)", body: "", after: yl)
            }
            if newNotificationRed {
                let rl = Double(Int(newItem.redLimit / 10)) * scalar[Int(newItem.redLimit) % 10]
                newItem.rNCID = NCHelper.shared.addNotification("Warning: \(newItem.title!)", body: "", after: rl)
            }
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func removeNotifications(for item: ResetItem) {
        let validNotifications = [item.yNCID, item.rNCID]
            .filter({$0 != nil}).map({$0!})
        NCHelper.shared.removeNotification(validNotifications)
    }
    
    private func clearEntries() {
        newTitle = ""
        newIcon = 0
        newNumYellow = "5"
        newUnitYellow = 1
        newNumRed = "7"
        newUnitRed = 1
        newNotes = ""
        newNotificationYellow = false
        newNotificationRed = false
    }
    
    let sortRules: [((ResetItem, ResetItem) -> Bool)] = [
        {$0.lastReset! > $1.lastReset!},
        {$0.title! < $1.title!},
        {i0, i1 in
            let (s0, t0) = priority(i0)
            let (s1, t1) = priority(i1)
            if s0 != s1 {return s0 > s1}
            return t0 > t1
        }
    ]
    
    let sortTexts: [String] = [
        "↑↓ Recent", "↑↓ Name", "↑↓ Attention"
    ]
}

private func priority(_ item: ResetItem) -> (UInt8, Double) {
    let reset = item.lastReset!
    let yellow = item.yellowLimit
    let red = item.redLimit
    
    let interval = reset.distance(to: Date())
    let yl = Double(Int(yellow / 10)) * scalar[Int(yellow) % 10]
    let rl = Double(Int(red / 10)) * scalar[Int(red) % 10]

    if interval > yl {return interval > rl ? (2, interval - rl) : (1, interval - yl)}
    return (0, interval)
}

private func colorIndex(reset: Date, yellow: Int32, red: Int32) -> Int {
    let interval = reset.distance(to: Date())
    let yl = Double(Int(yellow / 10)) * scalar[Int(yellow) % 10]
    let rl = Double(Int(red / 10)) * scalar[Int(red) % 10]
    if interval > rl {return 2}
    else if interval > yl {return 1}
    else {return 0}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.light)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
