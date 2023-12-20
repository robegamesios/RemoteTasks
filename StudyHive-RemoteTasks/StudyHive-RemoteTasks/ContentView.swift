//
//  ContentView.swift
//  StudyHive-RemoteTasks
//
//  Created by Rob Enriquez on 12/18/23.
//

import SwiftUI
import UniformTypeIdentifiers

struct StudyGroup {
    let name: String
    let description: String
}

struct StudyGroupCard: View {
    let group: StudyGroup
    
    var body: some View {
        NavigationLink(destination: StudyGroupDescription(group: group)) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .shadow(radius: 3)
                Text(group.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
            }
            .frame(width: 200, height: 100)
        }
    }
}

struct StudyGroupSession: View {
    let groupName: String
    @State private var newMessage = ""
    @State private var messages = sampleMessages
    
    var body: some View {
        VStack {
            Text("Live Session: \(groupName)")
                .font(.title)
                .bold()
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(messages, id: \.id) { message in
                        ChatMessageRow(message: message)
                    }
                }
                .padding()
            }
            HStack {
                TextField("Type your message...", text: $newMessage)
                    .padding()
                Button("Send") {
                    sendMessage()
                }
            }
            .padding(.top)
        }
        .padding()
    }
    
    func sendMessage() {
        if !newMessage.isEmpty {
            let message = ChatMessage(id: UUID(), sender: "Your User", text: newMessage)
            messages.append(message)
            newMessage = ""
        }
    }
}

struct ChatMessage: Identifiable {
    let id: UUID
    let sender: String
    let text: String
}

let sampleMessages = [
    ChatMessage(id: UUID(), sender: "User A", text: "Hello, everyone!"),
    ChatMessage(id: UUID(), sender: "User B", text: "Hi, how's it going?")
]

struct ChatMessageRow: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            Text(message.sender + ":")
            Text(message.text)
        }
    }
}

struct StudyGroupDescription: View {
    let group: StudyGroup
    @State private var isShowingFilePicker = false
    
    var body: some View {
        VStack {
            Text(group.name)
                .font(.title)
                .bold()
            Text("Description: \(group.description)")
            Spacer()
            NavigationLink(destination: StudyGroupSession(groupName: group.name)) {
                Text("Join Session")
            }
            .padding(.bottom, 20)
            Button("Upload File") {
                isShowingFilePicker = true
            }
            .padding(.bottom, 20)
        }
        .padding()
        .sheet(isPresented: $isShowingFilePicker) {
            FilePickerView()
        }
    }
}

struct FilePickerView: UIViewControllerRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.item], asCopy: false)
        documentPicker.allowsMultipleSelection = false
        documentPicker.delegate = context.coordinator
        documentPicker.modalPresentationStyle = .formSheet

        return documentPicker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        // No updates needed in this case
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: FilePickerView

        init(_ parent: FilePickerView) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return } // Handle if no file is selected
            // Add logic to read file contents and upload using 'url'
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            // Handle if the user cancels the picker
        }
    }
}

struct ContentView: View {
    @State private var isCreatingGroup = false // State variable for creation prompt
    @State private var newGroupName = "" // State variable for group name input
    @State private var newGroupDescription = ""
    @State private var studyGroups = [
        StudyGroup(name: "Calculus 101", description: "Calculus study group"),
        StudyGroup(name: "Intro to Biology", description: "Biology topics overview"),
        StudyGroup(name: "Web Development", description: "Learning web technologies")
    ]

    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                VStack {
                    Text("Study Hive")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom, 20)
                    
                    ForEach(studyGroups, id: \.name) { group in
                        StudyGroupCard(group: group)
                            .padding(.trailing, 10)
                    }

                    Button("Create Group") {
                        isCreatingGroup = true // Show creation prompt
                    }
                    .padding(.bottom, 20)
                }
                .padding()
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $isCreatingGroup) { // Sheet for group creation
            VStack {
                Text("New Study Group")
                    .font(.title2).bold()
                TextField("Group Name", text: $newGroupName)
                    .padding()
                TextField("Description", text: $newGroupDescription)
                    .padding()
                Button("Create") {
                    if !newGroupName.isEmpty && !newGroupDescription.isEmpty {
                        studyGroups.append(StudyGroup(name: newGroupName, description: newGroupDescription))
                        newGroupName = ""
                        newGroupDescription = ""
                    }
                    isCreatingGroup = false // Dismiss the sheet
                }
                .padding()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
