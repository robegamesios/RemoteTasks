//
//  ContentView.swift
//  EduStream-RemoteTasks
//
//  Created by Rob Enriquez on 12/18/23.
//

import SwiftUI
import AVKit

// Data model for a video
struct Video: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let description: String
    let thumbnailURL: URL
    let videoURL: URL
    var rating: Double? // Add a property to hold the rating (average or user-specific)
}

// Main view displaying a list of videos
struct VideoListView: View {
    // Sample video data (replace with your actual data source)
    let videos = [
        Video(title: "Introduction to Physics", description: "Explore the fundamental laws of motion.", thumbnailURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/b/bc/Refresh_icon.png")!, videoURL: URL(string: "https://example.com/physicsvideo.mp4")!, rating: 4.5),
        Video(title: "The Wonders of Biology", description: "Discover the intricate workings of living organisms.", thumbnailURL: URL(string: "https://example.com/biology.jpg")!, videoURL: URL(string: "https://example.com/biologyvideo.mp4")!, rating: 4.5),
        Video(title: "Mathematical Mysteries", description: "Unravel the beauty and power of mathematics.", thumbnailURL: URL(string: "https://example.com/math.jpg")!, videoURL: URL(string: "https://example.com/mathvideo.mp4")!, rating: 4.5),
        Video(title: "Historical Journeys", description: "Travel through time and explore pivotal events.", thumbnailURL: URL(string: "https://example.com/history.jpg")!, videoURL: URL(string: "https://example.com/historyvideo.mp4")!, rating: 4.5),
        Video(title: "Coding Fundamentals", description: "Learn the basics of computer programming.", thumbnailURL: URL(string: "https://example.com/coding.jpg")!, videoURL: URL(string: "https://example.com/codingvideo.mp4")!, rating: 4.5)
    ]
    
    @State private var selectedVideo: Video?
    
    var body: some View {
        NavigationView {
            List(videos) { video in
                NavigationLink(destination: VideoPlayerView(video: video)) {
                    VideoRow(video: video)
                }
            }
            .navigationTitle("Educational Videos")
            .navigationDestination(for: Video.self) { video in
                VideoPlayerView(video: video)
            }
        }
    }
}

// Row representation of a video in the list
struct VideoRow: View {
    let video: Video
    
    var body: some View {
        HStack {
            AsyncImage(url: video.thumbnailURL) { image in
                image.resizable().scaledToFit()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 80, height: 60)
            
            VStack(alignment: .leading) {
                Text(video.title).font(.headline)
                Text(video.description).font(.caption).foregroundColor(.gray)
            }
        }
    }
}

// View for playing and rating a video
struct VideoPlayerView: View {
    let video: Video
    @State private var rating: Int? = nil
    
    var body: some View {
        VStack {
            VideoPlayer(player: AVPlayer(url: video.videoURL)) // Display video player
                .frame(height: 250)
            Text(video.title).font(.headline)
            Text(video.description).font(.caption)
            
            // Rating UI
            if let rating = video.rating {
                HStack {
                    ForEach(1..<6) { index in
                        Image(systemName: index <= Int(rating.rounded()) ? "start.fill" : "start")
                            .foregroundColor(.yellow)
                    }
                }
            } else {
                HStack {
                    ForEach(1..<6) { index in
                        Image(systemName: "star.fill")
                            .foregroundColor(index <= (rating ?? 0) ? .yellow : .gray) // Fill stars based on rating
                            .onTapGesture {
                                rating = index
                            }
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        VideoListView()
    }
}
