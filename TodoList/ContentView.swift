//
//  ContentView.swift
//  TodoList
//
//  Created by 毕靖翔 on 2021/11/28.
//

import SwiftUI


/// 初始化卡片数据
/// - Returns: 卡片数组
func initUserData() -> [SingleToDo] {
    var output: [SingleToDo] = []
    if let dataStored = UserDefaults.standard.object(forKey: "TodoList") as? Data {
        let data = try! decoder.decode([SingleToDo].self, from: dataStored)
        for item in data {
            // 没有被删除才放进卡片
            if(!item.deleted) {
                output.append(SingleToDo(id: data.count, title: item.title, duedate: item.duedate, isChecked: item.isChecked))
            }
        }
    }
    
    return output
}

struct ContentView: View {
    @ObservedObject var userData: ToDo = ToDo(data: initUserData())
    
    @State var showEditingPage: Bool = false
    
    var body: some View {
        ZStack {
            NavigationView {
                ScrollView(.vertical, showsIndicators: true) {
                    VStack {
                        ForEach(self.userData.todoList) {item in
                            // 没有被删除才放进卡片
                            if(!item.deleted) {
                                SingleCardView(index: item.id)
                                    .environmentObject(self.userData)
                                .padding(.horizontal)
                                .padding(.top)
                            }
                        }
                    }
                }.navigationTitle("提醒事项")
            }
            
            HStack {
                Spacer()
                VStack {
                    Spacer()
                    Button(action: {
                        self.showEditingPage = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80)
                            .foregroundColor(.blue)
                            .padding(.trailing)
                    }.sheet(isPresented: self.$showEditingPage, content: {
                        EditingPage().environmentObject(self.userData)
                    })
                }
            }
        }
        
    }
}

struct SingleCardView: View {
    @EnvironmentObject var userData: ToDo
    
    // 是否显示编辑弹窗
    @State var showEditingPage: Bool = false
    
    var index: Int
    
    var body: some View {
        HStack {
            // 蓝色矩形
            Rectangle()
                .frame(width: 6)
                .foregroundColor(.blue)
            
            Button(action: {
                self.userData.delete(id: self.index)
            }) {
                Image(systemName: "trash")
                    .imageScale(.large)
                    .padding(.leading)
            }
            
            Button(action: {
                self.showEditingPage = true
            }) {
                // 中间todo
                Group {
                    VStack(alignment: .leading, spacing: 6.0) {
                        Text(self.userData.todoList[index].title)
                            .font(.headline)
                            .fontWeight(.heavy)
                            .foregroundColor(.black)
                        Text(self.userData.todoList[index].duedate.description)
                            .font(.subheadline)
                            .foregroundColor(Color.gray)
                    }
                    .padding(.leading)
                    
                    Spacer()
                }
            }
            .sheet(isPresented: self.$showEditingPage, content: {
                EditingPage(title: self.userData.todoList[index].title,
                            duedate: self.userData.todoList[index].duedate,
                            id: self.index)
                    .environmentObject(self.userData)
            })
            
            // 选择框
            Image(systemName: self.userData.todoList[index].isChecked ? "checkmark.square.fill" :"square")
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
