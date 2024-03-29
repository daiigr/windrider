//
//  RouteConditionPreviewView.swift
//  windrider
//
//  Created by Daniel Grbac Bravo on 07/03/2024.
//

import SwiftUI
import Charts

struct RouteConditionPreviewView: View {
  //MARK: - Properties
  @Binding var selectedPath: CyclingPath?
  @Binding var pathImpact: PathImpact
  @Binding var coordinateImpacts: [CoordinateImpact]
  
  
  @Binding var cyclingScore: Int
  @Binding var cyclingMessage: String
  
  @Binding  var isFetching: Bool
  @State private var fetchTimestamp: Date?
  
  @Namespace var animation
  @State private var isExpanded = false
  
  let headwindGradient = Gradient(colors: [.yellow, .red,.purple])
  let crosswindGradient = Gradient(colors: [.yellow, .orange,.purple])
  let tailwindGradient = Gradient(colors: [.yellow , .green,.purple])
  let windSpeedGradient = Gradient(colors: [.green, .yellow ,.orange, .red, .purple])
  let temperatureGradient = Gradient(colors: [ .purple, .blue ,.red])
  
  
  
  var body: some View {
    //MARK: - No Route Selected
    if selectedPath == nil{
      HStack{
        
        Text("No Route Selected")
          .font(.headline)
          .bold()
          .padding()
          .foregroundStyle(.primary)
      }.padding()
      
      
    } else {
      ZStack{
        if !isExpanded {
          //MARK: - Collapsed View
          
          VStack{
            HStack{
              withAnimation {
                Text("\(selectedPath?.name ?? "")")
                  .font(.headline)
                  .padding()
                  .bold()
                  .shadow(radius: 20)
                  .foregroundStyle(.primary)
                  .matchedGeometryEffect(id: "titleText", in: animation)
              }
            }
            .transition(.push(from: .bottom))
            .animation(.spring(duration: 2), value: selectedPath?.name ?? "")
            
            
            HStack{
              withAnimation {
                Text(cyclingMessage)
                  .font(.headline)
                  .fixedSize(horizontal: false, vertical: true)
                  .shadow(radius: 20)
                  .foregroundStyle(.gray)
                  .matchedGeometryEffect(id: "cyclingMessage", in: animation)
              }
              .transition(.push(from: .bottom))
              .animation(.spring(duration: 2), value: cyclingMessage)
              
              withAnimation {
                HStack{
                  Text("\(cyclingScore)").font(.system(size: 50, weight: .heavy, design: .serif)).bold().foregroundStyle(.primary)
                  + Text("%").font(.caption).bold().foregroundStyle(.gray)
                  
                }
                .matchedGeometryEffect(id: "cyclingScore", in: animation)
                .shadow(radius: 20)
                .contentTransition(.numericText(value:  Double(cyclingScore * 100)))
                
              }
              .padding()
              .transition(.push(from: .bottom))
              .animation(.smooth(duration: 2), value: Double(cyclingScore))
              .sensoryFeedback(.impact, trigger: Double(cyclingScore))
              
            }
            
            
            
            withAnimation {
              Gauge(value: Double(pathImpact.windSpeed), in: 0...15){
              } currentValueLabel: {
                HStack{
                  Text("\(truncateToOneDecmialPlace(pathImpact.windSpeed)) m\\s").bold()
                }
                .contentTransition(.numericText(value: Double(pathImpact.windSpeed)))
              }
              .gaugeStyle(.accessoryLinear)
              .tint(windSpeedGradient)
            }
            .transition(.push(from: .bottom))
            .animation(.snappy(duration: 2), value: Double(pathImpact.windSpeed))
            .matchedGeometryEffect(id: "windSpeedGauge", in: animation)
            
          }.padding()
          
          
          
        } else {
          //MARK: Expanded View
          VStack{
            HStack{
              withAnimation {
                Text("\(selectedPath?.name ?? "")")
                  .font(.headline)
                  .bold()
                  .padding()
                  .shadow(radius: 20)
                  .foregroundStyle(.primary)
                  .matchedGeometryEffect(id: "titleText", in: animation)
              }
            }
            .transition(.push(from: .bottom))
            .animation(.spring(duration: 2), value: selectedPath?.name ?? "")
            
            
            HStack{
              withAnimation {
                Text(cyclingMessage)
                  .font(.headline)
                  .fixedSize(horizontal: false, vertical: true)
                  .shadow(radius: 20)
                  .foregroundStyle(.gray)
                  .matchedGeometryEffect(id: "cyclingMessage", in: animation)
              }
              .transition(.push(from: .bottom))
              .animation(.spring(duration: 2), value: cyclingMessage)
              
              withAnimation {
                HStack{
                  Text("\(cyclingScore)").font(.system(size: 50, weight: .heavy, design: .serif)).bold().foregroundStyle(.primary)
                  + Text("%").font(.caption).bold().foregroundStyle(.gray)
                  
                }
                .matchedGeometryEffect(id: "cyclingScore", in: animation)
                .shadow(radius: 20)
                .contentTransition(.numericText(value:  Double(cyclingScore * 100)))
                
              }
              .padding()
              .transition(.push(from: .bottom))
              .animation(.smooth(duration: 2), value: Double(cyclingScore))
              .sensoryFeedback(.impact, trigger: Double(cyclingScore))
              
            }
            
            
            HStack{
              //temperature gauge
              withAnimation {
                Gauge(value: Double(kelvinToCelsius(pathImpact.temperature)), in: -20...40){
                  Image(systemName: "thermometer.medium")
                } currentValueLabel: {
                  HStack{
                    Text("\(Int(kelvinToCelsius(pathImpact.temperature)))°").bold()
                  }.contentTransition(.numericText(value: Double(kelvinToCelsius(pathImpact.temperature))))
                  
                }
                .gaugeStyle(.accessoryCircular)
                .tint(temperatureGradient)
                .animation(.spring(duration: 2), value: kelvinToCelsius(pathImpact.temperature))
                .matchedGeometryEffect(id: "temperatureGauge", in: animation)
              }
              .transition(.push(from: .bottom))
              .animation(.snappy(duration: 2), value: kelvinToCelsius(pathImpact.temperature))
              
              //crosswindPercentage gauge
              withAnimation {
                Gauge(value: Double(pathImpact.crosswindPercentage)/100){
                  Image(systemName: "arrow.down.right.and.arrow.up.left")
                } currentValueLabel: {
                  HStack{
                    Text("\(Int(pathImpact.crosswindPercentage))%").bold()
                  }.contentTransition(.numericText(value: Double(pathImpact.crosswindPercentage)))
                  
                }
                .gaugeStyle(.accessoryCircular)
                .tint(crosswindGradient)
                .matchedGeometryEffect(id: "crosswindPercentageGauge", in: animation)
              }
              .transition(.push(from: .bottom))
              .animation(.snappy(duration: 2), value: Double(pathImpact.crosswindPercentage))
              
              //tailwindPercentage gauge
              withAnimation {
                Gauge(value: Double(pathImpact.tailwindPercentage)/100){
                  Image(systemName: "arrow.right.to.line")
                } currentValueLabel: {
                  HStack{
                    Text("\(Int(pathImpact.tailwindPercentage))%").bold()
                  }.contentTransition(.numericText(value: Double(pathImpact.tailwindPercentage)))
                  
                }
                .gaugeStyle(.accessoryCircular)
                .tint(tailwindGradient)
                .matchedGeometryEffect(id: "tailwindPercentageGuage", in: animation)
              }
              .transition(.push(from: .bottom))
              .animation(.snappy(duration: 2), value: Double(pathImpact.tailwindPercentage))
              
              //headwindPercentage gauge
              withAnimation {
                Gauge(value: Double(pathImpact.headwindPercentage)/100){
                  Image(systemName: "arrow.left.to.line")
                } currentValueLabel: {
                  HStack{
                    Text("\(Int(pathImpact.headwindPercentage))%").bold()
                  }.contentTransition(.numericText(value: Double(pathImpact.headwindPercentage)))
                  
                }
                .gaugeStyle(.accessoryCircular)
                .tint(headwindGradient)
                .matchedGeometryEffect(id: "headwindPercentageGuage", in: animation)
              }
              .transition(.push(from: .bottom))
              .animation(.snappy(duration: 2), value: Double(pathImpact.headwindPercentage))
              
            }
            
            withAnimation {
              Gauge(value: Double(pathImpact.windSpeed), in: 0...15){
              } currentValueLabel: {
                HStack{
                  Text("\(truncateToOneDecmialPlace(pathImpact.windSpeed)) m\\s").bold()
                }
                .contentTransition(.numericText(value: Double(pathImpact.windSpeed)))
              }
              .gaugeStyle(.accessoryLinear)
              .tint(windSpeedGradient)
            }
            .matchedGeometryEffect(id: "windSpeedGauge", in: animation)
            .transition(.push(from: .bottom))
            .animation(.snappy(duration: 2), value: windSpeedGradient)
          }.padding()
        }
      }.onTapGesture {
        withAnimation {
          cyclingScore = Int(ImpactCalculator.calculateCyclingScore(for: pathImpact))
          isExpanded.toggle()
          
        }
      }
    }
  }
}

//MARK: - Functions
public func truncateToOneDecmialPlace(_ value: Float) -> String {
  return String(format: "%.1f", value)
}
/// given some
public func kelvinToCelsius(_ kelvin: Float) -> Float{
  return kelvin - 273.15
}

public func meterPerSecondToKilometerPerHour(_ mps: Double) -> Double {
  return mps * 3.6
}
