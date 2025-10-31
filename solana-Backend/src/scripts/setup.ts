#!/usr/bin/env node

import fs from 'fs';
import path from 'path';
import { SolanaWalletService } from '../services/walletService';

console.log('🚀 Sola Backend Setup Script');
console.log('============================\n');

async function setup() {
  try {
    // Check if .env file exists
    const envPath = path.join(process.cwd(), '.env');
    if (!fs.existsSync(envPath)) {
      console.log('📝 Creating .env file from template...');
      const envExample = fs.readFileSync(path.join(process.cwd(), 'env.example'), 'utf8');
      fs.writeFileSync(envPath, envExample);
      console.log('✅ .env file created. Please update it with your configuration.\n');
    } else {
      console.log('✅ .env file already exists.\n');
    }

    // Create logs directory
    const logsDir = path.join(process.cwd(), 'logs');
    if (!fs.existsSync(logsDir)) {
      console.log('📁 Creating logs directory...');
      fs.mkdirSync(logsDir, { recursive: true });
      console.log('✅ Logs directory created.\n');
    } else {
      console.log('✅ Logs directory already exists.\n');
    }

    // Test wallet service initialization
    console.log('🔧 Testing wallet service initialization...');
    try {
      const walletService = new SolanaWalletService();
      const address = walletService.getMainWalletAddress();
      console.log(`✅ Wallet service initialized successfully`);
      console.log(`📍 Main wallet address: ${address}\n`);
    } catch (error) {
      console.log('❌ Wallet service initialization failed:');
      console.log(`   ${error instanceof Error ? error.message : 'Unknown error'}`);
      console.log('   Please check your MAIN_WALLET_PRIVATE_KEY in .env file\n');
    }

    // Generate a sample wallet
    console.log('🆕 Generating sample wallet...');
    const walletService = new SolanaWalletService();
    const sampleWallet = walletService.generateNewWallet();
    console.log('✅ Sample wallet generated:');
    console.log(`   Public Key: ${sampleWallet.publicKey}`);
    console.log(`   Private Key: [${sampleWallet.privateKey.slice(0, 5).join(',')},...] (truncated)\n`);

    console.log('🎉 Setup completed successfully!');
    console.log('\nNext steps:');
    console.log('1. Update your .env file with your actual wallet configuration');
    console.log('2. Run "npm run dev" to start the development server');
    console.log('3. Test the API endpoints using the documentation in README.md');

  } catch (error) {
    console.error('❌ Setup failed:', error);
    process.exit(1);
  }
}

setup();
