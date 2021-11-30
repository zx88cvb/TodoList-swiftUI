//
//  EditingPage.swift
//  TodoList
//
//  Created by 毕靖翔 on 2021/11/29.
//

import SwiftUI

struct EditingPage: View {
    @EnvironmentObject var userData: ToDo
    
    @State var title: String = ""
    @State var duedate: Date = Date()
    
    var id: Int? = nil
    
    
    @Environment(\.presentationMode) var presentation
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(" 事项")) {
                    TextField("任务事项", text: self.$title)
                    DatePicker(selection: self.$duedate, label: { Text("截止时间") })
                }
                
                Section {
                    Button(action: {
                        if(id == nil) {
                            self.userData.add(data: SingleToDo(title: self.title, duedate: self.duedate))
                        } else {
                            self.userData.edit(id: self.id!, data: SingleToDo(title: self.title, duedate: self.duedate))
                        }
                        
                        self.presentation.wrappedValue.dismiss()
                    }) {
                        Text("确定")
                    }
                    Button(action: {
                        self.presentation.wrappedValue.dismiss()
                    }) {
                        Text("取消")
                    }
                }
            }.navigationTitle("添加")
        }
    }
}

struct EditingPage_Previews: PreviewProvider {
    static var previews: some View {
        EditingPage()
    }
}
