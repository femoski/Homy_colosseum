import {
  Connection,
  PublicKey,
  Keypair,
  Transaction,
  SystemProgram,
  sendAndConfirmTransaction,
} from '@solana/web3.js';
import {
  createTransferInstruction,
  getAccount,
  getMint,
  createAssociatedTokenAccountInstruction,
  getAssociatedTokenAddressSync,
  TOKEN_PROGRAM_ID,
  createMintToInstruction,
  createInitializeMintInstruction,
  MINT_SIZE,
  getMinimumBalanceForRentExemptMint,
} from '@solana/spl-token';
import config from '../config';
import logger from '../utils/logger';
// Metaplex Token Metadata (static import for ESM/CJS interop reliability)
// If the package isn't installed, the build will fail; ensure it's in dependencies
// eslint-disable-next-line @typescript-eslint/ban-ts-comment
// @ts-ignore
import * as metadataLib from '@metaplex-foundation/mpl-token-metadata';

// Metaplex Token Metadata Program IDs
const METADATA_PROGRAM_ID = new PublicKey('metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s');
const TOKEN_METADATA_PROGRAM_ID = METADATA_PROGRAM_ID;

export interface NFTMetadata {
  name: string;
  symbol: string;
  description: string;
  image?: string;
  properties?: {
    propertyAddress?: string;
    propertyType?: string;
    squareFeet?: number;
    bedrooms?: number;
    bathrooms?: number;
    yearBuilt?: number;
    location?: {
      city?: string;
      state?: string;
      country?: string;
      zipCode?: string;
    };
    [key: string]: any;
  };
  attributes?: Array<{
    trait_type: string;
    value: string | number;
  }>;
}

export interface MintNFTRequest {
  name: string;
  symbol: string;
  description: string;
  imageUri?: string;
  properties?: NFTMetadata['properties'];
  attributes?: NFTMetadata['attributes'];
  recipient?: string; // Optional: mint to specific address, defaults to main wallet
}

export interface TransferNFTRequest {
  mint: string;
  to: string;
}

export interface NFTInfo {
  mint: string;
  owner: string;
  name?: string;
  symbol?: string;
  uri?: string;
  image?: string;
  metadata?: NFTMetadata;
  supply: number;
  decimals: number;
  metadataAddress?: string;
}

export class NFTService {
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
   * Remove padding and non-printable nulls from fixed-length strings
   */
  private sanitizePaddedString(value?: string): string | undefined {
    if (typeof value !== 'string') return undefined;
    const cleaned = value.replace(/\u0000/g, '').replace(/\x00/g, '').replace(/\0/g, '').trim();
    return cleaned.length ? cleaned : undefined;
  }

  /**
   * Convert ipfs:// URIs to an HTTP gateway URL for client compatibility
   */
  private toHttpGateway(uri: string): string {
    if (!uri) return uri;
    if (uri.startsWith('ipfs://')) {
      const gateway = (config.storage?.gatewayUrl || 'https://ipfs.io').replace(/\/$/, '');
      return `${gateway}/ipfs/${uri.replace('ipfs://', '')}`;
    }
    return uri;
  }

  /**
   * Derive metadata PDA (Program Derived Address) for a mint
   */
  private async getMetadataPDA(mint: PublicKey): Promise<PublicKey> {
    const [metadataPDA] = PublicKey.findProgramAddressSync(
      [
        Buffer.from('metadata'),
        METADATA_PROGRAM_ID.toBuffer(),
        mint.toBuffer(),
      ],
      METADATA_PROGRAM_ID
    );
    return metadataPDA;
  }

  /**
   * Derive master edition PDA
   */
  private async getMasterEditionPDA(mint: PublicKey): Promise<PublicKey> {
    const [masterEditionPDA] = PublicKey.findProgramAddressSync(
      [
        Buffer.from('metadata'),
        METADATA_PROGRAM_ID.toBuffer(),
        mint.toBuffer(),
        Buffer.from('edition'),
      ],
      METADATA_PROGRAM_ID
    );
    return masterEditionPDA;
  }

  /**
   * Upload metadata to IPFS/Arweave using configured provider
   */
  private async uploadMetadata(metadata: NFTMetadata): Promise<string> {
    try {
      const provider = config.storage?.provider || 'none';
      const gateway = config.storage?.gatewayUrl || 'https://ipfs.io';
      const metadataJson = JSON.stringify(metadata);

      if (provider === 'pinata') {
        if (!config.storage?.pinataApiKey || !config.storage?.pinataSecretApiKey) {
          throw new Error('Pinata API credentials not configured');
        }

        const response = await fetch('https://api.pinata.cloud/pinning/pinJSONToIPFS', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'pinata_api_key': config.storage.pinataApiKey,
            'pinata_secret_api_key': config.storage.pinataSecretApiKey,
          } as any,
          body: JSON.stringify({ pinataContent: JSON.parse(metadataJson) }),
        });

        if (!response.ok) {
          const text = await response.text();
          throw new Error(`Pinata upload failed: ${response.status} ${text}`);
        }
        const result: any = await response.json();
        const cid = (result && result.IpfsHash) as string;

        console.log('Pinata upload successful:', result);
        return `ipfs://${cid}`;
      }

      if (provider === 'nft_storage') {
        if (!config.storage?.nftStorageToken) {
          throw new Error('NFT.Storage token not configured');
        }

        const response = await fetch('https://api.nft.storage/upload', {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${config.storage.nftStorageToken}`,
            'Content-Type': 'application/json',
          },
          body: metadataJson,
        });

        if (!response.ok) {
          const text = await response.text();
          throw new Error(`NFT.Storage upload failed: ${response.status} ${text}`);
        }
        const result: any = await response.json();
        const cid = result && result.value && result.value.cid as string;
        if (!cid) throw new Error('Invalid response from NFT.Storage');
        return `ipfs://${cid}`;
      }

      // Fallback: data URI (not recommended for production)
      const base64 = Buffer.from(metadataJson).toString('base64');
      return `data:application/json;base64,${base64}`;
    } catch (error) {
      logger.error('uploadMetadata failed, falling back to data URI:', error);
      const metadataJson = JSON.stringify(metadata);
      const base64 = Buffer.from(metadataJson).toString('base64');
      return `data:application/json;base64,${base64}`;
    }
  }

  /**
   * Mint a new property NFT
   */
  async mintNFT(request: MintNFTRequest): Promise<{
    mint: string;
    signature: string;
    tokenAccount: string;
    metadataAddress: string;
    success: boolean;
    error?: string;
  }> {
    try {
      logger.info('Minting NFT:', request);

      // Create mint keypair
      const mintKeypair = Keypair.generate();
      const mint = mintKeypair.publicKey;

      // Determine recipient
      const recipient = request.recipient 
        ? new PublicKey(request.recipient)
        : this.mainWallet.publicKey;

      // Get associated token account address
      const associatedTokenAccount = getAssociatedTokenAddressSync(
        mint,
        recipient
      );

      // Prepare metadata
      const metadata: NFTMetadata = {
        name: request.name,
        symbol: request.symbol,
        description: request.description,
        image: request.imageUri,
        properties: request.properties || {},
        attributes: request.attributes || [],
      };

      // Upload metadata to storage (IPFS/Arweave)
      const metadataUriRaw = await this.uploadMetadata(metadata);
      // Prefer HTTP gateway URIs for wallet compatibility
      const metadataUri = metadataUriRaw.startsWith('ipfs://')
        ? `${(config.storage?.gatewayUrl || 'https://ipfs.io').replace(/\/$/, '')}/ipfs/${metadataUriRaw.replace('ipfs://', '')}`
        : metadataUriRaw;

        if (!metadataUri || metadataUri.length > 200) {
          throw new Error('Metadata URI exceeds 200 bytes. Use an IPFS/Arweave provider to store short ipfs:// URIs.');
        }
      // Get metadata PDA
      const metadataPDA = await this.getMetadataPDA(mint);

      // Get minimum balance for rent-exempt mint
      const mintRent = await getMinimumBalanceForRentExemptMint(this.connection);

      // Create transaction
      const transaction = new Transaction();

      // 1. Create mint account
      transaction.add(
        SystemProgram.createAccount({
          fromPubkey: this.mainWallet.publicKey,
          newAccountPubkey: mint,
          space: MINT_SIZE,
          lamports: mintRent,
          programId: TOKEN_PROGRAM_ID,
        })
      );

      // 2. Initialize mint (decimals = 0 for NFTs)
      transaction.add(
        createInitializeMintInstruction(
          mint,
          0, // decimals (0 for NFTs)
          this.mainWallet.publicKey, // mint authority
          this.mainWallet.publicKey // freeze authority must be set for Metaplex
        )
      );

      // 3. Create associated token account if it doesn't exist
      let ataExists = false;
      try {
        await getAccount(this.connection, associatedTokenAccount);
        ataExists = true;
      } catch {
        // Account doesn't exist, will create it
      }

      if (!ataExists) {
        transaction.add(
          createAssociatedTokenAccountInstruction(
            this.mainWallet.publicKey,
            associatedTokenAccount,
            recipient,
            mint
          )
        );
      }

      // 4. Mint 1 token to the associated token account
      transaction.add(
        createMintToInstruction(
          mint,
          associatedTokenAccount,
          this.mainWallet.publicKey,
          1, // amount (1 for NFT)
          []
        )
      );

      // 5. Create Metadata and Master Edition (if mpl-token-metadata is available)
      try {
        try {
          logger.info('mpl-token-metadata exports', { keys: Object.keys((metadataLib as any) || {}) });
        } catch {}

        const metadataPDA = await this.getMetadataPDA(mint);
        const masterEditionPDA = await this.getMasterEditionPDA(mint);

        // Helper: search function across module namespaces
        const findFn = (root: any, predicate: (name: string, value: any) => boolean): any => {
          const visited = new Set<any>();
          const stack: Array<{ name: string; value: any }> = [{ name: 'root', value: root }];
          while (stack.length) {
            const { name, value } = stack.pop()!;
            if (!value || typeof value !== 'object') continue;
            if (visited.has(value)) continue;
            visited.add(value);
            for (const k of Object.keys(value)) {
              const v = value[k];
              if (predicate(k, v)) return v;
              if (v && typeof v === 'object') stack.push({ name: `${name}.${k}`, value: v });
            }
          }
          return undefined;
        };

        let createMetaFn =
          (metadataLib as any).createCreateMetadataAccountV3Instruction ||
          ((metadataLib as any).instructions && (metadataLib as any).instructions.createCreateMetadataAccountV3Instruction) ||
          (metadataLib as any).createCreateMetadataAccountV2Instruction ||
          ((metadataLib as any).instructions && (metadataLib as any).instructions.createCreateMetadataAccountV2Instruction) ||
          (metadataLib as any).createCreateMetadataAccountInstruction ||
          ((metadataLib as any).instructions && (metadataLib as any).instructions.createCreateMetadataAccountInstruction);

        if (typeof createMetaFn !== 'function') {
          createMetaFn = findFn((metadataLib as any), (n, v) => typeof v === 'function' && (n.includes('createCreateMetadataAccount') || n.includes('CreateMetadataAccount')));
        }

        if (typeof createMetaFn !== 'function') {
          throw new Error('No compatible createMetadata instruction found in mpl-token-metadata');
        }

        // Build args for different versions
        let metadataIx;
        const creatorsField = [
          {
            address: this.mainWallet.publicKey,
            verified: true,
            share: 100,
          },
        ];

        if (((metadataLib as any).createCreateMetadataAccountV3Instruction && createMetaFn === (metadataLib as any).createCreateMetadataAccountV3Instruction) || (createMetaFn && createMetaFn.name && createMetaFn.name.includes('CreateMetadataAccountV3'))) {
          metadataIx = createMetaFn(
            {
              metadata: metadataPDA,
              mint,
              mintAuthority: this.mainWallet.publicKey,
              payer: this.mainWallet.publicKey,
              updateAuthority: this.mainWallet.publicKey,
              systemProgram: SystemProgram.programId,
            },
            {
              createMetadataAccountArgsV3: {
                data: {
                  name: metadata.name,
                  symbol: metadata.symbol,
                  uri: metadataUri,
                  sellerFeeBasisPoints: 0,
                  creators: creatorsField,
                  collection: null,
                  uses: null,
                },
                isMutable: true,
                collectionDetails: null,
              },
            }
          );
        } else if (((metadataLib as any).createCreateMetadataAccountV2Instruction && createMetaFn === (metadataLib as any).createCreateMetadataAccountV2Instruction) || (createMetaFn && createMetaFn.name && createMetaFn.name.includes('CreateMetadataAccountV2'))) {
          metadataIx = createMetaFn(
            {
              metadata: metadataPDA,
              mint,
              mintAuthority: this.mainWallet.publicKey,
              payer: this.mainWallet.publicKey,
              updateAuthority: this.mainWallet.publicKey,
              systemProgram: SystemProgram.programId,
            },
            {
              createMetadataAccountArgsV2: {
                data: {
                  name: metadata.name,
                  symbol: metadata.symbol,
                  uri: metadataUri,
                  sellerFeeBasisPoints: 0,
                  creators: creatorsField,
                  collection: null,
                  uses: null,
                },
                isMutable: true,
              },
            }
          );
        } else {
          // Legacy variant
          metadataIx = createMetaFn(
            {
              metadata: metadataPDA,
              mint,
              mintAuthority: this.mainWallet.publicKey,
              payer: this.mainWallet.publicKey,
              updateAuthority: this.mainWallet.publicKey,
              systemProgram: SystemProgram.programId,
            },
            {
              createMetadataAccountArgs: {
                data: {
                  name: metadata.name,
                  symbol: metadata.symbol,
                  uri: metadataUri,
                  sellerFeeBasisPoints: 0,
                  creators: creatorsField,
                  collection: null,
                  uses: null,
                },
                isMutable: true,
              },
            }
          );
        }
        transaction.add(metadataIx);

        let createMasterFn =
          (metadataLib as any).createCreateMasterEditionV3Instruction ||
          ((metadataLib as any).instructions && (metadataLib as any).instructions.createCreateMasterEditionV3Instruction) ||
          (metadataLib as any).createCreateMasterEditionV2Instruction ||
          ((metadataLib as any).instructions && (metadataLib as any).instructions.createCreateMasterEditionV2Instruction) ||
          (metadataLib as any).createCreateMasterEditionInstruction ||
          ((metadataLib as any).instructions && (metadataLib as any).instructions.createCreateMasterEditionInstruction);

        if (typeof createMasterFn !== 'function') {
          createMasterFn = findFn((metadataLib as any), (n, v) => typeof v === 'function' && (n.includes('createCreateMasterEdition') || n.includes('CreateMasterEdition')));
        }

        if (typeof createMasterFn !== 'function') {
          throw new Error('No compatible createMasterEdition instruction found in mpl-token-metadata');
        }

        let masterEditionIx;
        if (((metadataLib as any).createCreateMasterEditionV3Instruction && createMasterFn === (metadataLib as any).createCreateMasterEditionV3Instruction) || (createMasterFn && createMasterFn.name && createMasterFn.name.includes('CreateMasterEditionV3'))) {
          masterEditionIx = createMasterFn(
            {
              edition: masterEditionPDA,
              mint,
              updateAuthority: this.mainWallet.publicKey,
              mintAuthority: this.mainWallet.publicKey,
              payer: this.mainWallet.publicKey,
              metadata: metadataPDA,
              systemProgram: SystemProgram.programId,
            },
            {
              createMasterEditionArgs: {
                maxSupply: 1n,
              },
            }
          );
        } else if (((metadataLib as any).createCreateMasterEditionV2Instruction && createMasterFn === (metadataLib as any).createCreateMasterEditionV2Instruction) || (createMasterFn && createMasterFn.name && createMasterFn.name.includes('CreateMasterEditionV2'))) {
          masterEditionIx = createMasterFn(
            {
              edition: masterEditionPDA,
              mint,
              updateAuthority: this.mainWallet.publicKey,
              mintAuthority: this.mainWallet.publicKey,
              payer: this.mainWallet.publicKey,
              metadata: metadataPDA,
              systemProgram: SystemProgram.programId,
            },
            {
              createMasterEditionArgs: {
                maxSupply: 1n,
              },
            }
          );
        } else {
          masterEditionIx = createMasterFn(
            {
              edition: masterEditionPDA,
              mint,
              updateAuthority: this.mainWallet.publicKey,
              mintAuthority: this.mainWallet.publicKey,
              payer: this.mainWallet.publicKey,
              metadata: metadataPDA,
              systemProgram: SystemProgram.programId,
            },
            {
              createMasterEditionArgs: {
                maxSupply: 1n,
              },
            }
          );
        }
        transaction.add(masterEditionIx);
      } catch (e) {
        logger.warn('mpl-token-metadata not installed; NFT will lack on-chain metadata. Install @metaplex-foundation/mpl-token-metadata to enable.', e);
      }

      // Send transaction
      const signature = await sendAndConfirmTransaction(
        this.connection,
        transaction,
        [this.mainWallet, mintKeypair],
        {
          commitment: 'confirmed',
          preflightCommitment: 'confirmed',
        }
      );

      logger.info(`NFT minted successfully: ${signature}, mint: ${mint.toString()}`);

      return {
        mint: mint.toString(),
        signature,
        tokenAccount: associatedTokenAccount.toString(),
        metadataAddress: metadataPDA.toString(),
        success: true,
      };
    } catch (error) {
      logger.error('Failed to mint NFT:', error);
      return {
        mint: '',
        signature: '',
        tokenAccount: '',
        metadataAddress: '',
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error',
      };
    }
  }

  /**
   * Transfer NFT to another address
   */
  async transferNFT(request: TransferNFTRequest): Promise<{
    signature: string;
    success: boolean;
    error?: string;
  }> {
    try {
      logger.info('Transferring NFT:', request);

      const mint = new PublicKey(request.mint);
      const recipient = new PublicKey(request.to);

      // Get source and destination token accounts
      const sourceTokenAccount = getAssociatedTokenAddressSync(
        mint,
        this.mainWallet.publicKey
      );
      const destinationTokenAccount = getAssociatedTokenAddressSync(
        mint,
        recipient
      );

      // Check if source account exists and has the NFT
      const sourceAccount = await getAccount(this.connection, sourceTokenAccount);
      if (Number(sourceAccount.amount) === 0) {
        throw new Error('NFT not found in wallet');
      }

      const transaction = new Transaction();

      // Create destination token account if it doesn't exist
      try {
        await getAccount(this.connection, destinationTokenAccount);
      } catch {
        transaction.add(
          createAssociatedTokenAccountInstruction(
            this.mainWallet.publicKey,
            destinationTokenAccount,
            recipient,
            mint
          )
        );
      }

      // Add transfer instruction
      transaction.add(
        createTransferInstruction(
          sourceTokenAccount,
          destinationTokenAccount,
          this.mainWallet.publicKey,
          1, // NFTs have amount of 1
          [],
          TOKEN_PROGRAM_ID
        )
      );

      // Send transaction
      const signature = await sendAndConfirmTransaction(
        this.connection,
        transaction,
        [this.mainWallet],
        {
          commitment: 'confirmed',
          preflightCommitment: 'confirmed',
        }
      );

      logger.info(`NFT transferred successfully: ${signature}`);
      return {
        signature,
        success: true,
      };
    } catch (error) {
      logger.error('Failed to transfer NFT:', error);
      return {
        signature: '',
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error',
      };
    }
  }

  /**
   * Get NFT metadata from on-chain
   */
  async getNFTMetadata(mint: string): Promise<NFTInfo | null> {
    try {
      const mintPubkey = new PublicKey(mint);
      const mintInfo = await getMint(this.connection, mintPubkey);

      // Get metadata PDA
      const metadataPDA = await this.getMetadataPDA(mintPubkey);

      // Fetch metadata account
      const metadataAccount = await this.connection.getAccountInfo(metadataPDA);

      let name: string | undefined;
      let symbol: string | undefined;
      let uri: string | undefined;
      let offchain: NFTMetadata | undefined;

      if (metadataAccount) {
        try {
          // Try to use mpl-token-metadata decode if available
          const maybeMetadataFromAccount =
            (metadataLib as any).Metadata?.fromAccountAddress ||
            (metadataLib as any).accounts?.Metadata?.fromAccountAddress;

          if (typeof maybeMetadataFromAccount === 'function') {
            const decoded = await maybeMetadataFromAccount(this.connection, metadataPDA);
            const data = decoded?.data || decoded?.dataV2 || decoded?.dataV3 || decoded?.data;
            name = this.sanitizePaddedString(data?.name);
            symbol = this.sanitizePaddedString(data?.symbol);
            uri = this.sanitizePaddedString(data?.uri);
          } else {
            // Fallback: best-effort manual parsing – Metaplex pads strings; attempt to read UTF-8 and trim
            // Note: without the SDK, robust parsing is non-trivial; provide only the PDA when unknown
          }

          if (uri) {
            // Normalize IPFS -> gateway if needed
            const httpUri = this.toHttpGateway(uri);
            try {
              const resp = await fetch(httpUri);
              if (resp.ok) {
                const json = (await resp.json()) as any;
                // Normalize image if present
                const normalizedImage = this.toHttpGateway(json?.image);
                offchain = {
                  name: json?.name,
                  symbol: json?.symbol,
                  description: json?.description,
                  image: normalizedImage,
                  properties: json?.properties,
                  attributes: json?.attributes,
                } as NFTMetadata;
              }
            } catch (e) {
              logger.warn('Failed fetching NFT URI JSON', { uri: httpUri, error: e });
            }
          }
        } catch (e) {
          logger.warn('Failed to decode mpl-token-metadata account', e);
        }
      }

      const imageResolved = offchain?.image ? this.toHttpGateway(offchain.image) : undefined;

      return {
        mint,
        owner: '',
        name,
        symbol,
        uri,
        image: imageResolved,
        metadata: offchain,
        supply: Number(mintInfo.supply),
        decimals: mintInfo.decimals,
        metadataAddress: metadataPDA.toString(),
      };
    } catch (error) {
      logger.error('Failed to get NFT metadata:', error);
      return null;
    }
  }

  /**
   * Get all NFTs owned by a wallet
   */
  async getNFTsByOwner(ownerAddress?: string): Promise<NFTInfo[]> {
    try {
      const owner = ownerAddress 
        ? new PublicKey(ownerAddress)
        : this.mainWallet.publicKey;

      // Get all token accounts
      const tokenAccounts = await this.connection.getParsedTokenAccountsByOwner(
        owner,
        {
          programId: TOKEN_PROGRAM_ID,
        }
      );

      const candidates = tokenAccounts.value
        .map((acc) => acc.account.data.parsed.info)
        .filter((info: any) => {
          const amount = info.tokenAmount?.uiAmount;
          return amount === 1; // quick filter before fetching mint info
        });

      const results: NFTInfo[] = [];

      // Fetch mints in parallel (bounded by Promise.all; RPC should handle moderate fanout)
      await Promise.all(
        candidates.map(async (info: any) => {
          try {
            const mintStr = info.mint as string;
            const mintPk = new PublicKey(mintStr);
            const mintInfo = await getMint(this.connection, mintPk);
            if (Number(mintInfo.supply) === 1 && mintInfo.decimals === 0) {
              const meta = await this.getNFTMetadata(mintStr);
              if (meta) {
                results.push({ ...meta, owner: owner.toString() });
              }
            }
          } catch (e) {
            logger.warn('Skipping token while gathering NFTs by owner', e);
          }
        })
      );

      return results;
    } catch (error) {
      logger.error('Failed to get NFTs by owner:', error);
      return [];
    }
  }

  /**
   * Get NFT balance (count) for a wallet
   */
  async getNFTBalance(ownerAddress?: string): Promise<number> {
    const nfts = await this.getNFTsByOwner(ownerAddress);
    return nfts.length;
  }

  /**
   * Verify if a wallet owns the given NFT mint
   */
  async verifyOwnership(mintAddress: string, ownerAddress: string): Promise<{
    isOwner: boolean;
    amount: number;
    tokenAccount?: string;
  }> {
    try {
      const mint = new PublicKey(mintAddress);
      const owner = new PublicKey(ownerAddress);

      // Associated Token Account for this owner and mint
      const ata = getAssociatedTokenAddressSync(mint, owner);

      try {
        const account = await getAccount(this.connection, ata);
        const amount = Number(account.amount);
        return {
          isOwner: amount > 0,
          amount,
          tokenAccount: ata.toString(),
        };
      } catch (e) {
        // ATA doesn't exist or not initialized -> owner doesn't hold this mint
        return { isOwner: false, amount: 0 };
      }
    } catch (error) {
      logger.error('Failed to verify NFT ownership:', error);
      return { isOwner: false, amount: 0 };
    }
  }

  /**
   * Get the main wallet's public key
   */
  getMainWalletAddress(): string {
    return this.mainWallet.publicKey.toString();
  }
}

