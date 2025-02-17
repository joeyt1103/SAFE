//
//  Library.swift
//  SAFE
//
//  Created by Kevin Gualano on 9/18/24.
//

import SwiftUI

struct LibraryView: View {
    var body: some View {
        VStack {
           
            Text("Diocesan Policies and Protocols")
                .font(.largeTitle)
                .padding()

            Spacer()
            
            Link("Diocesan Code of Conduct", destination: URL(string: "https://www.allentowndiocese.org/sites/default/files/2023-01/CodeofConduct2022_0.pdf")!)
                            .padding()
            Link("Policy Regarding the Alledge Abuse of Minors", destination: URL(string: "https://www.allentowndiocese.org/sites/default/files/2023-01/SexualAbusePolicy2022.pdf")!)
                            .padding()
            Link("Mandated Reporter Training", destination: URL(string: "https://www.allentowndiocese.org/sites/default/files/2021-01/Mandated%20Reporter%20Training%20Policy%20rev1-2021.pdf")!)
                            .padding()
            Link("Policy Concerning Youth Under 18", destination: URL(string: "https://www.allentowndiocese.org/about-youth-protection/safe-environment-programs/policy-concerning-children-and-young-people-under")!)
                            .padding()
            Link("Megan's Law Protocols", destination: URL(string: "https://www.allentowndiocese.org/youth-protection/megans-law")!)
                            .padding()
            Link("Policy for Overnight Trips and Chaperones", destination: URL(string: "https://www.allentowndiocese.org/sites/default/files/2017-08/Chaperones.pdf")!)
                            .padding()
            Link("FAQs About Protecting Youth", destination: URL(string: "https://www.allentowndiocese.org/youth-protection/faq")!)
                            .padding()
            
            Spacer()
            
        }
    }
}

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView()
    }
}
