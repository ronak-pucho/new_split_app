import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:we_spilit/model/user_model.dart';
import 'package:we_spilit/model/account_request_model.dart';
import 'package:we_spilit/services/storage_service.dart';
import 'dart:io';

class UserProvider extends ChangeNotifier {
  final _fireStore = FirebaseFirestore.instance;
  final _storageService = StorageService();

  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  // ── Create / overwrite user doc ──────────────────────────────────────────
  Future<void> setUserData({
    required String id,
    required String userName,
    required String userEmail,
    String? phoneNumber,
    String? category,
  }) async {
    final userModel = UserModel(
      userId: id,
      userName: userName,
      userEmail: userEmail,
      phoneNumber: phoneNumber,
      category: category ?? 'Personal',
      status: 'active',
      createdAt: DateTime.now(),
    );
    await _fireStore.collection('users').doc(id).set(userModel.toJson());
    _currentUser = userModel;
    notifyListeners();
  }

  // ── Fetch currently logged-in user from Firestore ────────────────────────
  Future<void> fetchCurrentUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      final doc = await _fireStore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        _currentUser = UserModel.fromJson(doc.data()!);
      }
    } catch (_) {} finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Request Activation ───────────────────────────────────────────────────
  Future<void> submitActivationRequest(String message) async {
    if (_currentUser == null) return;
    try {
      final reqId = DateTime.now().millisecondsSinceEpoch.toString();
      final request = AccountRequestModel(
        requestId: reqId,
        userId: _currentUser!.userId,
        userEmail: _currentUser!.userEmail,
        userName: _currentUser!.userName,
        message: message.trim(),
        timestamp: DateTime.now(),
      );
      await _fireStore.collection('account_requests').doc(reqId).set(request.toJson());
    } catch (e) {
      rethrow;
    }
  }

  // ── Update profile fields ────────────────────────────────────────────────
  Future<void> updateProfile({
    String? userName,
    String? phoneNumber,
    String? category,
    File? imageFile,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      String? photoUrl = _currentUser?.photoUrl;
      if (imageFile != null) {
        final url = await _storageService.uploadProfileImage(imageFile, uid);
        if (url != null) photoUrl = url;
      }

      final updates = <String, dynamic>{};
      if (userName != null) updates['userName'] = userName;
      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
      if (category != null) updates['category'] = category;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;

      await _fireStore.collection('users').doc(uid).update(updates);
      _currentUser = _currentUser?.copyWith(
        userName: userName,
        phoneNumber: phoneNumber,
        category: category,
        photoUrl: photoUrl,
      );
    } catch (_) {} finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Delete account ───────────────────────────────────────────────────────
  Future<void> deleteAccount() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await _storageService.deleteProfileImage(uid);
      await _fireStore.collection('users').doc(uid).delete();
      await FirebaseAuth.instance.currentUser?.delete();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }
}
