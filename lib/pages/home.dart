import 'package:blogapp/services/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController textController = TextEditingController();

  // Dialog box to add or update a blog
  void openBlogBox({String? docID, String? existingBlog}) {
    textController.text = existingBlog ?? '';

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(
                controller: textController,
                decoration: const InputDecoration(hintText: 'Enter blog content'),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    if (textController.text.isNotEmpty) {
                      try {
                        if (docID == null) {
                          await firestoreService.addBlog(textController.text);
                        } else {
                          await firestoreService.updateBlog(
                              docID, textController.text);
                        }
                        Navigator.of(context).pop(); // Close the dialog
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Blog saved successfully!')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${e.toString()}')),
                        );
                      }
                      textController.clear();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Blog content cannot be empty')),
                      );
                    }
                  },
                  child: const Text('Save Blog'),
                ),
              ],
            ));
  }

  // Delete a blog
  void deleteBlog(String docID) async {
    try {
      await firestoreService.deleteBlog(docID);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Blog deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text("Notes"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openBlogBox(),
        backgroundColor: Colors.amberAccent,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getBlogStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List blogList = snapshot.data!.docs;
            return ListView.builder(
              itemCount: blogList.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = blogList[index];
                String docID = document.id;

                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                String blogText = data['blog'];

                return ListTile(
                  title: Text(blogText),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => openBlogBox(
                          docID: docID,
                          existingBlog: blogText,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteBlog(docID),
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text("No Blogs..."));
          }
        },
      ),
    );
  }
}
