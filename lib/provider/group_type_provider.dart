import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:we_spilit/model/group_type_model.dart';
import 'package:we_spilit/model/admin_log_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroupTypeProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;

  List<GroupTypeModel> _groupTypes = [];
  bool _isLoading = false;

  List<GroupTypeModel> get groupTypes => _groupTypes;
  bool get isLoading => _isLoading;

  Future<void> fetchGroupTypes() async {
    if (_groupTypes.isNotEmpty) return;
    _isLoading = true;
    notifyListeners();
    try {
      final snap = await _db.collection('group_types').orderBy('createdAt').get();

      if (snap.docs.isEmpty) {
        await _createDefaultGroupTypes();
      } else {
        _groupTypes = snap.docs
            .map((d) => GroupTypeModel.fromJson(d.data()))
            .toList();
      }
    } catch (_) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _createDefaultGroupTypes() async {
    final defaults = ['Trip', 'Home', 'Couple', 'Other'];
    final newTypes = <GroupTypeModel>[];
    
    for (String name in defaults) {
      final id = DateTime.now().microsecondsSinceEpoch.toString();
      final model = GroupTypeModel(
        id: id,
        name: name,
        createdAt: DateTime.now(),
      );
      await _db.collection('group_types').doc(id).set(model.toJson());
      newTypes.add(model);
      await Future.delayed(const Duration(milliseconds: 10));
    }
    _groupTypes = newTypes;
  }

  // Admin
  Future<void> addGroupType(String name) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final model = GroupTypeModel(
      id: id,
      name: name.trim(),
      createdAt: DateTime.now(),
    );
    try {
      await _db.collection('group_types').doc(id).set(model.toJson());
      _groupTypes.add(model);
      _logAdminAction('group_type_created', 'Added: ${name.trim()}', newData: name.trim());
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateGroupType(String id, String newName) async {
    try {
      await _db.collection('group_types').doc(id).update({
        'name': newName.trim(),
      });
      final idx = _groupTypes.indexWhere((c) => c.id == id);
      if (idx != -1) {
        final oldName = _groupTypes[idx].name;
        _groupTypes[idx] = GroupTypeModel(
          id: id,
          name: newName.trim(),
          createdAt: _groupTypes[idx].createdAt,
        );
        _logAdminAction('group_type_updated', 'Updated Group Type', oldData: oldName, newData: newName.trim());
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteGroupType(String id, String name) async {
    try {
      await _db.collection('group_types').doc(id).delete();
      _groupTypes.removeWhere((c) => c.id == id);
      _logAdminAction('group_type_deleted', 'Deleted: $name');
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
