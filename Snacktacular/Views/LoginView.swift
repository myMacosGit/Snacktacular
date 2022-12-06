//
//  LoginView.swift
//  Snacktacular
//
//  Created by Richard Isaacs on 07.11.22.
//

import SwiftUI
import Firebase

struct LoginView: View {

    enum Field {
        case email, password
    }
    @State private var email = ""
    @State private var password = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var buttonDisabled = true
    @State private var presentSheet = false
    
    @FocusState private var focusField: Field?

    var body: some View {
        VStack {
            Image("logo")
                .resizable()
                .scaledToFit()
                .padding()
            
            Group {
                TextField("E-mail", text: $email)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .submitLabel(.next)
                    .focused($focusField, equals: .email) // this field is bound to the .email case
                    .onSubmit {
                        focusField = .password
                    }
                    .onChange(of: email) { _ in
                        enableButtons()
                    }
                SecureField("Password", text: $password)
                    .textInputAutocapitalization(.never)
                    .submitLabel(.done)
                    .focused($focusField, equals: .password)
                    .onSubmit {
                        focusField = nil // will dismiss the keyboard
                    }
                    .onChange(of: password) { _ in
                        enableButtons()
                    }
            } // Group
            .textFieldStyle(.roundedBorder)
            .overlay(content: {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(.gray.opacity(0.5), lineWidth: 2)
            })
            .padding(.horizontal)
            //self.Print("--- HStack")
            HStack {
                Button {
                    register()
                } label: {
                    Text("Sign up")
                } // Button
                .padding(.trailing)
        
                Button {
                    login()
                } label: {
                    Text("Log In")
                }         // Button
                .padding(.leading)
                
            } // HStack
            .disabled(buttonDisabled)
            .buttonStyle(.borderedProminent)
            .tint(Color("SnackColor"))
            .font(.title2)
            .padding(.top)
            
        } // NavigationStack
        .alert(alertMessage, isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        }.onAppear() {
            if Auth.auth().currentUser != nil {
                print ("🪵 Login/Registration Success")
                presentSheet = true
            }
        }
        .fullScreenCover(isPresented: $presentSheet) {
            ListView()
        }
    } // View
    
    func enableButtons () {
        let emailIsGood = email.count >= 6 && email.contains("@")
        let passwordIsGood = password.count >= 6
        buttonDisabled = !(emailIsGood && passwordIsGood)
        } // enableButtons
    
    func register() {
        //self.Print("--- register")
        Auth.auth().createUser(withEmail: email, password: password) {
            Result, error in
            
            if let error = error {
                print ("Sign UP Error \(error.localizedDescription)")
                alertMessage = "Sign UP Error \(error.localizedDescription)"
                showingAlert = true
            } else {
                print ("Sign UP/Registration Success")
                presentSheet = true
            }
        }
    } // register
    
    func login () {
        Auth.auth().signIn(withEmail: email, password: password) {
            Result, error in
            if let error = error {
                print ("Login Error \(error.localizedDescription)")
                alertMessage = "Login Error \(error.localizedDescription)"
                showingAlert = true
            } else {
                print ("🪵 Login/Registration Success")
                presentSheet = true
            }
        }
    } // login
} // LoginView

extension View {
    func Print(_ vars: Any...) -> some View {
        for v in vars { print(v) }
        return EmptyView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
