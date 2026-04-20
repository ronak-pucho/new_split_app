import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:we_spilit/model/admin_log_model.dart';
import 'package:we_spilit/model/user_model.dart';
import 'package:we_spilit/model/account_request_model.dart';
import 'package:we_spilit/model/group_model.dart';

class AdminProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;

  List<UserModel> _users = [];
  List<AdminLogModel> _logs = [];
  List<AccountRequestModel> _requests = [];
  List<GroupModel> _groups = [];
  bool _isLoading = false;
  int _cooldownHours = 12;

  List<UserModel> get users => _users;
  List<AdminLogModel> get logs => _logs;
  List<AccountRequestModel> get requests => _requests;
  List<GroupModel> get groups => _groups;
  bool get isLoading => _isLoading;
  int get cooldownHours => _cooldownHours;

  Future<void> fetchSettings() async {
    try {
      final doc = await _db.collection('settings').doc('app_config').get();
      if (doc.exists) {
        _cooldownHours = doc.data()?['cooldownHours'] ?? 12;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> updateCooldown(int hours) async {
    try {
      await _db.collection('settings').doc('app_config').set(
        {'cooldownHours': hours},
        SetOptions(merge: true),
      );
      _cooldownHours = hours;
      notifyListeners();
    } catch (_) {}
  }


  // ── Analytics getters ──────────────────────────────────────────────────────
  int get totalUsers => _users.length;
  int get activeUsers =>
      _users.where((u) => u.status == 'active').length;

  Map<String, int> get categoryDistribution {
    final map = <String, int>{};
    for (final u in _users) {
      final cat = u.category ?? 'Other';
      map[cat] = (map[cat] ?? 0) + 1;
    }
    return map;
  }

  /// Users created per month for the last 6 months
  Map<String, int> get usersPerMonth {
    final now = DateTime.now();
    final map = <String, int>{};
    for (var i = 5; i >= 0; i--) {
      final m = DateTime(now.year, now.month - i, 1);
      final label = '${_monthAbbr(m.month)}\'${m.year % 100}';
      map[label] = 0;
    }
    for (final u in _users) {
      if (u.createdAt == null) continue;
      final diff = now.difference(u.createdAt!).inDays;
      if (diff > 180) continue;
      final m = DateTime(u.createdAt!.year, u.createdAt!.month, 1);
      final label = '${_monthAbbr(m.month)}\'${m.year % 100}';
      map[label] = (map[label] ?? 0) + 1;
    }
    return map;
  }

  String _monthAbbr(int month) => [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][month - 1];

  // ── Data loaders ───────────────────────────────────────────────────────────
  Future<void> fetchAllUsers() async {
    _isLoading = true;
    notifyListeners();
    try {
      final snap = await _db.collection('users').get();
      _users = snap.docs
          .map((d) => UserModel.fromJson(d.data()))
          .toList();
    } catch (_) {} finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchLogs() async {
    try {
      final snap = await _db
          .collection('logs')
          .orderBy('timestamp', descending: true)
          .limit(100)
          .get();
      _logs = snap.docs
          .map((d) => AdminLogModel.fromJson(d.data()))
          .toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> fetchRequests() async {
    try {
      final snap = await _db
          .collection('account_requests')
          .where('status', isEqualTo: 'pending')
          .orderBy('timestamp', descending: true)
          .get();
      _requests = snap.docs
          .map((d) => AccountRequestModel.fromJson(d.data()))
          .toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> fetchAllGroups() async {
    try {
      final snap = await _db.collection('groups').get();
      _groups = snap.docs.map((d) => GroupModel.fromJson(d.data())).toList();
      notifyListeners();
    } catch (_) {}
  }

  // ── User management ────────────────────────────────────────────────────────
  Future<void> deleteUser(String uid, String email) async {
    try {
      await _db.collection('users').doc(uid).delete();
      _users.removeWhere((u) => u.userId == uid);

      // Write audit log
      final logId = DateTime.now().millisecondsSinceEpoch.toString();
      final log = AdminLogModel(
        logId: logId,
        action: 'user_deleted',
        targetUid: uid,
        targetEmail: email,
        adminUid: FirebaseAuth.instance.currentUser?.uid,
        timestamp: DateTime.now(),
      );
      await _db.collection('logs').doc(logId).set(log.toJson());
      _logs.insert(0, log);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> toggleUserType(String uid, String email, String newType) async {
    try {
      final idx = _users.indexWhere((u) => u.userId == uid);
      final oldType = idx != -1 ? _users[idx].userType : 'unknown';

      await _db.collection('users').doc(uid).update({'userType': newType});
      if (idx != -1) {
        _users[idx].userType = newType;
      }
      
      final logId = DateTime.now().millisecondsSinceEpoch.toString();
      final log = AdminLogModel(
        logId: logId,
        action: 'user_type_changed',
        targetUid: uid,
        targetEmail: email,
        adminUid: FirebaseAuth.instance.currentUser?.uid,
        oldData: oldType,
        newData: newType,
        timestamp: DateTime.now(),
      );
      await _db.collection('logs').doc(logId).set(log.toJson());
      _logs.insert(0, log);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> toggleUserStatus(String uid, String email, String newStatus) async {
    try {
      final idx = _users.indexWhere((u) => u.userId == uid);
      final oldStatus = idx != -1 ? _users[idx].status : 'unknown';

      await _db.collection('users').doc(uid).update({'status': newStatus});
      if (idx != -1) {
        _users[idx].status = newStatus;
      }
      
      final logId = DateTime.now().millisecondsSinceEpoch.toString();
      final log = AdminLogModel(
        logId: logId,
        action: 'user_status_changed',
        targetUid: uid,
        targetEmail: email,
        adminUid: FirebaseAuth.instance.currentUser?.uid,
        oldData: oldStatus,
        newData: newStatus,
        timestamp: DateTime.now(),
      );
      await _db.collection('logs').doc(logId).set(log.toJson());
      _logs.insert(0, log);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> toggleGroupStatus(String groupId, bool newStatus) async {
    try {
      await _db.collection('groups').doc(groupId).update({'isActive': newStatus});
      final idx = _groups.indexWhere((g) => g.groupId == groupId);
      if (idx != -1) {
        _groups[idx].isActive = newStatus;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resolveRequest(String requestId) async {
    try {
      await _db.collection('account_requests').doc(requestId).update({'status': 'resolved'});
      _requests.removeWhere((r) => r.requestId == requestId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> replyToRequest(String requestId, String replyMessage) async {
    try {
      await _db.collection('account_requests').doc(requestId).update({
        'adminReply': replyMessage,
        'adminReplyTime': DateTime.now().toIso8601String(),
      });
      final idx = _requests.indexWhere((r) => r.requestId == requestId);
      if (idx != -1) {
        final old = _requests[idx];
        _requests[idx] = AccountRequestModel(
          requestId: old.requestId,
          userId: old.userId,
          userEmail: old.userEmail,
          userName: old.userName,
          message: old.message,
          status: old.status,
          timestamp: old.timestamp,
          adminReply: replyMessage,
          adminReplyTime: DateTime.now(),
        );
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logAdminLogin(String adminUid, String? email) async {
    try {
      final logId = DateTime.now().millisecondsSinceEpoch.toString();
      final log = AdminLogModel(
        logId: logId,
        action: 'admin_login',
        adminUid: adminUid,
        targetEmail: email ?? 'Admin User',
        timestamp: DateTime.now(),
      );
      await _db.collection('logs').doc(logId).set(log.toJson());
      _logs.insert(0, log);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> logAdminLogout(String adminUid, String? email) async {
    try {
      final logId = DateTime.now().millisecondsSinceEpoch.toString();
      final log = AdminLogModel(
        logId: logId,
        action: 'admin_logout',
        adminUid: adminUid,
        targetEmail: email ?? 'Admin User',
        timestamp: DateTime.now(),
      );
      await _db.collection('logs').doc(logId).set(log.toJson());
      _logs.insert(0, log);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> logUserAction(String uid, String? email, String action, {String? oldData, String? newData}) async {
    try {
      final logId = DateTime.now().millisecondsSinceEpoch.toString();
      final log = AdminLogModel(
        logId: logId,
        action: action,
        targetUid: uid,
        targetEmail: email ?? 'Unknown User',
        oldData: oldData,
        newData: newData,
        timestamp: DateTime.now(),
      );
      await _db.collection('logs').doc(logId).set(log.toJson());
    } catch (_) {}
  }

  // ── Admin check ────────────────────────────────────────────────────────────
  static Future<bool> isAdmin(String uid) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (userDoc.exists && userDoc.data()?['userType'] == 'admin') {
      return true;
    }
    return false;
  }
}
