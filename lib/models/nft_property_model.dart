// Standalone NFT model (no base property).

/// Standalone NFT Property Model
class NFTPropertyModel {
  final bool isMinted;
  final String? mintAddress;
  final String? nftMetadataUri;
  final String? ownerWalletAddress;
  final DateTime? mintedAt;
  final String? transactionSignature;
  final bool isVerified;
  final String? certificateId;
  final Map<String, dynamic>? nftAttributes;
  final Map<String, dynamic>? metadata;
  final String? nftImage;
  final String? nftName;


  NFTPropertyModel({
    this.isMinted = false,
    this.mintAddress,
    this.nftMetadataUri,
    this.ownerWalletAddress,
    this.mintedAt,
    this.transactionSignature,
    this.isVerified = false,
    this.certificateId,
    this.nftAttributes,
    this.metadata,
    this.nftImage,
    this.nftName,
  });

  // Base property constructor removed

  /// Create from JSON with NFT properties
  factory NFTPropertyModel.fromJson(Map<String, dynamic> json) {
    // Support both snake_case and camelCase API payloads
    final dynamic attributesRaw = json['nft_attributes'] ?? json['nftAttributes'];

    final bool minted = (json['is_minted'] ?? json['isMinted']) ?? false;
    final String? mintAddr = json['mint_address'] ?? json['mintAddress'] ?? json['mint'];
    final String? nftName = json['nft_name'] ?? json['nftName'] ?? json['name'];
    final String? nftImage = json['nft_image'] ?? json['nftImage'] ?? json['image'];
    final String? metaUri =
        json['nft_metadata_uri'] ?? json['nftMetadataUri'] ?? json['metadataAddress'];
    final String? ownerAddr =
        json['owner_wallet_address'] ?? json['ownerWalletAddress'];
    final dynamic mintedAtRaw = json['minted_at'] ?? json['mintedAt'];
    final DateTime? mintedAt = mintedAtRaw is String
        ? DateTime.tryParse(mintedAtRaw)
        : null;
    final String? txSig =
        json['transaction_signature'] ?? json['transactionSignature'];
    final bool verified =
        (json['is_verified'] ?? json['isVerified']) ?? false;
    final String? certId = json['certificate_id'] ?? json['certificateId'];
    final Map<String, dynamic>? attributes = attributesRaw is Map
        ? Map<String, dynamic>.from(attributesRaw)
        : null;
    final Map<String, dynamic>? metadata = json['metadata'] is Map
        ? Map<String, dynamic>.from(json['metadata'])
        : null;

    // Construct without requiring base property fields
    return NFTPropertyModel(
      isMinted: minted,
      mintAddress: mintAddr,
      nftMetadataUri: metaUri,
      ownerWalletAddress: ownerAddr,
      mintedAt: mintedAt,
      transactionSignature: txSig,
      isVerified: verified,
      certificateId: certId,
      nftAttributes: attributes,
      metadata: metadata,
      nftImage: nftImage,
      nftName: nftName,
    );
  }

  /// Convert to JSON with NFT properties
  Map<String, dynamic> toJson() {
    return {
      'is_minted': isMinted,
      'mint_address': mintAddress,
      'nft_metadata_uri': nftMetadataUri,
      'owner_wallet_address': ownerWalletAddress,
      'minted_at': mintedAt?.toIso8601String(),
      'transaction_signature': transactionSignature,
      'is_verified': isVerified,
      'certificate_id': certificateId,
      'nft_attributes': nftAttributes,
      'metadata': metadata,
      'nft_image': nftImage,
      'nft_name': nftName,
    };
  }

  /// Copy with NFT properties
  NFTPropertyModel copyWithNFT({
    bool? isMinted,
    String? mintAddress,
    String? nftMetadataUri,
    String? ownerWalletAddress,
    DateTime? mintedAt,
    String? transactionSignature,
    bool? isVerified,
    String? certificateId,
    Map<String, dynamic>? nftAttributes,
    Map<String, dynamic>? metadata,
    String? nftName,
  }) {
    return NFTPropertyModel(
      isMinted: isMinted ?? this.isMinted,
      mintAddress: mintAddress ?? this.mintAddress,
      nftMetadataUri: nftMetadataUri ?? this.nftMetadataUri,
      ownerWalletAddress: ownerWalletAddress ?? this.ownerWalletAddress,
      mintedAt: mintedAt ?? this.mintedAt,
      transactionSignature: transactionSignature ?? this.transactionSignature,
      isVerified: isVerified ?? this.isVerified,
      certificateId: certificateId ?? this.certificateId,
      nftAttributes: nftAttributes ?? this.nftAttributes,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Get the NFT state as a string
  String get nftState => isMinted ? 'Off Chain' : 'On Chain';

  /// Get the short mint address for display
  String get shortMintAddress {
    if (mintAddress == null || mintAddress!.isEmpty) return '';
    return '${mintAddress!.substring(0, 8)}...${mintAddress!.substring(mintAddress!.length - 8)}';
  }

  /// Get the Solana Explorer URL
  String? get solanaExplorerUrl {
    if (mintAddress == null || mintAddress!.isEmpty) return null;
    return 'https://explorer.solana.com/address/$mintAddress?cluster=devnet';
  }

  /// Get the Phantom Wallet deep link
  String? get phantomWalletUrl {
    if (mintAddress == null || mintAddress!.isEmpty) return null;
    return 'https://phantom.app/ul/browse/$mintAddress?cluster=devnet';
  }

  String toString() {
    return 'NFTPropertyModel(isMinted: $isMinted, mintAddress: $mintAddress, isVerified: $isVerified)';
  }
}

/// Enum for NFT property states
enum NFTPropertyState {
  preview,
  minted,
}

/// Extension on NFTPropertyState for display
extension NFTPropertyStateExtension on NFTPropertyState {
  String get displayName {
    switch (this) {
      case NFTPropertyState.preview:
        return 'Preview';
      case NFTPropertyState.minted:
        return 'Minted';
    }
  }
}
