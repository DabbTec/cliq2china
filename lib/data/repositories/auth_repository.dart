import '../models/user.dart';

class AuthRepository {
  Future<UserModel> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));
    if (email == 'admin@cliq2china.com') {
      return UserModel(id: '1', email: email, name: 'Admin', role: 'admin');
    } else if (email == 'seller@cliq2china.com') {
      return UserModel(id: '2', email: email, name: 'Seller User', role: 'seller');
    }
    return UserModel(id: '3', email: email, name: 'Buyer User', role: 'buyer');
  }

  Future<void> signup(UserModel user, String password) async {
    await Future.delayed(const Duration(seconds: 2));
  }
}
