//
//  ContentView.swift
//  WeatherWiz-RemoteTasks
//
//  Created by Rob Enriquez on 12/19/23.
//

import SwiftUI

struct HomeView: View {
    @State private var isHourlySelected = true // State for hourly/daily toggle
    @State private var isModalPresented = false
    @State private var selectedLocation: Location? = nil // Initially nil
    @State private var isFavorite: Bool = false
    
    private func presentModal() {
        isModalPresented = true
    }
    
    private func toggleFavorite() {
        guard let locationName = selectedLocation?.name else { return } // Safety check
        let defaults = UserDefaults.standard
        if var savedLocations = defaults.array(forKey: "locations") as? [String] {
            if savedLocations.contains(locationName) {
                savedLocations.removeAll(where: { $0 == locationName }) // Remove if existing
            } else {
                savedLocations.append(locationName) // Add if not present
            }
            defaults.set(savedLocations, forKey: "locations")
            isFavorite.toggle()
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background (consider adding a gradient or image here)

                VStack {
                    // Upper Part (City, Temperature, Description, Icon)
                    HStack {
                        Text(selectedLocation?.name ?? "City") // Replace with dynamic city data
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Button(action: { toggleFavorite() }) {
                                Image(systemName: isFavorite ? "heart.fill" : "heart")
                                    .font(.system(size: 24)) // Adjust size as needed
                            }
                        Spacer()
                        Image(systemName: selectedLocation?.icon ?? "questionmark") // Display icon
                            .font(.system(size: 60))
                    }
                    .padding()

                    Text("\(selectedLocation?.currentTemp ?? 0)°C, \(selectedLocation?.description ?? "")") // Display temp and description
                        .font(.title2)

                    HStack {
                        Text("H: \(selectedLocation?.highTemp ?? 0)°C L: \(selectedLocation?.lowTemp ?? 0)°C")
                    }

                    Spacer()

                    // Middle Part (Hourly/Daily View)
                    VStack {
                        HStack {
                            Button(action: { isHourlySelected = true }) {
                                Text("Hourly").padding()
                            }
                            Button(action: { isHourlySelected = false }) {
                                Text("Daily").padding()
                            }
                        }

                        ScrollView(.horizontal) { // Scrollable for hourly/daily views
                            HStack {
                                if isHourlySelected {
                                    ForEach(0..<8) { hour in // Replace 8 with the number of hourly views
                                        HourlyView(hour: hour) // Hour, icon, temperature
                                    }
                                } else {
                                    ForEach(0..<5) { day in // Replace 5 with the number of daily views
                                        DailyView(day: day) // Day, date, icon, temperature
                                    }
                                }
                            }
                        }
                    }

                    Spacer() // Push the views upward

                    // Lower Buttons (Home, Add, Favorite)
                    HStack {
                        Button(action: { /* Home action */ }) {
                            Image(systemName: "house.fill")
                        }
                        Spacer()
                        NavigationLink(destination: AddLocationModal(selectedLocation: $selectedLocation)) {
                            Image(systemName: "plus")
                        }
                        
                        Spacer()
                        NavigationLink(destination: FavoritesView()) {
                            Image(systemName: "heart.fill") // Or your preferred icon
                        }
                    }
                    .padding()
                }
            }
            .onAppear { // Add this modifier
                if let locationName = selectedLocation?.name {
                    isFavorite = retrieveSavedLocations().contains(locationName)
                }
            }
        }
    }
}

struct HourlyView: View {
    let hour: Int

    var body: some View {
        VStack {
            Text("\(hour):00") // Display the hour
            Image(systemName: "cloud.sun") // Replace with dynamic weather icon
            Text("23°C") // Display temperature for the hour
        }
        .padding()
    }
}

struct DailyView: View {
    let day: Int

    var body: some View {
        VStack {
            Text("Day \(day)") // Display the day number
            Text("May 22") // Replace with dynamic date
            Image(systemName: "sun.max") // Replace with dynamic weather icon
            Text("H: 25°C L: 18°C") // Display high and low temperatures
        }
        .padding()
    }
}

struct AddLocationModal: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedLocation: Location? // Binding for updating
    @State private var searchText = ""
    @State private var searchResults: [Location] = [] // Placeholder for search results
    
    var body: some View {
        VStack {
            TextField("Search for a location", text: $searchText)
                .padding()
                .onChange(of: searchText) {
                    if !searchText.isEmpty {
                        searchResults = sampleLocations.filter { location in
                            location.name.localizedCaseInsensitiveContains(searchText)
                        }
                        
                        if searchResults.isEmpty {
                            // Show "No results" view if needed
                        } else {
                            // Display searchResults list as before
                        }
                    } else {
                        searchResults = [] // Clear results when search is empty
                    }
                }
            List(searchResults) { location in
                Button(action: {
                    selectedLocation = location
                    dismiss()
                }) {
                    Text(location.name) // Display location name
                }
            }
        }
        .padding()
    }
}

struct SearchBar: View {
    @Binding var searchTerm: String

    var body: some View {
        TextField("Search location", text: $searchTerm)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
    }
}

struct HourlyForecast: Identifiable, Codable {
    var id = UUID()
    let time: Date
    let temperature: Double
    let weatherIcon: String // Assuming weather icons are represented by strings
}

struct DailyForecast: Identifiable, Codable {
    var id = UUID()
    let date: Date
    let highTemp: Double
    let lowTemp: Double
    let weatherIcon: String
}

struct Location: Identifiable {
    let id = UUID()
    let name: String  // Updated from "name"
    let currentTemp: Int
    let highTemp: Int
    let lowTemp: Int
    let description: String
    let icon: String
}

let sampleLocations: [Location] = [
    Location(name: "San Francisco", currentTemp: 65, highTemp: 70, lowTemp: 58, description: "Partly Cloudy", icon: "cloud.sun"),
    Location(name: "New York", currentTemp: 72, highTemp: 78, lowTemp: 65, description: "Sunny", icon: "sun.max.fill"),
    Location(name: "London", currentTemp: 58, highTemp: 62, lowTemp: 53, description: "Rainy", icon: "cloud.rain"),
    Location(name: "San Mateo", currentTemp: 58, highTemp: 62, lowTemp: 53, description: "Rainy", icon: "cloud.rain"),
    Location(name: "Palo Alto", currentTemp: 58, highTemp: 62, lowTemp: 53, description: "Rainy", icon: "cloud.rain"),
    Location(name: "Vallejo", currentTemp: 58, highTemp: 62, lowTemp: 53, description: "Rainy", icon: "cloud.rain")
]

func saveLocationToUserDefaults(locationName: String) {
    let defaults = UserDefaults.standard
    if var savedLocations = defaults.array(forKey: "locations") as? [String] {
        savedLocations.append(locationName)
        defaults.set(savedLocations, forKey: "locations")
    } else {
        defaults.set([locationName], forKey: "locations")
    }
}

func retrieveSavedLocations() -> [String] {
    let defaults = UserDefaults.standard
    guard let savedLocationNames = defaults.array(forKey: "locations") as? [String] else {
        return [] // Return an empty array if no locations are saved
    }

    return savedLocationNames  // Return the array of location names directly
}

struct FavoritesView: View {
    @State private var savedLocations: [Location] = []

    var body: some View {
        List(savedLocations) { location in
            HStack {
                VStack(alignment: .leading) {
                    Text(location.name)
                        .font(.headline)
                    Text("\(location.currentTemp)°C (H: \(location.highTemp)°C L: \(location.lowTemp)°C)")
                        .font(.subheadline)
                }
                Spacer()
                Image(systemName: location.icon)
            }
        }
        .onAppear {
            for locationName in retrieveSavedLocations() {
                for location in sampleLocations {
                    if location.name == locationName {
                        savedLocations.append(location)
                    }
                }
            }
        }
    }
}


