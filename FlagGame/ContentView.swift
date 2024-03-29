//
//  ContentView.swift
//  FlagGame
//
//  Created by melih özdil on 18.03.2024.
//

import SwiftUI

extension Color {
    
    init(hex: String) {
            let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
            var int: UInt64 = 0
            Scanner(string: hex).scanHexInt64(&int)
            let a, r, g, b: UInt64
            switch hex.count {
            case 3: // RGB (12-bit)
                (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
            case 6: // RGB (24-bit)
                (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
            case 8: // ARGB (32-bit)
                (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
            default:
                (a, r, g, b) = (1, 1, 1, 0)
            }

            self.init(
                .sRGB,
                red: Double(r) / 255,
                green: Double(g) / 255,
                blue:  Double(b) / 255,
                opacity: Double(a) / 255
            )
        }
}

struct FlagButton: View {
    var number: Int
    var flagTapped: (Int) -> Void // Function to handle flag tap
    var countriesOnGame: [String] // Array of country names
    
    @State private var isSpinning = false
    
    var body: some View {
        Button(action: {
            withAnimation{
                flagTapped(number)
                isSpinning.toggle()
            }
        }, label: {
          Image(countriesOnGame[number])
                .resizable()
                .frame(width: 200.0, height: 130.0)
                .clipShape(.rect(cornerRadius: 20))
                .rotation3DEffect(.degrees(isSpinning ? 360 : 0), axis: (x:0, y:1, z:0))
                .padding(10)
                
        })
    }
}


struct ContentView: View {
    @State private var countries = ["Austria", "Andorra", "Albania", "Bulgaria", "Bosnia And Herzegovina", "Belgium", "Belarus", "Denmark", "Czech Republic", "Croatia", "Greece", "Germany", "Georgia", "France", "Finland", "Estonia", "Italy", "Ireland", "Iceland", "Hungary", "Macedonia", "Luxembourg", "Lithuania"].shuffled()
    
    @State private var countriesOnGame = ["Austria", "Andorra", "Albania", "Bulgaria", "Bosnia And Herzegovina", "Belgium", "Belarus", "Denmark", "Czech Republic", "Croatia", "Greece", "Germany", "Georgia", "France", "Finland", "Estonia", "Italy", "Ireland", "Iceland", "Hungary", "Macedonia", "Luxembourg", "Lithuania"].shuffled()
    
    
    @State private var remainingFlags = 23
    @State private var score = 0
    
    @State private var correctAnswer = Int.random(in: 0...2)
    @State private var wrongAnswer = false
    @State private var gameOver = false
    @State private var selectedAnswer = -1
        
    var body: some View {
            ZStack {
                RadialGradient(stops: [
                    .init(color: Color(hex: "0a7296"), location: 0.1),
                    .init(color: Color(hex: "0a8896"), location: 0.6)
                ], center: .top, startRadius: 100, endRadius: 500)
                .ignoresSafeArea()
                
                VStack (spacing:5){
                    Spacer()
                    VStack{
                        Text("Choose the flag of")
                            .foregroundStyle(.white)
                            .font(.custom("ChalkboardSE-Regular", size: 16))
                        
                        Text(countriesOnGame[correctAnswer])
                            .frame(width: 300)
                            .foregroundStyle(.white)
                            .font(.custom("ChalkboardSE-Regular", size: 25))
                    }
                    Spacer()
                    Text("Remaining \(Image(systemName: "flag.square")): \(remainingFlags-3)")
                        .font(.custom("ChalkboardSE-Regular", size: 30))
                        .padding(12)
                        .background(Color(hex:"#88e319"))
                        .clipShape(.rect(cornerRadius: 20))
                        .foregroundColor(.white)
                    Spacer()
                    
                    ForEach(0..<3) { number in
                        FlagButton(number:number, flagTapped: flagTapped, countriesOnGame: countriesOnGame)
                        .background(.ultraThinMaterial)
                        .clipShape(.rect(cornerRadius: 30))
                        .transition(.opacity)
                    }
                    .padding(3)
                    
                    Spacer()
                    
                    Text("Result: \(score)")
                        .font(.custom("ChalkboardSE-Regular", size: 40))
                        .padding(13)
                        .background(Color(hex:"#88e319"))
                        .clipShape(.rect(cornerRadius: 20))
                        .foregroundColor(.white)
                    Spacer()
                    
                }
                .frame(maxWidth: .infinity)
            }
            .sheet(isPresented: $wrongAnswer, onDismiss: {
                askQuestion()
            }, content: {
                WrongAnswerView(correctCountry: countriesOnGame[correctAnswer])
                    .presentationDetents([.fraction(0.4)])
            })
            
            .sheet(isPresented: $gameOver, onDismiss: {
                countriesOnGame = countries
                remainingFlags = 23
                score = 0
                askQuestion()
            }, content: {
                GameOverView(finalScore: score)
                    .presentationDetents([.fraction(0.4)])
            })
        }
    
    func flagTapped(_ number: Int) {
        if number == correctAnswer {
            score += 1
            askQuestion()
            
        } else {
            wrongAnswer.toggle()
        }
        remainingFlags -= 1
    }
    
    func askQuestion() {
        if remainingFlags > 4 {
            if let indexToRemove = countriesOnGame.firstIndex(of: countriesOnGame[correctAnswer]) {
                countriesOnGame.remove(at: indexToRemove)
            }
            countriesOnGame.shuffle()
            correctAnswer = Int.random(in: 0...2)
        } else {
            gameOver = true
        }
    }
}

struct WrongAnswerView: View {
    let correctCountry: String
    
    var body: some View {
        ZStack{
            
            LinearGradient(stops: [
                .init(color: Color(hex: "034dad"), location: 0.2),
                .init(color: Color(hex: "0a8896"), location: 0.8)
            ], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack {
                Text("The correct answer was:")
                    .font(.custom("ChalkboardSE-Regular", size: 25))
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(.rect(cornerRadius: 20))
                    .foregroundColor(.white)
                    .padding()
                Image(correctCountry)
                    .resizable()
                    .clipShape(.rect(cornerRadius: 20))
                    .frame(width: 250, height: 180)
                    .clipShape(.rect(cornerRadius: 30))
                    
            }
        }
    }
}

struct GameOverView: View {
    let finalScore: Int
    
    var body: some View {
        ZStack{
            
            LinearGradient(stops: [
                .init(color: Color(hex: "034dad"), location: 0.1),
                .init(color: Color(hex: "0a8896"), location: 0.6)
            ], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack {
                Text("Your score is: \(finalScore)")
                    .font(.custom("ChalkboardSE-Regular", size: 35))
                    .padding()
                    .background(.mint)
                    .clipShape(.rect(cornerRadius: 20))
                    .foregroundColor(.white)
                    .padding()
                Text("Scroll down this to play")
                    .font(.custom("ChalkboardSE-Regular", size: 25))
                    .padding()
                    .background(.mint)
                    .clipShape(.rect(cornerRadius: 20))
                    .foregroundColor(.white)
                
                    
            }
        }
    }
}


#Preview {
    ContentView()
}

