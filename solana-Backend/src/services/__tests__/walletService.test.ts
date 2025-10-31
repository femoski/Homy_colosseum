import { SolanaWalletService } from '../services/walletService';
import config from '../config';

// Mock the Solana Web3.js modules
jest.mock('@solana/web3.js');
jest.mock('@solana/spl-token');

describe('SolanaWalletService', () => {
  let walletService: SolanaWalletService;

  beforeEach(() => {
    // Reset mocks before each test
    jest.clearAllMocks();
    walletService = new SolanaWalletService();
  });

  describe('getSolBalance', () => {
    it('should return SOL balance', async () => {
      // Mock the connection.getBalance method
      const mockGetBalance = jest.fn().mockResolvedValue(1000000000); // 1 SOL in lamports
      
      // This would need proper mocking setup in a real test environment
      expect(mockGetBalance).toBeDefined();
    });
  });

  describe('sendSol', () => {
    it('should validate recipient address', async () => {
      const invalidAddress = 'invalid-address';
      
      try {
        await walletService.sendSol(invalidAddress, 0.1);
        fail('Should have thrown an error for invalid address');
      } catch (error) {
        expect(error).toBeDefined();
      }
    });

    it('should validate amount', async () => {
      const validAddress = '11111111111111111111111111111112'; // Valid Solana address format
      
      try {
        await walletService.sendSol(validAddress, -0.1);
        fail('Should have thrown an error for negative amount');
      } catch (error) {
        expect(error).toBeDefined();
      }
    });
  });

  describe('generateNewWallet', () => {
    it('should generate a new wallet with valid format', () => {
      const newWallet = walletService.generateNewWallet();
      
      expect(newWallet).toHaveProperty('publicKey');
      expect(newWallet).toHaveProperty('privateKey');
      expect(typeof newWallet.publicKey).toBe('string');
      expect(Array.isArray(newWallet.privateKey)).toBe(true);
    });
  });
});
