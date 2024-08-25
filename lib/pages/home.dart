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

  // Dialog box to add a blog
  void openBlogBox() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(
                controller: textController,
                decoration:
                    const InputDecoration(hintText: 'Enter blog content'),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    if (textController.text.isNotEmpty) {
                      try {
                        await firestoreService.addBlog(textController.text);
                        Navigator.of(context).pop(); // Close the dialog
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Blog added successfully!')),
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
                  child: const Text('Add Blog'),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text("Notes"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openBlogBox,
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
                );
              },
            );
          } else {
            return const Text("No Blogs...");
          }
        },
      ),
    );
  }
}
