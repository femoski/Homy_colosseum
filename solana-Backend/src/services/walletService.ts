import {
  Connection,
  PublicKey,
  Keypair,
  Transaction,
  SystemProgram,
  LAMPORTS_PER_SOL,
  sendAndConfirmTransaction,
  TransactionInstruction,
  AccountInfo,
} from '@solana/web3.js';
import {
  getAssociatedTokenAddress,
  createTransferInstruction,
  getAccount,
  TokenAccountNotFoundError,
  TokenInvalidAccountOwnerError,
} from '@solana/spl-token';
import config from '../config';
import logger from '../utils/logger';

export interface WalletBalance {
  sol: number;
  tokens: TokenBalance[];
}

export interface TokenBalance {
  mint: string;
  amount: number;
  decimals: number;
  symbol?: string;
}

export interface TransactionResult {
  signature: string;
  success: boolean;
  error?: string;
}

export interface WithdrawalRequest {
  to: string;
  amount: number;
  tokenMint?: string;
  memo?: string;
}

export class SolanaWalletService {
  private connection: Connection;
  private mainWallet: Keypair;

  constructor() {
    this.connection = new Connection(config.solana.rpcUrl, 'confirmed');
    this.mainWallet = this.loadMainWallet();
  }

  private loadMainWallet(): Keypair {
    try {
      const privateKeyArray = JSON.parse(config.wallet.privateKey);
      return Keypair.fromSecretKey(new Uint8Array(privateKeyArray));
    } catch (error) {
      logger.error('Failed to load main wallet:', error);
      throw new Error('Invalid wallet private key format');
    }
  }

  /**
   * Get the main wallet's SOL balance
   */
  async getSolBalance(): Promise<number> {
    try {
      const balance = await this.connection.getBalance(this.mainWallet.publicKey);
      return balance / LAMPORTS_PER_SOL;
    } catch (error) {
      logger.error('Failed to get SOL balance:', error);
      throw new Error('Failed to retrieve wallet balance');
    }
  }

  /**
   * Get token balances for the main wallet
   */
  async getTokenBalances(): Promise<TokenBalance[]> {
    try {
      const tokenAccounts = await this.connection.getParsedTokenAccountsByOwner(
        this.mainWallet.publicKey,
        {
          programId: new PublicKey('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA'),
        }
      );

      const balances: TokenBalance[] = [];

      for (const account of tokenAccounts.value) {
        const accountInfo = account.account.data.parsed.info;
        balances.push({
          mint: accountInfo.mint,
          amount: accountInfo.tokenAmount.uiAmount || 0,
          decimals: accountInfo.tokenAmount.decimals,
        });
      }

      return balances;
    } catch (error) {
      logger.error('Failed to get token balances:', error);
      throw new Error('Failed to retrieve token balances');
    }
  }

  /**
   * Get complete wallet balance (SOL + tokens)
   */
  async getWalletBalance(): Promise<WalletBalance> {
    try {
      const [solBalance, tokenBalances] = await Promise.all([
        this.getSolBalance(),
        this.getTokenBalances(),
      ]);

      return {
        sol: solBalance,
        tokens: tokenBalances,
      };
    } catch (error) {
      logger.error('Failed to get wallet balance:', error);
      throw new Error('Failed to retrieve wallet balance');
    }
  }

  /**
   * Send SOL to a recipient address
   */
  async sendSol(to: string, amount: number, memo?: string): Promise<TransactionResult> {
    try {
      const recipient = new PublicKey(to);
      const lamports = Math.floor(amount * LAMPORTS_PER_SOL);

      // Check if we have enough balance
      const currentBalance = await this.getSolBalance();
      if (currentBalance < amount + config.transaction.minimumBalanceThreshold) {
        throw new Error('Insufficient SOL balance');
      }

      const transaction = new Transaction();

      // Add transfer instruction
      transaction.add(
        SystemProgram.transfer({
          fromPubkey: this.mainWallet.publicKey,
          toPubkey: recipient,
          lamports,
        })
      );

      // Add memo if provided
      if (memo) {
        transaction.add(
          new TransactionInstruction({
            keys: [],
            programId: new PublicKey('MemoSq4gqABAXKb96qnH8TysKcWfC85B2q2'),
            data: Buffer.from(memo, 'utf8'),
          })
        );
      }

      // Send and confirm transaction
      const signature = await sendAndConfirmTransaction(
        this.connection,
        transaction,
        [this.mainWallet],
        {
          commitment: 'confirmed',
          preflightCommitment: 'confirmed',
        }
      );

      logger.info(`SOL transfer successful: ${signature}`);
      return {
        signature,
        success: true,
      };
    } catch (error) {
      logger.error('Failed to send SOL:', error);
      return {
        signature: '',
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error',
      };
    }
  }

  /**
   * Send SPL tokens to a recipient address
   */
  async sendTokens(
    to: string,
    tokenMint: string,
    amount: number,
    decimals: number,
    memo?: string
  ): Promise<TransactionResult> {
    try {
      const recipient = new PublicKey(to);
      const mint = new PublicKey(tokenMint);

      // Get associated token addresses
      const sourceTokenAccount = await getAssociatedTokenAddress(
        mint,
        this.mainWallet.publicKey
      );
      const destinationTokenAccount = await getAssociatedTokenAddress(mint, recipient);

      // Check if source token account exists and has sufficient balance
      try {
        const sourceAccountInfo = await getAccount(this.connection, sourceTokenAccount);
        const currentBalance = Number(sourceAccountInfo.amount);
        const transferAmount = Math.floor(amount * Math.pow(10, decimals));

        if (currentBalance < transferAmount) {
          throw new Error('Insufficient token balance');
        }
      } catch (error) {
        if (error instanceof TokenAccountNotFoundError) {
          throw new Error('Token account not found');
        }
        throw error;
      }

      const transaction = new Transaction();

      // Add token transfer instruction
      transaction.add(
        createTransferInstruction(
          sourceTokenAccount,
          destinationTokenAccount,
          this.mainWallet.publicKey,
          Math.floor(amount * Math.pow(10, decimals))
        )
      );

      // Add memo if provided
      if (memo) {
        transaction.add(
          new TransactionInstruction({
            keys: [],
            programId: new PublicKey('MemoSq4gqABAXKb96qnH8TysKcWfC85B2q2'),
            data: Buffer.from(memo, 'utf8'),
          })
        );
      }

      // Send and confirm transaction
      const signature = await sendAndConfirmTransaction(
        this.connection,
        transaction,
        [this.mainWallet],
        {
          commitment: 'confirmed',
          preflightCommitment: 'confirmed',
        }
      );

      logger.info(`Token transfer successful: ${signature}`);
      return {
        signature,
        success: true,
      };
    } catch (error) {
      logger.error('Failed to send tokens:', error);
      return {
        signature: '',
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error',
      };
    }
  }

  /**
   * Process a withdrawal request
   */
  async processWithdrawal(request: WithdrawalRequest): Promise<TransactionResult> {
    try {
      logger.info(`Processing withdrawal request:`, request);

      // Validate recipient address
      try {
        new PublicKey(request.to);
      } catch {
        throw new Error('Invalid recipient address');
      }

      // Validate amount
      if (request.amount <= 0) {
        throw new Error('Amount must be greater than 0');
      }

      let result: TransactionResult;

      if (request.tokenMint) {
        // Token withdrawal
        const tokenBalances = await this.getTokenBalances();
        const tokenBalance = tokenBalances.find(t => t.mint === request.tokenMint);
        
        if (!tokenBalance) {
          throw new Error('Token not found in wallet');
        }

        result = await this.sendTokens(
          request.to,
          request.tokenMint,
          request.amount,
          tokenBalance.decimals,
          request.memo
        );
      } else {
        // SOL withdrawal
        result = await this.sendSol(request.to, request.amount, request.memo);
      }

      if (result.success) {
        logger.info(`Withdrawal successful: ${result.signature}`);
      } else {
        logger.error(`Withdrawal failed: ${result.error}`);
      }

      return result;
    } catch (error) {
      logger.error('Failed to process withdrawal:', error);
      return {
        signature: '',
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error',
      };
    }
  }

  /**
   * Generate a new wallet keypair
   */
  generateNewWallet(): { publicKey: string; privateKey: number[] } {
    const keypair = Keypair.generate();
    return {
      publicKey: keypair.publicKey.toString(),
      privateKey: Array.from(keypair.secretKey),
    };
  }

  /**
   * Get transaction details by signature
   */
  async getTransactionDetails(signature: string): Promise<any> {
    try {
      const transaction = await this.connection.getTransaction(signature, {
        commitment: 'confirmed',
      });
      return transaction;
    } catch (error) {
      logger.error('Failed to get transaction details:', error);
      throw new Error('Failed to retrieve transaction details');
    }
  }

  /**
   * Confirm transaction signature and get detailed status
   */
  async confirmTransaction(signature: string): Promise<{
    signature: string;
    confirmed: boolean;
    status: 'pending' | 'confirmed' | 'finalized' | 'failed' | 'not_found';
    confirmationTime?: number;
    amount?: number;
    tokenMint?: string;
    fromAddress?: string;
    toAddress?: string;
    error?: string;
    transaction?: any;
  }> {
    try {
      logger.info(`Confirming transaction: ${signature}`);

      // First check if transaction exists
      const transaction = await this.connection.getTransaction(signature, {
        commitment: 'confirmed',
      });

      if (!transaction) {
        return {
          signature,
          confirmed: false,
          status: 'not_found',
          error: 'Transaction not found',
        };
      }

      // Check transaction status
      const status = transaction.meta?.err ? 'failed' : 'confirmed';
      
      // Get confirmation time
      const confirmationTime = transaction.blockTime ? transaction.blockTime * 1000 : undefined;

      // Extract transaction amount and addresses
      let amount = 0;
      let tokenMint: string | undefined;
      let fromAddress: string | undefined;
      let toAddress: string | undefined;

      const transactionData = transaction.transaction;
      
      // Simple approach: calculate amount from balance changes
      if (transaction.meta?.preBalances && transaction.meta?.postBalances && transactionData?.message?.accountKeys) {
        const accountKeys = transactionData.message.accountKeys;
        
        // Find the largest balance change (excluding fees)
        for (let i = 0; i < accountKeys.length; i++) {
          const preBalance = transaction.meta.preBalances[i];
          const postBalance = transaction.meta.postBalances[i];
          const change = postBalance - preBalance;
          
          // If this is a significant positive change (incoming), it's likely a transfer
          if (change > 1000000) { // More than 0.001 SOL
            amount = change / LAMPORTS_PER_SOL;
            toAddress = accountKeys[i]?.toString();
            
            // Find the corresponding sender (largest negative change)
            for (let j = 0; j < accountKeys.length; j++) {
              const senderPreBalance = transaction.meta.preBalances[j];
              const senderPostBalance = transaction.meta.postBalances[j];
              const senderChange = senderPostBalance - senderPreBalance;
              
              if (Math.abs(senderChange + change) < 1000) { // Account for small fee differences
                fromAddress = accountKeys[j]?.toString();
                break;
              }
            }
            
            logger.info(`Transfer detected: ${amount} SOL from ${fromAddress} to ${toAddress}`);
            break;
          }
        }
      }
      
      // Also check for SPL token transfers
      if (transactionData?.message?.instructions && transactionData.message.accountKeys) {
        for (const instruction of transactionData.message.instructions) {
          try {
            
            // Check for SPL token transfers
            const programId = transactionData.message.accountKeys[instruction.programIdIndex];
            if (programId && programId.toString() === 'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA') {
              const accounts = instruction.accounts;
              if (accounts && accounts.length >= 3) {
                const sourceIndex = accounts[0];
                const destinationIndex = accounts[1];
                
                // Get actual account addresses from account keys
                const sourceAddr = transactionData.message.accountKeys[sourceIndex]?.toString();
                const destAddr = transactionData.message.accountKeys[destinationIndex]?.toString();
                
                fromAddress = sourceAddr || 'Unknown';
                toAddress = destAddr || 'Unknown';
                
                // Get token amount from token balance changes
                if (transaction.meta?.preTokenBalances && transaction.meta?.postTokenBalances) {
                  const preBalance = transaction.meta.preTokenBalances.find(
                    (balance: any) => balance.accountIndex === sourceIndex
                  );
                  const postBalance = transaction.meta.postTokenBalances.find(
                    (balance: any) => balance.accountIndex === sourceIndex
                  );
                  
                  if (preBalance && postBalance) {
                    const decimals = preBalance.uiTokenAmount.decimals;
                    const preAmount = preBalance.uiTokenAmount.uiAmount || 0;
                    const postAmount = postBalance.uiTokenAmount.uiAmount || 0;
                    amount = Math.abs(preAmount - postAmount);
                    tokenMint = preBalance.mint;
                  }
                }
              }
            }
          } catch (instructionError) {
            logger.warn('Error processing instruction for amount:', instructionError);
            continue;
          }
        }
      }

      // Additional confirmation by checking signature status
      const signatureStatus = await this.connection.getSignatureStatus(signature, {
        searchTransactionHistory: true,
      });

      const isConfirmed = signatureStatus.value?.confirmationStatus === 'confirmed' || 
                         signatureStatus.value?.confirmationStatus === 'finalized';

      logger.info(`Transaction ${signature} status: ${status}, confirmed: ${isConfirmed}, amount: ${amount}, fromAddress: ${fromAddress}, toAddress: ${toAddress}`);

      return {
        signature,
        confirmed: isConfirmed && status !== 'failed',
        status: isConfirmed ? (status === 'failed' ? 'failed' : 'confirmed') : 'pending',
        confirmationTime,
        amount: amount,
        tokenMint: tokenMint || undefined,
        fromAddress: fromAddress || undefined,
        toAddress: toAddress || undefined,
        transaction: {
          slot: transaction.slot,
          blockTime: transaction.blockTime,
          fee: transaction.meta?.fee,
          status: status,
          instructions: transaction.transaction?.message?.instructions?.length || 0,
        },
      };
    } catch (error) {
      logger.error('Failed to confirm transaction:', error);
      return {
        signature,
        confirmed: false,
        status: 'failed',
        error: error instanceof Error ? error.message : 'Unknown error',
      };
    }
  }

  /**
   * Wait for transaction confirmation with timeout
   */
  async waitForConfirmation(
    signature: string, 
    timeout: number = config.transaction.confirmationTimeout
  ): Promise<{
    signature: string;
    confirmed: boolean;
    status: string;
    confirmationTime?: number;
    error?: string;
  }> {
    const startTime = Date.now();
    
    while (Date.now() - startTime < timeout) {
      try {
        const result = await this.confirmTransaction(signature);
        
        if (result.confirmed || result.status === 'failed') {
          return result;
        }
        
        // Wait 2 seconds before checking again
        await new Promise(resolve => setTimeout(resolve, 2000));
      } catch (error) {
        logger.error(`Error checking confirmation for ${signature}:`, error);
        await new Promise(resolve => setTimeout(resolve, 2000));
      }
    }
    
    return {
      signature,
      confirmed: false,
      status: 'timeout',
      error: 'Confirmation timeout exceeded',
    };
  }

  /**
   * Check if a transaction was sent TO the main wallet
   */
  async checkIncomingTransaction(signature: string): Promise<{
    signature: string;
    isIncoming: boolean;
    confirmed: boolean;
    status: 'pending' | 'confirmed' | 'finalized' | 'failed' | 'not_found';
    amount?: number;
    tokenMint?: string;
    fromAddress?: string;
    confirmationTime?: number;
    error?: string;
    transaction?: any;
  }> {
    try {
      logger.info(`Checking incoming transaction: ${signature}`);

      // Get transaction details
      const transaction = await this.connection.getTransaction(signature, {
        commitment: 'confirmed',
      });

      if (!transaction) {
        return {
          signature,
          isIncoming: false,
          confirmed: false,
          status: 'not_found',
          error: 'Transaction not found',
        };
      }

      const mainWalletAddress = this.mainWallet.publicKey.toString();
      let isIncoming = false;
      let amount = 0;
      let tokenMint: string | undefined;
      let fromAddress: string | undefined;

      // Check if transaction involves our main wallet
      const transactionData = transaction.transaction;
      if (transactionData?.message?.instructions && transactionData.message.accountKeys) {
        for (const instruction of transactionData.message.instructions) {
          try {
            // Check for SOL transfers
            const programId = transactionData.message.accountKeys[instruction.programIdIndex];
            if (programId && programId.toString() === '11111111111111111111111111111111') { // System Program
              const accounts = instruction.accounts;
              if (accounts && accounts.length >= 2) {
                const fromIndex = accounts[0];
                const toIndex = accounts[1];
                
                // Get actual account addresses from account keys
                const fromAddr = transactionData.message.accountKeys[fromIndex]?.toString();
                const toAddr = transactionData.message.accountKeys[toIndex]?.toString();
                
                if (toAddr === mainWalletAddress) {
                  isIncoming = true;
                  fromAddress = fromAddr || 'Unknown';
                  
                  // Get SOL amount from pre/post balances
                  if (transaction.meta?.preBalances && transaction.meta?.postBalances) {
                    const accountIndex = transactionData.message.accountKeys.findIndex(
                      (key: any) => key?.toString() === mainWalletAddress
                    );
                    if (accountIndex >= 0) {
                      const preBalance = transaction.meta.preBalances[accountIndex];
                      const postBalance = transaction.meta.postBalances[accountIndex];
                      amount = (postBalance - preBalance) / LAMPORTS_PER_SOL;
                    }
                  }
                }
              }
            }
          } catch (instructionError) {
            logger.warn('Error processing instruction:', instructionError);
            continue;
          }
          
          try {
            // Check for SPL token transfers
            const programId = transactionData.message.accountKeys[instruction.programIdIndex];
            if (programId && programId.toString() === 'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA') {
            const accounts = instruction.accounts;
            if (accounts && accounts.length >= 3) {
              const source = accounts[0];
              const destination = accounts[1];
              
              // Get token account info to check if destination belongs to our wallet
              try {
                const destinationPublicKey = transactionData.message.accountKeys[destination];
                const destinationAccount = await this.connection.getAccountInfo(destinationPublicKey);
                if (destinationAccount?.owner.toString() === mainWalletAddress) {
                  isIncoming = true;
                  
                  // Get token mint from account data
                  const accountData = destinationAccount.data;
                  if (accountData.length >= 64) {
                    const mintBytes = accountData.slice(0, 32);
                    tokenMint = new PublicKey(mintBytes).toString();
                  }
                  
                  // Get amount from token balance changes
                  if (transaction.meta?.preTokenBalances && transaction.meta?.postTokenBalances) {
                    const preBalance = transaction.meta.preTokenBalances.find(
                      (balance: any) => balance.accountIndex === accounts.indexOf(destination)
                    );
                    const postBalance = transaction.meta.postTokenBalances.find(
                      (balance: any) => balance.accountIndex === accounts.indexOf(destination)
                    );
                    
                    if (preBalance && postBalance) {
                      const decimals = preBalance.uiTokenAmount.decimals;
                      amount = (postBalance.uiTokenAmount.uiAmount || 0) - (preBalance.uiTokenAmount.uiAmount || 0);
                    }
                  }
                  
                  // Get source account owner as from address
                  try {
                    const sourcePublicKey = transactionData.message.accountKeys[source];
                    const sourceAccount = await this.connection.getAccountInfo(sourcePublicKey);
                    if (sourceAccount?.owner) {
                      fromAddress = sourceAccount.owner.toString();
                    }
                  } catch (error) {
                    logger.warn('Could not get source account owner:', error);
                  }
                }
              } catch (error) {
                logger.warn('Could not get destination account info:', error);
              }
            }
          }
          } catch (tokenError) {
            logger.warn('Error processing token instruction:', tokenError);
            continue;
          }
        }
      }

      // Check transaction status
      const status = transaction.meta?.err ? 'failed' : 'confirmed';
      const confirmationTime = transaction.blockTime ? transaction.blockTime * 1000 : undefined;

      // Additional confirmation by checking signature status
      const signatureStatus = await this.connection.getSignatureStatus(signature, {
        searchTransactionHistory: true,
      });

      const isConfirmed = signatureStatus.value?.confirmationStatus === 'confirmed' || 
                         signatureStatus.value?.confirmationStatus === 'finalized';

      logger.info(`Transaction ${signature} incoming check: ${isIncoming}, confirmed: ${isConfirmed}, amount: ${amount}`);

      return {
        signature,
        isIncoming,
        confirmed: isConfirmed && status !== 'failed',
        status: isConfirmed ? (status === 'failed' ? 'failed' : 'confirmed') : 'pending',
        amount: isIncoming ? amount : undefined,
        tokenMint: isIncoming ? tokenMint : undefined,
        fromAddress: isIncoming ? fromAddress : undefined,
        confirmationTime,
        transaction: {
          slot: transaction.slot,
          blockTime: transaction.blockTime,
          fee: transaction.meta?.fee,
          status: status,
          instructions: transaction.transaction?.message?.instructions?.length || 0,
        },
      };
    } catch (error) {
      logger.error('Failed to check incoming transaction:', error);
      return {
        signature,
        isIncoming: false,
        confirmed: false,
        status: 'failed',
        error: error instanceof Error ? error.message : 'Unknown error',
      };
    }
  }

  /**
   * Get all incoming transactions for the main wallet
   */
  async getIncomingTransactions(limit: number = 10): Promise<{
    transactions: Array<{
      signature: string;
      amount: number;
      tokenMint?: string;
      fromAddress: string;
      confirmationTime: number;
      status: string;
    }>;
    total: number;
  }> {
    try {
      const signatures = await this.connection.getSignaturesForAddress(
        this.mainWallet.publicKey,
        { limit }
      );

      const transactions = [];
      
      for (const sigInfo of signatures) {
        const result = await this.checkIncomingTransaction(sigInfo.signature);
        if (result.isIncoming && result.confirmed) {
          transactions.push({
            signature: result.signature,
            amount: result.amount || 0,
            tokenMint: result.tokenMint,
            fromAddress: result.fromAddress || 'Unknown',
            confirmationTime: result.confirmationTime || 0,
            status: result.status,
          });
        }
      }

      return {
        transactions,
        total: transactions.length,
      };
    } catch (error) {
      logger.error('Failed to get incoming transactions:', error);
      throw new Error('Failed to retrieve incoming transactions');
    }
  }

  /**
   * Get the main wallet's public key
   */
  getMainWalletAddress(): string {
    return this.mainWallet.publicKey.toString();
  }
}
