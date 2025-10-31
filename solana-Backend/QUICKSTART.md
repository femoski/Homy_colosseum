# Quick Start Guide

## 🚀 Get Started in 5 Minutes

### 1. Install Dependencies
```bash
npm install
```

### 2. Run Setup Script
```bash
npm run setup
```
This will:
- Create `.env` file from template
- Create logs directory
- Test wallet service initialization
- Generate a sample wallet

### 3. Configure Your Wallet
Edit `.env` file with your actual wallet details:
```env
MAIN_WALLET_PRIVATE_KEY=[1,2,3,...] # Your wallet private key as array
MAIN_WALLET_ADDRESS=YourWalletAddress
```

### 4. Start Development Server
```bash
npm run dev
```

### 5. Test the API
```bash
# Health check
curl http://localhost:3000/health

# Get wallet balance
curl http://localhost:3000/api/wallet/balance

# Send SOL (example)
curl -X POST http://localhost:3000/api/wallet/send \
  -H "Content-Type: application/json" \
  -d '{
    "to": "recipient_address",
    "amount": 0.1,
    "memo": "Test transfer"
  }'
```

## 🔧 Configuration Options

### Solana Networks
- **Devnet** (default): `SOLANA_NETWORK=devnet`
- **Testnet**: `SOLANA_NETWORK=testnet`  
- **Mainnet**: `SOLANA_NETWORK=mainnet-beta`

### RPC Endpoints
- **Devnet**: `https://api.devnet.solana.com`
- **Testnet**: `https://api.testnet.solana.com`
- **Mainnet**: `https://api.mainnet-beta.solana.com`

## 📋 API Endpoints Summary

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/health` | Health check |
| GET | `/api/wallet/balance` | Complete wallet balance |
| GET | `/api/wallet/sol-balance` | SOL balance only |
| GET | `/api/wallet/token-balances` | SPL token balances |
| POST | `/api/wallet/send` | Send SOL |
| POST | `/api/wallet/send-token` | Send SPL tokens |
| POST | `/api/wallet/withdraw` | Process withdrawal |
| POST | `/api/wallet/generate` | Generate new wallet |
| GET | `/api/wallet/transaction/{sig}` | Get transaction details |
| GET | `/api/wallet/info` | Wallet information |

## 🛠️ Development Commands

```bash
# Development
npm run dev              # Start dev server with hot reload
npm run build            # Build for production
npm start                # Start production server

# Testing
npm test                 # Run tests
npm run test:coverage    # Run tests with coverage

# Code Quality
npm run lint             # Check code style
npm run lint:fix         # Fix code style issues

# Setup
npm run setup            # Run setup script
```

## 🐳 Docker Deployment

```bash
# Build and run with Docker
docker build -t sola-backend .
docker run -p 3000:3000 --env-file .env sola-backend

# Or use Docker Compose
docker-compose up -d
```

## 🔍 Troubleshooting

### Common Issues:

1. **"Invalid wallet private key format"**
   - Ensure private key is in array format: `[1,2,3,...]`
   - Check JSON formatting in `.env`

2. **"Failed to retrieve wallet balance"**
   - Verify RPC endpoint is accessible
   - Check wallet address is correct
   - Ensure sufficient network connectivity

3. **"Insufficient SOL balance"**
   - Check wallet balance
   - Account for transaction fees
   - Verify minimum balance threshold

### Getting Help:
- Check logs in `logs/` directory
- Verify environment configuration
- Test with Solana CLI tools
- Review API documentation in README.md

## 📚 Next Steps

1. **Production Setup**: Configure production environment variables
2. **Security**: Implement API key authentication
3. **Monitoring**: Set up health checks and monitoring
4. **Testing**: Add comprehensive test coverage
5. **Documentation**: Customize API documentation for your use case

Happy coding! 🎉
