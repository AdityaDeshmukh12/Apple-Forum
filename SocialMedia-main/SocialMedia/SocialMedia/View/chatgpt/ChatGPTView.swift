//
//  ChatGPTView.swift
//  SocialMedia
//
//  Created by Aditya Inamdar on 05/05/23.
//

import SwiftUI
import OpenAISwift

struct QuestionAndAnswer: Identifiable {
    
    let id = UUID()
    let question: String
    var answer: String
}

struct ChatGPTView: View {
    
    let openAI = OpenAISwift(authToken: "abc")
    
    @State private var search: String = ""
    @State private var questionAndAnswers: [QuestionAndAnswer] = []
    @State private var searching: Bool = false
    
    private func performOpenAISearch() {
        openAI.sendCompletion(with: search) { result in
            switch result {
                case .success(let success):
                    
                let questionAndAnswer = QuestionAndAnswer(question: search, answer: success.choices?.first?.text.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
                
                
                    questionAndAnswers.append(questionAndAnswer)
                    search = ""
                    searching = false
                    
                case .failure(let failure):
                    print(failure.localizedDescription)
                    searching = false
            }
        }
    }
    private func performOpenAISearchWithOptions() async {
        do {
            let result = try await openAI.sendCompletion(with: search,maxTokens: 200)
            print("result:\(result.choices?.first?.text ?? "no resp")")
            questionAndAnswers.append(QuestionAndAnswer(question: search, answer: result.choices?.first?.text.replacingOccurrences(of: "^\\s*", with: "",options: .regularExpression) ?? "no resp"))
            search = ""
            searching = false
        }
        catch {
            print("Error in chatgpt view:\(error.localizedDescription)")
            searching = false
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                
                ScrollView(showsIndicators: false) {
                    ForEach(questionAndAnswers) { qa in
                        VStack(spacing: 10) {
                            Text(qa.question)
                                .bold()
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text(qa.answer)
                                .padding([.bottom], 10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }.padding()
                
                HStack {
                    TextField("Type here...", text: $search)
                        .onSubmit {
                            if !search.isEmpty {
                                searching = true
                                
                                Task {
                                    await performOpenAISearchWithOptions()
                                }
                            
                            }
                        }
                    .padding()
                    if searching {
                        ProgressView()
                            .padding()
                    }
                }
                
            }.navigationTitle("ChatGPT")
        }
    }
}
struct ChatGPTView_Previews: PreviewProvider {
    static var previews: some View {
        ChatGPTView()
    }
}
