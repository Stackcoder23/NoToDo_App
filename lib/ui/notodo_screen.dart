import 'package:flutter/material.dart';
import 'package:notodo/model/nodo_item.dart';
import 'package:notodo/util/database_client.dart';

class NoToDoScreen extends StatefulWidget {
  @override
  _NoToDoScreenState createState() => _NoToDoScreenState();
}

class _NoToDoScreenState extends State<NoToDoScreen> {
  final TextEditingController _textEditingController =
      new TextEditingController();
  var db = new DatabaseHelper();

  final List<NoDoItem> itemList = <NoDoItem>[];

  @override
  void initState() {
    super.initState();

    _readNoDoList();
  }

  void _handleSubmit(String text) async {
    _textEditingController.clear();
    NoDoItem noDoItem = new NoDoItem(text, DateTime.now().toIso8601String());
    int savedItem = await db.saveItem(noDoItem);
    Navigator.pop(context);
    _readNoDoList();
    // NoDoItem addedItem = await db.getItem(savedItem);
    //
    // setState(() {
    //   itemList.insert(0, addedItem);
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Column(
        children: [
          Flexible(
              child: ListView.builder(
                  padding: EdgeInsets.all(8),
                  reverse: false,
                  itemCount: itemList.length,
                  itemBuilder: (_, int index) {
                    return Card(
                      color: Colors.white10,
                      child: ListTile(
                        title: itemList[index],
                        onLongPress: () => _updateNoDo(itemList[index], index),
                        trailing: Listener(
                          key: Key(itemList[index].itemName),
                          child: Icon(
                            Icons.remove_circle_outline,
                            color: Colors.red,
                          ),
                          onPointerDown: (pointerEvent) =>
                            _deleteNoDo(itemList[index].id),
                        ),
                      ),
                    );
                  })),
          Divider(
            height: 1,
          )
        ],
      ),
      floatingActionButton: new FloatingActionButton(
          backgroundColor: Colors.redAccent,
          child: new Icon(Icons.add),
          tooltip: "Add item",
          onPressed: _showFormDialog),
    );
  }

  void _showFormDialog() {
    var alert = new AlertDialog(
      content: Row(
        children: [
          Expanded(
              child: TextField(
            controller: _textEditingController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: "Item",
              hintText: "Add NoToDo",
              icon: Icon(Icons.note_add),
            ),
          ))
        ],
      ),
      actions: [
        TextButton(
            onPressed: () {
              _handleSubmit(_textEditingController.text);
              _textEditingController.clear();
            },
            child: Text("Save")),
        TextButton(
            onPressed: () => Navigator.pop(context), child: Text("Cancel"))
      ],
    );
    showDialog(
        context: context,
        builder: (_) {
          return alert;
        });
  }

  _readNoDoList() async {
    List items = await db.getItems();
    itemList.clear();
    items.forEach((item) {
      setState(() {
          itemList.add(NoDoItem.map(item));
      });
      // NoDoItem noDoItem = NoDoItem.map(item);
      // print("Db Items: ${noDoItem.itemName}");
    });
  }

  _deleteNoDo(int id) async{
    await db.deleteItem(id);
    _readNoDoList();
  }

  _updateNoDo(NoDoItem itemList, int index) async{
    var alert = new AlertDialog(
      title: Text("Update Item"),
      content: Row(
        children: [
          Expanded(child: TextField(
            controller: _textEditingController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: "Item",
              hintText: "Add NoToDo",
              icon: Icon(Icons.update_outlined),
            ),
          ))
        ],
      ),
      actions: [
        TextButton(
            onPressed: () async {
              NoDoItem itemUpdated = NoDoItem.fromMap(
                { "itemName": _textEditingController.text,
                  "dateCreated": DateTime.now().toIso8601String(),
                  "id": itemList.id,
                }
              );
              await db.updateItem(itemUpdated);
              _readNoDoList();
              _textEditingController.clear();
              Navigator.pop(context);
            } ,
            child: Text("Update")),
        TextButton(
            onPressed: () => Navigator.pop(context), child: Text("Cancel"))
      ],
    );
    showDialog(context: context, builder: (_){
      return alert;
    });

  }

}
