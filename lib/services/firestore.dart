import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference blogs =
      FirebaseFirestore.instance.collection('blogs');

  // Create
  Future<void> addBlog(String blog) {
    return blogs.add({
      'blog': blog,
      'timestamp': Timestamp.now(),
    });
  }

  // Update
  Future<void> updateBlog(String docID, String updatedBlog) {
    return blogs.doc(docID).update({
      'blog': updatedBlog,
      'timestamp': Timestamp.now(),
    });
  }

  // Delete
  Future<void> deleteBlog(String docID) {
    return blogs.doc(docID).delete();
  }

  Stream<QuerySnapshot> getBlogStream() {
    final blogsStream =
        blogs.orderBy('timestamp', descending: true).snapshots();
    return blogsStream;
  }
}
