import { Router, Request, Response } from 'express';
import { SolanaWalletService } from '../services/walletService';
import { validateRequest, asyncHandler } from '../middleware/validation';
import { sendSolSchema, sendTokenSchema, withdrawalSchema, transactionSignatureSchema } from '../validation/schemas';
import logger from '../utils/logger';

const router = Router();
const walletService = new SolanaWalletService();

/**
 * GET /wallet/balance
 * Get the main wallet's balance (SOL + tokens)
 */
router.get('/balance', asyncHandler(async (req: Request, res: Response) => {
  try {
    const balance = await walletService.getWalletBalance();
    
    res.json({
      success: true,
      data: {
        walletAddress: walletService.getMainWalletAddress(),
        balance,
        timestamp: new Date().toISOString(),
      },
    });
  } catch (error) {
    logger.error('Failed to get wallet balance:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to retrieve wallet balance',
    });
  }
}));

/**
 * GET /wallet/sol-balance
 * Get only the SOL balance
 */
router.get('/sol-balance', asyncHandler(async (req: Request, res: Response) => {
  try {
    const balance = await walletService.getSolBalance();
    
    res.json({
      success: true,
      data: {
        walletAddress: walletService.getMainWalletAddress(),
        solBalance: balance,
        timestamp: new Date().toISOString(),
      },
    });
  } catch (error) {
    logger.error('Failed to get SOL balance:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to retrieve SOL balance',
    });
  }
}));

/**
 * GET /wallet/token-balances
 * Get token balances
 */
router.get('/token-balances', asyncHandler(async (req: Request, res: Response) => {
  try {
    const tokenBalances = await walletService.getTokenBalances();
    
    res.json({
      success: true,
      data: {
        walletAddress: walletService.getMainWalletAddress(),
        tokenBalances,
        timestamp: new Date().toISOString(),
      },
    });
  } catch (error) {
    logger.error('Failed to get token balances:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to retrieve token balances',
    });
  }
}));

/**
 * POST /wallet/send
 * Send SOL or tokens to a recipient
 */
router.post('/send', validateRequest(sendSolSchema), asyncHandler(async (req: Request, res: Response) => {
  const { to, amount, memo } = req.body;
  
  try {
    const result = await walletService.sendSol(to, amount, memo);
    
    if (result.success) {
      res.json({
        success: true,
        data: {
          signature: result.signature,
          amount,
          to,
          memo,
          timestamp: new Date().toISOString(),
        },
      });
    } else {
      res.status(400).json({
        success: false,
        message: result.error || 'Transaction failed',
      });
    }
  } catch (error) {
    logger.error('Failed to send SOL:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to process SOL transfer',
    });
  }
}));

/**
 * POST /wallet/send-token
 * Send SPL tokens to a recipient
 */
router.post('/send-token', validateRequest(sendTokenSchema), asyncHandler(async (req: Request, res: Response) => {
  const { to, tokenMint, amount, decimals, memo } = req.body;
  
  try {
    const result = await walletService.sendTokens(to, tokenMint, amount, decimals, memo);
    
    if (result.success) {
      res.json({
        success: true,
        data: {
          signature: result.signature,
          tokenMint,
          amount,
          decimals,
          to,
          memo,
          timestamp: new Date().toISOString(),
        },
      });
    } else {
      res.status(400).json({
        success: false,
        message: result.error || 'Transaction failed',
      });
    }
  } catch (error) {
    logger.error('Failed to send tokens:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to process token transfer',
    });
  }
}));

/**
 * POST /wallet/withdraw
 * Process a withdrawal request
 */
router.post('/withdraw', validateRequest(withdrawalSchema), asyncHandler(async (req: Request, res: Response) => {
  const { to, amount, tokenMint, memo } = req.body;
  
  try {
    const result = await walletService.processWithdrawal({
      to,
      amount,
      tokenMint,
      memo,
    });
    
    if (result.success) {
      res.json({
        success: true,
        data: {
          signature: result.signature,
          amount,
          tokenMint,
          to,
          memo,
          timestamp: new Date().toISOString(),
        },
      });
    } else {
      res.status(400).json({
        success: false,
        message: result.error || 'Withdrawal failed',
      });
    }
  } catch (error) {
    logger.error('Failed to process withdrawal:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to process withdrawal request',
    });
  }
}));

/**
 * POST /wallet/generate
 * Generate a new wallet keypair
 */
router.post('/generate', asyncHandler(async (req: Request, res: Response) => {
  try {
    const newWallet = walletService.generateNewWallet();
    
    res.json({
      success: true,
      data: {
        publicKey: newWallet.publicKey,
        privateKey: newWallet.privateKey,
        timestamp: new Date().toISOString(),
      },
    });
  } catch (error) {
    logger.error('Failed to generate wallet:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to generate new wallet',
    });
  }
}));

/**
 * GET /wallet/transaction/:signature
 * Get transaction details by signature
 */
router.get('/transaction/:signature', asyncHandler(async (req: Request, res: Response) => {
  const { signature } = req.params;
  
  // Validate signature format
  const { error } = transactionSignatureSchema.validate({ signature });
  if (error) {
    res.status(400).json({
      success: false,
      message: 'Invalid transaction signature format',
    });
    return;
  }
  
  try {
    const transaction = await walletService.getTransactionDetails(signature);
    
    if (!transaction) {
    res.status(404).json({
      success: false,
      message: 'Transaction not found',
    });
    return;
    }
    
    res.json({
      success: true,
      data: {
        signature,
        transaction,
        timestamp: new Date().toISOString(),
      },
    });
  } catch (error) {
    logger.error('Failed to get transaction details:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to retrieve transaction details',
    });
    return;
  }
}));

/**
 * POST /wallet/confirm-transaction
 * Confirm transaction signature and get detailed status
 */
router.post('/confirm-transaction', asyncHandler(async (req: Request, res: Response) => {
  const { signature } = req.body;
  
  // Validate signature format
  const { error } = transactionSignatureSchema.validate({ signature });
  if (error) {
    res.status(400).json({
      success: false,
      message: 'Invalid transaction signature format',
    });
    return;
  }
  
  try {
    const confirmation = await walletService.confirmTransaction(signature);
    
    res.json({
      success: true,
      data: {
        ...confirmation,
        timestamp: new Date().toISOString(),
      },
    });
  } catch (error) {
    logger.error('Failed to confirm transaction:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to confirm transaction',
    });
  }
}));

/**
 * POST /wallet/wait-confirmation
 * Wait for transaction confirmation with timeout
 */
router.post('/wait-confirmation', asyncHandler(async (req: Request, res: Response) => {
  const { signature, timeout } = req.body;
  
  // Validate signature format
  const { error } = transactionSignatureSchema.validate({ signature });
  if (error) {
    res.status(400).json({
      success: false,
      message: 'Invalid transaction signature format',
    });
    return;
  }
  
  // Validate timeout (optional)
  const timeoutMs = timeout && typeof timeout === 'number' ? timeout : undefined;
  
  try {
    const confirmation = await walletService.waitForConfirmation(signature, timeoutMs);
    
    res.json({
      success: true,
      data: {
        ...confirmation,
        timestamp: new Date().toISOString(),
      },
    });
  } catch (error) {
    logger.error('Failed to wait for confirmation:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to wait for transaction confirmation',
    });
  }
}));

/**
 * POST /wallet/check-incoming
 * Check if a transaction was sent TO the main wallet
 */
router.post('/check-incoming', asyncHandler(async (req: Request, res: Response) => {
  const { signature } = req.body;
  
  // Validate signature format
  const { error } = transactionSignatureSchema.validate({ signature });
  if (error) {
    res.status(400).json({
      success: false,
      message: 'Invalid transaction signature format',
    });
    return;
  }
  
  try {
    const result = await walletService.checkIncomingTransaction(signature);
    
    res.json({
      success: true,
      data: {
        ...result,
        timestamp: new Date().toISOString(),
      },
    });
  } catch (error) {
    logger.error('Failed to check incoming transaction:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to check incoming transaction',
    });
  }
}));

/**
 * GET /wallet/incoming-transactions
 * Get all incoming transactions for the main wallet
 */
router.get('/incoming-transactions', asyncHandler(async (req: Request, res: Response) => {
  const limit = parseInt(req.query.limit as string) || 10;
  
  // Validate limit
  if (limit < 1 || limit > 100) {
    res.status(400).json({
      success: false,
      message: 'Limit must be between 1 and 100',
    });
    return;
  }
  
  try {
    const result = await walletService.getIncomingTransactions(limit);
    
    res.json({
      success: true,
      data: {
        ...result,
        walletAddress: walletService.getMainWalletAddress(),
        timestamp: new Date().toISOString(),
      },
    });
  } catch (error) {
    logger.error('Failed to get incoming transactions:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to retrieve incoming transactions',
    });
  }
}));

/**
 * GET /wallet/info
 * Get main wallet information
 */
router.get('/info', asyncHandler(async (req: Request, res: Response) => {
  try {
    res.json({
      success: true,
      data: {
        walletAddress: walletService.getMainWalletAddress(),
        network: process.env.SOLANA_NETWORK || 'devnet',
        timestamp: new Date().toISOString(),
      },
    });
  } catch (error) {
    logger.error('Failed to get wallet info:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to retrieve wallet information',
    });
  }
}));

export default router;
