class ApiEndpoints {
  static const String baseUrl = 'http://localhost:8000/api'; // Mock for Django backend
  
  // Auth
  static const String login = '/auth/login/';
  static const String signup = '/auth/signup/';
  static const String profile = '/auth/profile/';
  
  // Products
  static const String products = '/products/';
  static const String categories = '/categories/';
  
  // Loans
  static const String loans = '/loans/';
  static const String loanHistory = '/loans/history/';
}
