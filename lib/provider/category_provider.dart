import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:we_spilit/model/category_model.dart';
import 'package:we_spilit/model/admin_log_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CategoryProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;

  List<CategoryModel> _categories = [];
  bool _isLoading = false;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;

  /// Fetch categories globally. Creates default categories if DB is empty.
  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();
    try {
      final snap = await _db.collection('categories').orderBy('createdAt').get();

      if (snap.docs.isEmpty) {
        // Build initial defaults if exactly empty
        await _createDefaultCategories();
      } else {
        _categories = snap.docs
            .map((d) => CategoryModel.fromJson(d.data()))
            .toList();
      }
    } catch (_) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _createDefaultCategories() async {
    final defaults = ['Personal', 'Business', 'Student', 'Other'];
    final newCats = <CategoryModel>[];
    
    for (String name in defaults) {
      final catId = DateTime.now().microsecondsSinceEpoch.toString();
      final model = CategoryModel(
        categoryId: catId,
        categoryName: name,
        createdAt: DateTime.now(),
      );
      await _db.collection('categories').doc(catId).set(model.toJson());
      newCats.add(model);
      await Future.delayed(const Duration(milliseconds: 10)); // Ensure unique ordered IDs
    }
    _categories = newCats;
  }

  // ── Admin Functions ────────────────────────────────────────────────────────
  
  Future<void> addCategory(String name) async {
    final catId = DateTime.now().millisecondsSinceEpoch.toString();
    final model = CategoryModel(
      categoryId: catId,
      categoryName: name.trim(),
      createdAt: DateTime.now(),
    );
    try {
      await _db.collection('categories').doc(catId).set(model.toJson());
      _categories.add(model);
      _logAdminAction('category_created', 'Added: ${name.trim()}', newData: name.trim());
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateCategory(String id, String newName) async {
    try {
      await _db.collection('categories').doc(id).update({
        'categoryName': newName.trim(),
      });
      final idx = _categories.indexWhere((c) => c.categoryId == id);
      if (idx != -1) {
        final oldName = _categories[idx].categoryName;
        _categories[idx] = CategoryModel(
          categoryId: id,
          categoryName: newName.trim(),
          createdAt: _categories[idx].createdAt,
        );
        _logAdminAction('category_updated', 'Updated category', oldData: oldName, newData: newName.trim());
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCategory(String id, String name) async {
    try {
      await _db.collection('categories').doc(id).delete();
      _categories.removeWhere((c) => c.categoryId == id);
      _logAdminAction('category_deleted', 'Deleted: $name');
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  void _logAdminAction(String action, String target, {String? oldData, String? newData}) {
    try {
      final admin = FirebaseAuth.instance.currentUser;
      if (admin == null) return;
      final logId = DateTime.now().millisecondsSinceEpoch.toString();
      final log = AdminLogModel(
        logId: logId,
        action: action,
        adminUid: admin.uid,
        targetEmail: target,
        oldData: oldData,
        newData: newData,
        timestamp: DateTime.now(),
      );
      _db.collection('logs').doc(logId).set(log.toJson());
    } catch (_) {}
  }
}
