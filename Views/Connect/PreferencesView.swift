//
//  PreferencesView.swift
//  Lymbo
//
//  Created on 2025
//

import SwiftUI

struct PreferencesView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedTypes: Set<String> = []
    @State private var maxDistance: Double = 50
    @State private var ageRange: ClosedRange<Double> = 18...65
    
    let artistTypes = ["Photographer", "Video Designer", "Fashion Designer", "Graphic Designer", "Illustrator", "Painter", "Sculptor"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Artist Types
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Type of Artist")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.foreground)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(artistTypes, id: \.self) { type in
                                Button(action: {
                                    if selectedTypes.contains(type) {
                                        selectedTypes.remove(type)
                                    } else {
                                        selectedTypes.insert(type)
                                    }
                                }) {
                                    Text(type)
                                        .font(.system(size: 14))
                                        .foregroundColor(selectedTypes.contains(type) ? .accentColor : .foreground)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(selectedTypes.contains(type) ? Color.primaryColor : Color.inputBackground)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    
                    // Distance
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Maximum Distance")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.foreground)
                        
                        Text("\(Int(maxDistance)) km")
                            .font(.system(size: 18))
                            .foregroundColor(.mutedForeground)
                        
                        Slider(value: $maxDistance, in: 1...100, step: 1)
                            .accentColor(.primaryColor)
                    }
                    
                    // Age Range
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Age Range")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.foreground)
                        
                        Text("\(Int(ageRange.lowerBound)) - \(Int(ageRange.upperBound)) years")
                            .font(.system(size: 18))
                            .foregroundColor(.mutedForeground)
                        
                        RangeSlider(range: $ageRange, bounds: 18...65)
                    }
                }
                .padding(20)
            }
            .background(Color.backgroundColor)
            .navigationTitle("Preferences")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.primaryColor)
                }
            }
        }
    }
}

struct RangeSlider: View {
    @Binding var range: ClosedRange<Double>
    let bounds: ClosedRange<Double>
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.muted)
                    .frame(height: 4)
                
                Rectangle()
                    .fill(Color.primaryColor)
                    .frame(width: CGFloat((range.upperBound - range.lowerBound) / (bounds.upperBound - bounds.lowerBound)) * geometry.size.width, height: 4)
                    .offset(x: CGFloat((range.lowerBound - bounds.lowerBound) / (bounds.upperBound - bounds.lowerBound)) * geometry.size.width)
                
                // Lower thumb
                Circle()
                    .fill(Color.primaryColor)
                    .frame(width: 20, height: 20)
                    .offset(x: CGFloat((range.lowerBound - bounds.lowerBound) / (bounds.upperBound - bounds.lowerBound)) * geometry.size.width)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let newValue = bounds.lowerBound + (value.location.x / geometry.size.width) * (bounds.upperBound - bounds.lowerBound)
                                if newValue >= bounds.lowerBound && newValue <= range.upperBound {
                                    range = newValue...range.upperBound
                                }
                            }
                    )
                
                // Upper thumb
                Circle()
                    .fill(Color.primaryColor)
                    .frame(width: 20, height: 20)
                    .offset(x: CGFloat((range.upperBound - bounds.lowerBound) / (bounds.upperBound - bounds.lowerBound)) * geometry.size.width)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let newValue = bounds.lowerBound + (value.location.x / geometry.size.width) * (bounds.upperBound - bounds.lowerBound)
                                if newValue >= range.lowerBound && newValue <= bounds.upperBound {
                                    range = range.lowerBound...newValue
                                }
                            }
                    )
            }
        }
        .frame(height: 40)
    }
}

#Preview {
    PreferencesView()
}

