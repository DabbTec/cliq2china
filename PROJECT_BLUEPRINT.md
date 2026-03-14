# Cliq2China Project Blueprint & Roadmap

## 1. Project Overview
A multi-platform (Web & Mobile) marketplace ecosystem connecting Buyers and Sellers, inspired by the AliExpress model, with integrated FinTech features (Loans/Wallet) and a robust Admin Management system.

### Tech Stack
- **Mobile & Web**: Flutter (Shared codebase for iOS, Android, and Web)
- **Backend**: Django REST Framework (DRF)
- **Database**: PostgreSQL (Production) / SQLite (Development)
- **Third-Party**: Paystack/Flutterwave (Payments), Firebase (Notifications), Smile ID (KYC).

---

## 2. Platform Architecture

### A. Flutter Mobile (iOS & Android)
- **Shared Logic**: State management (GetX), API Service, Theme/UI Kit.
- **Buyer Mode**: 
  - Home (Marketplace Feed), Search, Cart, Tracking, Support.
- **Seller Mode**: 
  - Inventory management, Order fulfillment, Payout tracking.
- **FinTech Module**: 
  - Wallet Dashboard & Loan Application.

### B. Flutter Web (Landing & Admin)
- **Landing Page**: Public-facing, SEO-optimized product discovery.
- **Admin Dashboard**: Bulk user management, Seller approval, Loan vetting, Marketplace analytics.

---

## 3. Detailed Feature Breakdown

### Authentication & Onboarding
- **Guest Access**: Browse marketplace without login.
- **Social Login**: Google/Facebook integration.
- **Role Selection**: Post-login switchable role selection (Buyer vs. Seller).
- **Onboarding**: Distinct steps for identity verification (KYC) for Sellers.

### Marketplace (AliExpress Model)
- **Buyer Functions**: Purchase products, track orders, contact support, leave reviews, dispute resolution.
- **Seller Functions**: List products, manage stock, view sales analytics, manage payouts.
- **In-App Chat**: Real-time buyer-seller interaction.

### FinTech (Wallet & Loan)
- **Integrated Wallet**: Displays available balance, earnings (for sellers), and loan status.
- **Loan Management**: Application flow, status tracking, and disbursement history.

### Referral Program
- Unique referral codes and copyable share links generated post-signup.

---

## 4. 30-Day Development Roadmap

| Week | Focus | Daily Tasks |
| :--- | :--- | :--- |
| **Week 1** | **UI Foundation & Auth** | D1: UI Kit (Colors, Typography). D2: Auth Screens. D3: Role Selection. D4: Onboarding Flow. D5: Social Auth UI. D6-7: Guest Home Screen. |
| **Week 2** | **Marketplace UI** | D8: Home Feed. D9: Search & Filter. D10: Product Detail. D11: Shopping Cart. D12: Order Tracking UI. D13-14: Review & Support UI. |
| **Week 3** | **Seller & FinTech UI** | D15: Seller Dashboard. D16: Inventory Management. D17: Order Fulfillment UI. D18: Wallet UI. D19: Loan Application UI. D20-21: Referral UI. |
| **Week 4** | **Web & Admin UI** | D22: Responsive Landing Page. D23: Admin Layout. D24: User Management Tables. D25: Seller Approval Flow. D26: Loan Vetting UI. D27-30: Integration & Polish. |

---

## 5. Third-Party Integration Recommendations
1. **Payments**: Paystack/Flutterwave (for local & international trade).
2. **Chat**: Stream Chat or WebSocket (Django Channels).
3. **KYC/KYB**: Smile ID (identity verification).
4. **Cloud Storage**: AWS S3 (product images/docs).
5. **Notifications**: Firebase Cloud Messaging (FCM).
