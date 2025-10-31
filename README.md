# Homy - Real Estate Tokenization Platform

A Flutter-based mobile application that revolutionizes real estate through Solana blockchain integration, enabling property tokenization as NFTs (Non-Fungible Tokens). Homy allows users to purchase, own, and trade real estate properties as blockchain-verified digital assets.

## 🌟 Overview

Homy is a comprehensive property management platform that combines traditional real estate features with cutting-edge blockchain technology. By leveraging Solana's high-performance blockchain, Homy enables seamless tokenization of properties, creating transparent, secure, and easily transferable ownership certificates.

### Key Features

- **🔐 Solana Wallet Integration**: Connect and manage Solana wallets directly in the app using Solana Mobile Client
- **🏠 Property Tokenization**: Convert real estate properties into blockchain-verified NFTs
- **🪙 NFT Marketplace**: Browse, purchase, and trade property NFTs
- **✅ Ownership Verification**: Immutable proof of ownership on the Solana blockchain
- **📜 Certificate Minting**: Generate NFT certificates for property tours and purchases
- **💰 Multi-Payment Support**: Pay with SOL, credit cards, and other payment methods
- **📱 Cross-Platform**: Native iOS and Android support with Flutter

## 🚀 Tech Stack

### Frontend
- **Flutter** (SDK ^3.5.4) - Cross-platform mobile development
- **GetX** - State management and navigation
- **Firebase** - Push notifications and backend services

### Blockchain Integration
- **Solana Dart SDK** - Solana blockchain interactions
- **Solana Mobile Client** - Mobile wallet connectivity and transaction signing
- **Base58 Encoding** - Address encoding/decoding
- **Ed25519 Cryptography** - Key pair generation and signing

### Key Dependencies
```yaml
solana: # Solana blockchain SDK
solana_mobile_client: # Mobile wallet integration
get: ^4.6.6 # State management
firebase_core: ^3.15.2
firebase_messaging: ^15.2.10
google_maps_flutter: ^2.10.0
```

## 📋 Prerequisites

Before you begin, ensure you have:

- **Flutter SDK** 3.5.4 or higher
- **Dart SDK** compatible with Flutter
- **Android Studio** / **Xcode** for native development
- **Solana Wallet** (Phantom, Solflare, or compatible mobile wallet)
- **Firebase Account** for push notifications
- **Google Maps API Key** for location services

## 🛠️ Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd homy-colosseum
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Add your `google-services.json` (Android) to `android/app/`
   - Add your `GoogleService-Info.plist` (iOS) to `ios/Runner/`
   - Configure Firebase in `lib/firebase_options.dart`

4. **Configure API Keys**
   - Update `lib/utils/app_constant.dart` with your API keys:
     - Google Maps API key
     - Payment gateway keys (Paystack, Razorpay, PayPal)
     - Backend API base URL

5. **Configure Solana Network**
   - Set your Solana RPC endpoint in the configuration service
   - Default: Devnet (`https://api.devnet.solana.com`)
   - For production: Use Mainnet RPC endpoints

6. **Run the application**
   ```bash
   flutter run
   ```

## 🏗️ Architecture

### Project Structure

```
lib/
├── services/
│   ├── solana_wallet_service.dart    # Solana wallet operations
│   └── nft_marketplace_service.dart  # NFT marketplace logic
├── models/
│   └── nft_property_model.dart       # NFT property data model
├── screens/
│   └── properties/
│       └── nft_marketplace_screen.dart
├── controllers/
│   └── nft_marketplace_controller.dart
└── utils/
    └── constants.dart
```

### Core Services

#### SolanaWalletService
Manages all Solana blockchain interactions:
- Wallet connection/disconnection
- Balance fetching
- Transaction signing and sending
- NFT minting
- Certificate generation

#### NFTMarketplaceService
Handles marketplace operations:
- Property NFT listing
- Purchase transactions
- Ownership verification
- Transaction history

## 🔑 Key Features Explained

### 1. Solana Wallet Integration

Connect your Solana wallet (Phantom, Solflare, etc.) to the app:

```dart
// Connect wallet
await SolanaWalletService.to.connectWallet();

// Check balance
final balance = await SolanaWalletService.to.fetchBalance();

// Get wallet address
final address = SolanaWalletService.to.walletAddress.value;
```

### 2. Property Tokenization

Convert properties into NFTs on the Solana blockchain:

```dart
// Mint property as NFT
final result = await SolanaWalletService.to.mintNFT({
  'name': 'Property Name',
  'description': 'Property description',
  'imageUrl': 'https://...',
  'propertyId': '123',
  // ... other metadata
});
```

### 3. NFT Marketplace

Browse and purchase property NFTs:

```dart
// Get marketplace listings
final properties = await NFTMarketplaceService.to.getNFTProperties(
  page: 1,
  limit: 20,
  filter: 'verified',
);

// Purchase property
final purchase = await NFTMarketplaceService.to.completePurchaseAndMint(
  property: propertyNFT,
  paymentMethod: 'solana',
);
```

### 4. Certificate Minting

Generate NFT certificates for property tours and bookings:

```dart
// Mint tour certificate
final certificate = await SolanaWalletService.to.mintNFTCertificate({
  'title': 'Property Tour Certificate',
  'description': 'Certified tour booking',
  'imageUrl': 'https://...',
  'propertyId': '123',
});
```

## 🌐 Solana Network Configuration

The app supports both Devnet (testing) and Mainnet (production):

- **Devnet**: `https://api.devnet.solana.com`
- **Mainnet**: `https://api.mainnet-beta.solana.com`

Configure the network in your backend configuration service.

## 🔒 Security Features

- **Secure Key Management**: Private keys never leave the device
- **Mobile Wallet Integration**: Uses Solana Mobile Client for secure transaction signing
- **Transaction Verification**: All transactions are verified on-chain
- **Ownership Verification**: Immutable proof of ownership via blockchain

## 📱 Supported Platforms

- ✅ **Android** (API 21+)
- ✅ **iOS** (iOS 12.0+)
- ⚠️ **Web** (Partial support)

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/
```

## 📦 Building for Production

### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🔗 Resources

- [Solana Documentation](https://docs.solana.com/)
- [Solana Mobile Client](https://docs.solanamobile.com/)
- [Flutter Documentation](https://docs.flutter.dev/)
- [NFT Standards on Solana](https://docs.metaplex.com/programs/token-metadata/)

## 💡 Features in Development

- [ ] Fractional property ownership (Tokenized Real Estate)
- [ ] Secondary marketplace for NFT trading
- [ ] Rental income distribution via tokens
- [ ] DAO governance for property management
- [ ] Cross-chain bridge support

## 📞 Support

For support, email support@homy.com or join our [Discord community](https://discord.gg/homy).

## 🙏 Acknowledgments

- Solana Foundation for blockchain infrastructure
- Metaplex for NFT standards and tooling
- Flutter team for the amazing framework

---

**Built with ❤️ using Flutter and Solana**
# Homy-colosseum
# Homy-colosseum
# Homy_colosseum
