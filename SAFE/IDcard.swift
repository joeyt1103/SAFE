//
//  IDcard.swift
//  SAFE
//
//  Created by Joey Trave on 4/14/25.
//
import SwiftUI
import Foundation

// will show users id card with requirements
struct IDCard: View {
    @ObservedObject var userState = UserState.shared
    @StateObject private var dataManager = RequirementsDataManager()

    @State private var clearances: [UserRequirementStatus] = []
    @State private var trainings: [UserRequirementStatus] = []
    @State private var policies: [UserRequirementStatus] = []
    var body: some View {
        NavigationView{
            VStack{
                
                HStack{
                    VStack{
                        Text("Name"/*firstName + lastName*/)
                            .font(.system(.body))
                            .fontWeight(.bold)
                            .padding(.bottom, 5)
                            .padding(.leading, -100)
                        Text("User"/*username*/)
                            .font(.system(.body))
                            .fontWeight(.bold)
                            .padding(.bottom, 5)
                            .padding(.leading, -100)
                        Text("Diocese name"/*dioceseName*/)
                            .font(.system(.body))
                            .fontWeight(.bold)
                            .padding(.bottom, 5)
                            .padding(.leading, -90)
                    }
                    VStack{
                        Image("idcard")
                            .resizable()
                            .frame(width: 100, height: 100)
                        Text("ID Card"/*userId*/)
                            .font(.system(.body))
                            .fontWeight(.bold)
                            .padding(.bottom, 5)
                            .padding(.leading, 120)
                    }
                    
                }
                VStack{
                    sectionView(title: "Clearances", certifications: clearances)
                    sectionView(title: "Trainings", certifications: trainings)
                    sectionView(title: "Policies", certifications: policies)
                }
                
            }
            .padding(8)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.2)))
            .padding(.bottom, 10)
            
            
            
        }
    
    }
    private func sectionView(title: String, certifications: [UserRequirementStatus]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.custom("Helvetica", size: 22))
                .foregroundColor(Color(red: 0.3176, green: 0.3176, blue: 0.3176))
                .bold()

            Divider()

            VStack(spacing: 12) {
                ForEach(certifications) { cert in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(cert.reqID)
                                .font(.custom("Helvetica", size: 16))
                                .foregroundColor(Color(red: 0.3176, green: 0.3176, blue: 0.3176))
                            Spacer()
                            Text(cert.status)
                                .font(.custom("Helvetica", size: 16))
                                .foregroundColor(colorForStatus(cert.status))
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 2)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(12)
        .shadow(radius: 4)
    }
    
    private func colorForStatus(_ status: String) -> Color {
        if status.starts(with: "Expired On:") {
            return .red
        } else if status.starts(with: "Expiring Within") {
            return .orange
        } else if status.starts(with: "Generated") {
            return .indigo
        } else {
            return .black
        }
    }
}

#Preview {
        IDCard()
}

