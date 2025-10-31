import Joi from 'joi';

export const sendSolSchema = Joi.object({
  to: Joi.string().required().custom((value, helpers) => {
    try {
      // Validate Solana public key format
      if (value.length < 32 || value.length > 44) {
        return helpers.error('string.invalid');
      }
      return value;
    } catch {
      return helpers.error('string.invalid');
    }
  }).messages({
    'string.invalid': 'Invalid Solana address format'
  }),
  amount: Joi.number().positive().required().max(1000000).messages({
    'number.positive': 'Amount must be positive',
    'number.max': 'Amount exceeds maximum limit'
  }),
  memo: Joi.string().max(290).optional()
});

export const sendTokenSchema = Joi.object({
  to: Joi.string().required().custom((value, helpers) => {
    try {
      if (value.length < 32 || value.length > 44) {
        return helpers.error('string.invalid');
      }
      return value;
    } catch {
      return helpers.error('string.invalid');
    }
  }).messages({
    'string.invalid': 'Invalid Solana address format'
  }),
  tokenMint: Joi.string().required().custom((value, helpers) => {
    try {
      if (value.length < 32 || value.length > 44) {
        return helpers.error('string.invalid');
      }
      return value;
    } catch {
      return helpers.error('string.invalid');
    }
  }).messages({
    'string.invalid': 'Invalid token mint address format'
  }),
  amount: Joi.number().positive().required().max(1000000).messages({
    'number.positive': 'Amount must be positive',
    'number.max': 'Amount exceeds maximum limit'
  }),
  decimals: Joi.number().integer().min(0).max(9).required().messages({
    'number.integer': 'Decimals must be an integer',
    'number.min': 'Decimals must be at least 0',
    'number.max': 'Decimals must be at most 9'
  }),
  memo: Joi.string().max(290).optional()
});

export const withdrawalSchema = Joi.object({
  to: Joi.string().required().custom((value, helpers) => {
    try {
      if (value.length < 32 || value.length > 44) {
        return helpers.error('string.invalid');
      }
      return value;
    } catch {
      return helpers.error('string.invalid');
    }
  }).messages({
    'string.invalid': 'Invalid Solana address format'
  }),
  amount: Joi.number().positive().required().max(1000000).messages({
    'number.positive': 'Amount must be positive',
    'number.max': 'Amount exceeds maximum limit'
  }),
  tokenMint: Joi.string().optional().custom((value, helpers) => {
    if (!value) return value;
    try {
      if (value.length < 32 || value.length > 44) {
        return helpers.error('string.invalid');
      }
      return value;
    } catch {
      return helpers.error('string.invalid');
    }
  }).messages({
    'string.invalid': 'Invalid token mint address format'
  }),
  memo: Joi.string().max(290).optional()
});

export const transactionSignatureSchema = Joi.object({
  signature: Joi.string().required().min(80).max(100).messages({
    'string.min': 'Invalid transaction signature format',
    'string.max': 'Invalid transaction signature format'
  })
});

export const mintNFTSchema = Joi.object({
  name: Joi.string().required().min(1).max(32).messages({
    'string.min': 'NFT name must be at least 1 character',
    'string.max': 'NFT name must be at most 32 characters'
  }),
  symbol: Joi.string().required().min(1).max(10).messages({
    'string.min': 'NFT symbol must be at least 1 character',
    'string.max': 'NFT symbol must be at most 10 characters'
  }),
  description: Joi.string().required().min(1).max(5000).messages({
    'string.min': 'Description must be at least 1 character',
    'string.max': 'Description must be at most 500 characters'
  }),
  imageUri: Joi.string().uri().optional().messages({
    'string.uri': 'Image URI must be a valid URL'
  }),
  recipient: Joi.string().optional().custom((value, helpers) => {
    if (!value) return value;
    try {
      if (value.length < 32 || value.length > 44) {
        return helpers.error('string.invalid');
      }
      return value;
    } catch {
      return helpers.error('string.invalid');
    }
  }).messages({
    'string.invalid': 'Invalid recipient address format'
  }),
  properties: Joi.object({
    propertyAddress: Joi.string().optional(),
    propertyType: Joi.string().optional(),
    squareFeet: Joi.number().positive().optional(),
    bedrooms: Joi.number().integer().min(0).optional(),
    bathrooms: Joi.number().integer().min(0).optional(),
    yearBuilt: Joi.number().integer().min(1800).max(new Date().getFullYear()).optional(),
    location: Joi.object({
      city: Joi.string().optional(),
      state: Joi.string().optional(),
      country: Joi.string().optional(),
      zipCode: Joi.string().optional(),
    }).optional(),
  }).optional(),
  attributes: Joi.array().items(
    Joi.object({
      trait_type: Joi.string().required(),
      value: Joi.alternatives().try(Joi.string(), Joi.number()).required(),
    })
  ).optional(),
});

export const transferNFTSchema = Joi.object({
  mint: Joi.string().required().custom((value, helpers) => {
    try {
      if (value.length < 32 || value.length > 44) {
        return helpers.error('string.invalid');
      }
      return value;
    } catch {
      return helpers.error('string.invalid');
    }
  }).messages({
    'string.invalid': 'Invalid NFT mint address format'
  }),
  to: Joi.string().required().custom((value, helpers) => {
    try {
      if (value.length < 32 || value.length > 44) {
        return helpers.error('string.invalid');
      }
      return value;
    } catch {
      return helpers.error('string.invalid');
    }
  }).messages({
    'string.invalid': 'Invalid recipient address format'
  }),
});

export const nftMintSchema = Joi.object({
  mint: Joi.string().required().custom((value, helpers) => {
    try {
      if (value.length < 32 || value.length > 44) {
        return helpers.error('string.invalid');
      }
      return value;
    } catch {
      return helpers.error('string.invalid');
    }
  }).messages({
    'string.invalid': 'Invalid NFT mint address format'
  }),
});

export const ownerAddressSchema = Joi.object({
  owner: Joi.string().optional().custom((value, helpers) => {
    if (!value) return value;
    try {
      if (value.length < 32 || value.length > 44) {
        return helpers.error('string.invalid');
      }
      return value;
    } catch {
      return helpers.error('string.invalid');
    }
  }).messages({
    'string.invalid': 'Invalid owner address format'
  }),
});

export const verifyOwnershipQuerySchema = Joi.object({
  mint: Joi.string().required().custom((value, helpers) => {
    try {
      if (value.length < 32 || value.length > 44) {
        return helpers.error('string.invalid');
      }
      return value;
    } catch {
      return helpers.error('string.invalid');
    }
  }).messages({
    'string.invalid': 'Invalid NFT mint address format'
  }),
  owner: Joi.string().required().custom((value, helpers) => {
    try {
      if (value.length < 32 || value.length > 44) {
        return helpers.error('string.invalid');
      }
      return value;
    } catch {
      return helpers.error('string.invalid');
    }
  }).messages({
    'string.invalid': 'Invalid owner address format'
  }),
});
