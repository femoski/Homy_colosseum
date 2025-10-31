import { Router, Request, Response } from 'express';
import { NFTService } from '../services/nftService';
import { validateRequest, asyncHandler } from '../middleware/validation';
import { mintNFTSchema, transferNFTSchema, nftMintSchema, ownerAddressSchema, verifyOwnershipQuerySchema } from '../validation/schemas';
import logger from '../utils/logger';

const router = Router();
const nftService = new NFTService();

/**
 * POST /nft/mint
 * Mint a new property NFT
 */
router.post('/mint', validateRequest(mintNFTSchema), asyncHandler(async (req: Request, res: Response) => {
  const { name, symbol, description, imageUri, properties, attributes, recipient } = req.body;
  
  try {
    const result = await nftService.mintNFT({
      name,
      symbol,
      description,
      imageUri,
      properties,
      attributes,
      recipient,
    });
    
    if (result.success) {
      res.json({
        success: true,
        data: {
          mint: result.mint,
          signature: result.signature,
          tokenAccount: result.tokenAccount,
          metadataAddress: result.metadataAddress,
          timestamp: new Date().toISOString(),
        },
      });
    } else {
      res.status(400).json({
        success: false,
        message: result.error || 'NFT minting failed',
      });
    }
  } catch (error) {
    logger.error('Failed to mint NFT:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to mint NFT',
    });
  }
}));

/**
 * POST /nft/transfer
 * Transfer an NFT to another address
 */
router.post('/transfer', validateRequest(transferNFTSchema), asyncHandler(async (req: Request, res: Response) => {
  const { mint, to } = req.body;
  
  try {
    const result = await nftService.transferNFT({ mint, to });
    
    if (result.success) {
      res.json({
        success: true,
        data: {
          signature: result.signature,
          mint,
          to,
          timestamp: new Date().toISOString(),
        },
      });
    } else {
      res.status(400).json({
        success: false,
        message: result.error || 'NFT transfer failed',
      });
    }
  } catch (error) {
    logger.error('Failed to transfer NFT:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to transfer NFT',
    });
  }
}));

/**
 * GET /nft/:mint
 * Get NFT metadata by mint address
 */
router.get('/:mint', asyncHandler(async (req: Request, res: Response) => {
  const { mint } = req.params;
  
  // Validate mint format
  const { error } = nftMintSchema.validate({ mint });
  if (error) {
    res.status(400).json({
      success: false,
      message: 'Invalid NFT mint address format',
    });
    return;
  }
  
  try {
    const nftInfo = await nftService.getNFTMetadata(mint);
    
    if (!nftInfo) {
      res.status(404).json({
        success: false,
        message: 'NFT not found',
      });
      return;
    }
    
    res.json({
      success: true,
      data: {
        ...nftInfo,
        timestamp: new Date().toISOString(),
      },
    });
  } catch (error) {
    logger.error('Failed to get NFT metadata:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to retrieve NFT metadata',
    });
  }
}));

/**
 * GET /nft/owner/:owner?
 * Get all NFTs owned by an address (defaults to main wallet)
 */
router.get('/owner/:owner?', asyncHandler(async (req: Request, res: Response) => {
  const { owner } = req.params;
  
  // Validate owner format if provided
  if (owner) {
    const { error } = ownerAddressSchema.validate({ owner });
    if (error) {
      res.status(400).json({
        success: false,
        message: 'Invalid owner address format',
      });
      return;
    }
  }
  
  try {
    const nfts = await nftService.getNFTsByOwner(owner);
    
    res.json({
      success: true,
      data: {
        owner: owner || nftService.getMainWalletAddress(),
        nfts,
        count: nfts.length,
        timestamp: new Date().toISOString(),
      },
    });
  } catch (error) {
    logger.error('Failed to get NFTs by owner:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to retrieve NFTs',
    });
  }
}));

/**
 * GET /nft/balance/:owner?
 * Get NFT balance (count) for an address
 */
router.get('/balance/:owner?', asyncHandler(async (req: Request, res: Response) => {
  const { owner } = req.params;
  
  // Validate owner format if provided
  if (owner) {
    const { error } = ownerAddressSchema.validate({ owner });
    if (error) {
      res.status(400).json({
        success: false,
        message: 'Invalid owner address format',
      });
      return;
    }
  }
  
  try {
    const balance = await nftService.getNFTBalance(owner);
    
    res.json({
      success: true,
      data: {
        owner: owner || nftService.getMainWalletAddress(),
        balance,
        timestamp: new Date().toISOString(),
      },
    });
  } catch (error) {
    logger.error('Failed to get NFT balance:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to retrieve NFT balance',
    });
  }
}));

/**
 * GET /nft/verify-ownership?mint=...&owner=...
 * Verify whether a wallet owns a given NFT mint
 */
router.get('/verify-ownership/address', asyncHandler(async (req: Request, res: Response) => {
  const { mint, owner } = req.query as { mint?: string; owner?: string };

  const { error } = verifyOwnershipQuerySchema.validate({ mint, owner });
  if (error) {
    res.status(400).json({
      success: false,
      message: 'Invalid query parameters',
    });
    return;
  }

  try {
    const result = await nftService.verifyOwnership(mint!, owner!);
    res.json({
      success: true,
      data: {
        mint,
        owner,
        isOwner: result.isOwner,
        amount: result.amount,
        tokenAccount: result.tokenAccount,
        timestamp: new Date().toISOString(),
      },
    });
  } catch (err) {
    logger.error('Failed to verify ownership:', err);
    res.status(500).json({
      success: false,
      message: 'Failed to verify ownership',
    });
  }
}));

export default router;

