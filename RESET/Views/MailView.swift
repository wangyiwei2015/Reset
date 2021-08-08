//
//  MailView.swift
//  RESET
//
//  Created by Wangyiwei on 2021/6/14.
//

import SwiftUI
import MessageUI

struct MailView: UIViewControllerRepresentable {
    typealias UIViewControllerType = MFMailComposeViewController
    @Environment(\.presentationMode) var mode
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let ver = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String? ?? "0"
        let build = Bundle.main.infoDictionary!["CFBundleVersion"] as! String? ?? "0"
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = context.coordinator
        composer.setSubject("[Reset] Feedback")
        composer.setToRecipients(["wangyw.dev@outlook.com"])
        composer.setMessageBody("\n\n\n\n--- Please type above this line ---\n\nv\(ver)(\(build)) on \(UIDevice.current.model) @\(UIDevice.current.systemVersion)", isHTML: false)
        return composer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {
        //
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding var presentation: PresentationMode
        
        init(presentation: Binding<PresentationMode>) {
            _presentation = presentation
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            $presentation.wrappedValue.dismiss()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(presentation: mode)
    }
}
