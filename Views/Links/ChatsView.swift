//
//  ChatsView.swift
//  Lymbo
//
//  Created on 2025
//

import SwiftUI

struct ChatsView: View {
    let chats = sampleChats
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Text("The Chats Tab is where all the chats are! Creatives you match will be shown here with a \"Met Here\" Category Tag.")
                    .font(.system(size: 14))
                    .foregroundColor(.mutedForeground)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                
                ForEach(chats) { chat in
                    ChatRow(chat: chat)
                }
            }
        }
    }
}

struct ChatRow: View {
    let chat: Chat
    
    var body: some View {
        NavigationLink(destination: ChatDetailView(chat: chat)) {
            HStack(spacing: 16) {
                // Profile Image
                AsyncImage(url: URL(string: "https://picsum.photos/60/60?random=\(chat.creative.name.hash)")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.muted
                }
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                
                // Chat Info
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(chat.creative.name)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.foreground)
                        
                        Spacer()
                        
                        Text(chat.lastMessageTime)
                            .font(.system(size: 12))
                            .foregroundColor(.mutedForeground)
                    }
                    
                    Text(chat.lastMessage)
                        .font(.system(size: 14))
                        .foregroundColor(.mutedForeground)
                        .lineLimit(1)
                    
                    // Met Here Tag
                    HStack {
                        Text("Met Here")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.primaryColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.primaryColor.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
            }
            .padding(16)
            .background(Color.card)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
    }
}

struct ChatDetailView: View {
    let chat: Chat
    @State private var messageText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(chat.messages) { message in
                        MessageBubble(message: message)
                    }
                }
                .padding()
            }
            
            // Message Input
            HStack(spacing: 12) {
                TextField("Type a message...", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    // Send message
                    messageText = ""
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.accentColor)
                        .frame(width: 44, height: 44)
                        .background(Color.primaryColor)
                        .clipShape(Circle())
                }
            }
            .padding()
            .background(Color.card)
        }
        .navigationTitle(chat.creative.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MessageBubble: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.isFromMe {
                Spacer()
            }
            
            VStack(alignment: message.isFromMe ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .font(.system(size: 14))
                    .foregroundColor(message.isFromMe ? .accentColor : .foreground)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(message.isFromMe ? Color.primaryColor : Color.inputBackground)
                    .cornerRadius(16)
                
                Text(message.time)
                    .font(.system(size: 10))
                    .foregroundColor(.mutedForeground)
            }
            
            if !message.isFromMe {
                Spacer()
            }
        }
    }
}

struct Chat: Identifiable {
    let id = UUID()
    let creative: Creative
    let lastMessage: String
    let lastMessageTime: String
    let messages: [Message]
}

struct Message: Identifiable {
    let id = UUID()
    let text: String
    let isFromMe: Bool
    let time: String
}

let sampleChats: [Chat] = [
    Chat(
        creative: sampleCreatives[0],
        lastMessage: "Hey! I loved your portfolio",
        lastMessageTime: "2h ago",
        messages: [
            Message(text: "Hey! I loved your portfolio", isFromMe: false, time: "10:30 AM"),
            Message(text: "Thank you! Yours is amazing too", isFromMe: true, time: "10:32 AM"),
            Message(text: "Would love to collaborate sometime", isFromMe: false, time: "10:35 AM")
        ]
    ),
    Chat(
        creative: sampleCreatives[1],
        lastMessage: "Thanks for the connection!",
        lastMessageTime: "1d ago",
        messages: [
            Message(text: "Thanks for the connection!", isFromMe: false, time: "Yesterday")
        ]
    )
]

#Preview {
    NavigationView {
        ChatsView()
    }
}

