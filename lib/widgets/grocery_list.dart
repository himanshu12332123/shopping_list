import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';

import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';

class GroceryList extends StatefulWidget{
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
 List<GroceryItem> _groceryItems = [];
late  Future<List<GroceryItem>>_loadedItems;
 String? _error; 

  @override
  void initState() {
     
    super.initState();
  _loadedItems =  _loadItems();
  }

  Future< List<GroceryItem>> _loadItems() async {
     final url =
 Uri.https(
  'flutter-prep-cd57f-default-rtdb.firebaseio.com','shopping-list.json'
  );

  
  final response = await http.get(url);
  
  if(response.statusCode >= 400){
  //  setState(() {
  //    _error = 'failed to fetch data.please try again later';
  //  });
  throw Exception('failed to fetch groceery items.please try again ');
  }
   
   if(response.body == 'null'){
    return [];
   }


  print(response.body);
  final Map<String,dynamic> listData =  json.decode(response.body);
  final List<GroceryItem> loadedItems = [];

  for(final item in listData.entries) {
    final category = categories.entries.firstWhere((catItem) => catItem.value.title == item.value['category']).value;
   loadedItems.add(
    GroceryItem(
      id: item.key,
      name: item.value['name'],
      quantity: item.value['quantity'],
       category: category
       )
       );
  }
 return loadedItems;

  

  // throw Exception('An error occurred!');

  }

  void _addItem() async {
   final newItem =  await Navigator.of(context).push<GroceryItem>(
    MaterialPageRoute(
      builder: (ctx) => NewItem()
      )
  );

  if(newItem == null){
    return;
  }
  
  setState( (){
   _groceryItems.add(newItem);
  });

// _loadItems();
 
  
  }
  
  void _removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
   _groceryItems.remove(item);
 });
         final url = Uri.https('flutter-prep-cd57f-default-rtdb.firebaseio.com',
         'shopping-list/${item.id}.json');

 final response = await http.delete(url);
   if(response.statusCode >= 400){
     setState(() {
   _groceryItems.insert(index,item);
 });
   }
 

  }
  @override
  Widget build(BuildContext context) {

  // Widget content = 
 
   
  //  if (_groceryItems.isNotEmpty) {
  //   content = 
  //  }

  //  if(_error != null){
  //   content =

  //  }

   return  Scaffold(
    appBar: AppBar(
    title: const Text('Your Groceries') ,
    actions: [
      IconButton(
        onPressed: _addItem,
         icon: Icon(Icons.add),
         )
    ],

    ),
    body: FutureBuilder(
      future: _loadedItems,
       builder: (context,snapshot){ 
        if(snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

         if(snapshot.hasError) {
          return  Center(child: Text(snapshot.error.toString()),);
        }

        if(snapshot.data!.isEmpty){
          return Center(child: Text('No items added yet'),);
        }

        return ListView.builder(
      itemCount: snapshot.data!.length,
      itemBuilder: (ctx,index) => Dismissible(
        onDismissed: (direction){
       _removeItem(snapshot.data![index]);
        },
        key: ValueKey(snapshot.data![index].id),
        child: ListTile(
          title: Text(snapshot.data![index].name) ,
          leading: Container(
            width:24,
            height:24,
            color:snapshot.data![index].category.color,
          ),
          trailing: Text(snapshot.data![index].quantity.toString()),
        ),
      ),
      );

       }),
   );
  }
}