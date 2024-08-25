import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference blogs =
      FirebaseFirestore.instance.collection('blog');

  //Creat
  Future<void> addBlog(String blog) {
    return blogs.add({
      'blog': blog,
      'timestamp': Timestamp.now(),
    });
  }

  Stream<QuerySnapshot> getBlogStream() {
    final blogsStream =
        blogs.orderBy('timestamp', descending: true).snapshots();

    return blogsStream;
  }
}