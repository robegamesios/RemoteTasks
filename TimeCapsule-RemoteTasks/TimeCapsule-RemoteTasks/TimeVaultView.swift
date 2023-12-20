//
//  ContentView.swift
//  TimeCapsule-RemoteTasks
//
//  Created by Rob Enriquez on 12/20/23.
//

import SwiftUI

struct TimeVaultView: View {
    @State private var timeVaultEntries: [TimeVaultEntry] = []
    @State private var selectedVaultEntry: TimeVaultEntry? = nil
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Time Vault")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()

                Spacer()

                List {
                    if timeVaultEntries.isEmpty {
                        Text("No time vault memories created")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(timeVaultEntries) { entry in
                            NavigationLink(destination: VaultDetailView(entry: entry)) { // Add NavigationLink
                                Text(entry.comment.split(separator: "\n").first ?? "")
                            }
                        }
                    }
                }

                Spacer()

                NavigationLink(destination: CreateTimeVaultView(timeVaultEntries: $timeVaultEntries)) {
                    Image(systemName: "plus.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.accentColor)
                }
                .padding(.bottom)
            }
            .navigationBarHidden(true) // Adjust as needed
            
        }
    }
}

struct VaultDetailView: View {
    let entry: TimeVaultEntry

    var body: some View {
        ScrollView {
            VStack {
                // Display photos (adapt as needed)
                ForEach(entry.photos, id: \.self) { photo in
                    Image(uiImage: UIImage(data: photo)!) // Assuming photos is Data
                        .resizable()
                        .scaledToFit()

                }

                Text(entry.comment)
            }
        }
    }
}

struct TimeVaultEntry: Identifiable {
    let id = UUID()
    let photos: [Data] // Placeholder, adapt to your photo storage
    let comment: String
    let openDate: Date
}

struct CreateTimeVaultView: View {
    @Environment(\.dismiss) var dismiss

    @State private var selectedImages: [UIImage] = []
    @State private var isShowingImagePicker = false
    @State private var comment: String = ""
    @State private var selectedDate: Date = Date()
    @State private var isShowingDatePicker = false
    @Binding var timeVaultEntries: [TimeVaultEntry]

    
    var body: some View {
        VStack {
            HStack {
                Button("Select Photos") {
                    isShowingImagePicker = true
                }
                Spacer()
            }
            .padding(.horizontal)
            
            ImageGrid(images: selectedImages)
            
            Spacer()
            
            VStack(spacing: 0) {
                Divider()
                
                Button("Select Date to Open Vault") {
                    isShowingDatePicker = true
                }
                .buttonStyle(.bordered)
                .padding(.bottom, 10)
                
                TextEditor(text: $comment)
                    .frame(height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                    .background(Color.gray.opacity(0.2))
                    .padding(.horizontal, 16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.gray.opacity(0.5))
                            .padding(.horizontal, 8)
                    )
                    .overlay(alignment: .topLeading) {
                        if comment.isEmpty {
                            Text("Type your thoughts here")
                                .foregroundColor(.gray.opacity(0.8))
                                .font(.callout)
                                .padding(.horizontal, 16)
                                .padding(.top, 8)
                        }
                    }
                    .padding(.bottom, 20)
                    .onChange(of: selectedDate) {
                        if selectedDate != Date() {
                            let formattedDate = formattedDate(from: selectedDate)
                            if let firstLineEndIndex = comment.firstIndex(of: "\n") {
                                comment.replaceSubrange(...firstLineEndIndex, with: "\(formattedDate)\n")
                            } else {
                                comment = "\(formattedDate)\n"
                            }
                        }
                    }
                
                Button("Create TimeVault") {
                    // 1. Convert photos and comment to data as needed
                    let photoData = selectedImages.compactMap { image -> Data? in
                        return image.jpegData(compressionQuality: 0.8)
                    }
                    // 2. Create TimeVaultEntry instance
                    let newEntry = TimeVaultEntry(
                        photos: photoData,
                        comment: comment,
                        openDate: selectedDate
                    )
                    
                    // 3. Append to the array
                    timeVaultEntries.append(newEntry)
                    
                    // 4. Navigate back (adjust the navigation mechanism if needed)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .padding(.bottom)
            }
            .sheet(isPresented: $isShowingDatePicker) {
                DatePickerView(selectedDate: $selectedDate, isShowingDatePicker: $isShowingDatePicker)
            }
            .sheet(isPresented: $isShowingImagePicker) {
                MultiImagePicker(selectedImages: $selectedImages)
            }
        }
    }
}

private func formattedDate(from date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM dd, yyyy" // Customize as needed
    return formatter.string(from: date)
}

struct DatePickerView: View {
    @Binding var selectedDate: Date
    @Binding var isShowingDatePicker: Bool
    
    var body: some View {
        VStack {
            DatePicker(
                "Select Date",
                selection: $selectedDate,
                in: Date()..., // Starts from today
                displayedComponents: .date
            )
            .datePickerStyle(.graphical) // Modern style

            Button("Select") {
                isShowingDatePicker = false // Dismiss the sheet
            }
        }
    }
}

struct ImageGrid: View {
    let images: [UIImage]
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3) // 3 columns

    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(images, id: \.self) { image in
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }
        }
        .padding()
    }
}

struct MultiImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary // Adjust source type as needed
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: MultiImagePicker

        init(_ parent: MultiImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImages.append(image)
            }
            picker.dismiss(animated: true)
        }
    }
}

#Preview {
    TimeVaultView()
}
