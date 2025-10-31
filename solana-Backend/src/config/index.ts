import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

export interface Config {
  solana: {
    network: string;
    rpcUrl: string;
    wsUrl: string;
  };
  wallet: {
    privateKey: string;
    address: string;
  };
  server: {
    port: number;
    nodeEnv: string;
  };
  logging: {
    level: string;
    file: string;
  };
  security: {
    apiKey: string;
    jwtSecret: string;
  };
  transaction: {
    confirmationTimeout: number;
    maxRetries: number;
    minimumBalanceThreshold: number;
  };
  rateLimit: {
    windowMs: number;
    maxRequests: number;
  };
  storage?: {
    provider: 'pinata' | 'nft_storage' | 'none';
    pinataApiKey?: string;
    pinataSecretApiKey?: string;
    nftStorageToken?: string;
    gatewayUrl?: string;
  };
}

const config: Config = {
  solana: {
    network: process.env.SOLANA_NETWORK || 'devnet',
    rpcUrl: process.env.SOLANA_RPC_URL || 'https://api.devnet.solana.com',
    wsUrl: process.env.SOLANA_WS_URL || 'wss://api.devnet.solana.com',
  },
  wallet: {
    privateKey: process.env.MAIN_WALLET_PRIVATE_KEY || '',
    address: process.env.MAIN_WALLET_ADDRESS || '',
  },
  server: {
    port: parseInt(process.env.PORT || '3001', 10),
    nodeEnv: process.env.NODE_ENV || 'development',
  },
  logging: {
    level: process.env.LOG_LEVEL || 'info',
    file: process.env.LOG_FILE || 'logs/app.log',
  },
  security: {
    apiKey: process.env.API_KEY || '',
    jwtSecret: process.env.JWT_SECRET || '',
  },
  transaction: {
    confirmationTimeout: parseInt(process.env.CONFIRMATION_TIMEOUT || '30000', 10),
    maxRetries: parseInt(process.env.MAX_RETRIES || '3', 10),
    minimumBalanceThreshold: parseFloat(process.env.MINIMUM_BALANCE_THRESHOLD || '0.001'),
  },
  rateLimit: {
    windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '900000', 10),
    maxRequests: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '100', 10),
  },
  storage: {
    provider: (process.env.STORAGE_PROVIDER as 'pinata' | 'nft_storage' | 'none') || 'none',
    pinataApiKey: process.env.PINATA_API_KEY || '',
    pinataSecretApiKey: process.env.PINATA_SECRET_API_KEY || '',
    nftStorageToken: process.env.NFT_STORAGE_TOKEN || '',
    gatewayUrl: process.env.IPFS_GATEWAY_URL || 'https://ipfs.io',
  },
};

// Validate required configuration
if (!config.wallet.privateKey) {
  throw new Error('MAIN_WALLET_PRIVATE_KEY is required');
}

if (!config.wallet.address) {
  throw new Error('MAIN_WALLET_ADDRESS is required');
}

export default config;
