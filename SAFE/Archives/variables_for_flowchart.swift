//
//  step2.swift
//  SAFE
//
//  Created by Kevin Gualano on 10/10/24.
//

import Foundation

//Step 1 Get data about where the abuse occurred and where the child lives

let PP = """
        PA Childline:
        1-800-932-0313
        """
let PJ = """
        NJ State Registry:
        1-877-652-2873

        AND
        
        PA Childline:
        1-800-932-0313
        """
let JJ = """
        NJ State Registry:
        1-877-652-2873
        """
let JP = """
        NJ State Registry:
        1-877-652-2873

        AND
        
        PA Childline:
        1-800-932-0313
        """






//Step 2 Complete CY-47 will replace hard coded text with db results

let step2 = """
Yes you MUST complete the CY-47

Complete the CY-47 Online

You are required to create  Keystone ID in order to submit an electronic report.  Complete all information on the form as best you are able (there may be some questions you are not able to answer). 

You must print the form before you exit. A confirmation of the submitted form will be sent to your email.               

OR

Complete the CY-47 Manually

Print the form, and complete all information as far as you are able (there may be some questions that you are not able to answer). You must complete the form immediately after making the call then within 48 hours you are required to mail or fax the form to the local county office.

It is strongly recommended that you make the report online as this is a complicated and intensive manual 8process with short window to complete everything.

"""

let step2nj = """
No you DO NOT complete the CY-47

New Jersey does not recognize form PA CY-47, so after calling the NJ Registry, you do not complete the CY-47.
"""

//Step 3 Notify the Person in Charge
let charge_notify = """
Inform the Person in Charge:

Parish:
Pastor/Parochial Administrator

School:
Principal

Diocesan:
Vicar General

Secretary for Catholic Health, Human Services and Youth Protection

Vicar for Clergy
"""
//Step 4 Contact Attorney and Secretary
let next_contact = """
Who to Contact Next:

Diocesan Legal Counsel
Attorney Joseph Zator

Phone:
610-432-1900

Fax:
610-432-1707

Email:
jzator@zatorlaw.com

Address:
4400 Walbert Ave
Allentown, PA 18104

Secretary for Catholic Health, Human Services and Youth Protection

Ms. Pamela J. Russo

Phone:
610-871-5200 x2204

Email:
prusso@allentowndiocese.org
"""
//Step 5 Be on the look out for future correspondance
let follow_up = """
In 30-60 Days

You should receive a letter from the local County Office of Children and Youth with report findings.  When you receive this letter you must forward the letter to Attorney Zator’s office by the above contact information.  You should also keep a copy of this letter in a secure location for your own records.

Important Note:
Keep copies of all your documents and correspondence. For further questions contract the Secretary for Health, Human Services, and Youth Protection:

Ms. Pamela Russo
prusso@allentowndiocese.org     or     610-871-5200 x2204

"""
