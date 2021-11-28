//
//  ContentView.swift
//  TodoList
//
//  Created by 毕靖翔 on 2021/11/28.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var userData: ToDo = ToDo(data: [
        SingleToDo(title: "Hello", duedate: Date()),
        SingleToDo(title: "Game Time", duedate: Date()),
        SingleToDo(title: "Sleep", duedate: Date())
    ])
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack {
                ForEach(self.userData.TodoList) {item in
                    SingleCardView(index: item.id)
                        .environmentObject(self.userData)
                    .padding(.horizontal)
                }
            }
        }
        
    }
}

struct SingleCardView: View {
    @EnvironmentObject var userData: ToDo
    var index: Int
    
    var body: some View {
        HStack {
            Rectangle()
                .frame(width: 6)
                .foregroundColor(.blue)
            VStack(alignment: .leading, spacing: 6.0) {
                Text(self.userData.TodoList[index].title)
                    .font(.headline)
                    .fontWeight(.heavy)
                Text(self.userData.TodoList[index].duedate.description)
                    .font(.subheadline)
                    .foregroundColor(Color.gray)
            }
            .padding(.leading)
            
            Spacer()
            
            Image(systemName: self.userData.TodoList[index].isChecked ? "checkmark.square.fill" :"square")
                .imageScale(.large)
                .padding(.trailing)
                .onTapGesture {
                    self.userData.check(id: index)
                }
        }.frame(height: 80)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 10, x: 0, y: 10)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
