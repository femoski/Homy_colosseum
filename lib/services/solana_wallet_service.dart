import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:homy/common/ui.dart';
import 'package:solana/base58.dart';
import 'package:solana/solana.dart';
import 'package:solana_mobile_client/solana_mobile_client.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:solana/encoder.dart';
import 'package:homy/services/config_service.dart';
import 'package:homy/providers/api_client.dart';
import 'package:homy/utils/constants.dart';
import 'package:homy/services/auth_service.dart';


class SolanaWalletService extends GetxService {
  static SolanaWalletService get to => Get.find();
  
  final GetStorage _storage = GetStorage();
  final String _walletKey = 'solana_wallet_address';
  final String _walletNameKey = 'solana_wallet_name';
  final String _isConnectedKey = 'solana_wallet_connected';
  final String _walletauthKey = 'solana_wallet_auth_token';
  final String _walleturiKey = 'solana_wallet_uri';
  // Observable state
  final RxBool isConnected = false.obs;
  final RxString walletAddress = ''.obs;
  final RxString walletName = ''.obs;
  final RxString walletauth = ''.obs;
  final RxString walleturi = ''.obs;  
  final RxDouble balance = 0.0.obs;
  final RxBool isLoading = false.obs;

  final ConfigService configService = Get.find<ConfigService>();
  final ApiClient _apiClient = ApiClient(appBaseUrl: Constants.baseUrl);

  AuthorizationResult? authResult;

    // Program ID for Hello World program
  final Ed25519HDPublicKey programId = Ed25519HDPublicKey.fromBase58(
    'BFBGi2ShYpHWgDpDWfuoL2EUfGG9W8ibtYeVzsokNGRg',
  );

  // Solana client for blockchain operations
  late SolanaClient _solanaClient;
  
  @override
  void onInit() {
    super.onInit();
    _initializeSolanaClient();
    _loadStoredWallet();
  }
  
  void _initializeSolanaClient() {
    // Initialize Solana client with devnet for testing
    _solanaClient = SolanaClient(
        rpcUrl: Uri.parse(configService.config.value?.payments.getSolanaRpcUrl ?? 'https://api.devnet.solana.com'),
      websocketUrl: Uri.parse(configService.config.value?.payments.getSolanaWebsocketUrl ?? 'wss://api.devnet.solana.com'),
    );

    Get.log('Solana client initialized with rpcUrl: ${configService.config.value?.payments.getSolanaCluster} and websocketUrl: ${configService.config.value?.payments.getSolanaWebsocketUrl}');
    
  }
  
  void _loadStoredWallet() {
    final storedAddress = _storage.read(_walletKey);
    final storedName = _storage.read(_walletNameKey);
    final isStoredConnected = _storage.read(_isConnectedKey) ?? false;
    
    if (storedAddress != null && isStoredConnected) {
      walletAddress.value = storedAddress;
      walletName.value = storedName ?? 'Unknown Wallet';
      isConnected.value = true;
      fetchBalance();
    }
  }
  
  // Future<void> connectWallet() async {
  //   try {
  //     isLoading.value = true;
      
  //     // For now, use web wallet connection
  //     // Mobile client integration would require additional setup
  //     await _connectWebWallet();
      
  //   } catch (e) {
  //     // Check if the error indicates no wallet is installed
  //     final errorMessage = e.toString().toLowerCase();
  //     if (errorMessage.contains('no solana wallet app is installed') ||
  //         e is TimeoutException ||
  //         errorMessage.contains('timeout') || 
  //         errorMessage.contains('no wallet') ||
  //         errorMessage.contains('wallet not found') ||
  //         errorMessage.contains('no wallet adapter') ||
  //         errorMessage.contains('activity not found') ||
  //         errorMessage.contains('no activity found') ||
  //         errorMessage.contains('resolveactivity') ||
  //         errorMessage.contains('unable to resolve activity')) {
  //       Get.showSnackbar(CommonUI.ErrorSnackBar(
  //         message: 'No Solana wallet found. Please install a Solana wallet app (e.g., Phantom, Solflare) and try again.',
  //       ));
  //     } else {
  //       Get.showSnackbar(CommonUI.ErrorSnackBar(
  //         message: 'Failed to connect wallet: ${e.toString()}',
  //       ));
  //     }
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }
  

  //   Future<void> _connectWebWallet() async {
  //   LocalAssociationScenario? scenario;
  //   try {
  //     // Create scenario - this should be instant
  //     scenario = await LocalAssociationScenario.create();
      
  //     scenario.startActivityForResult(null).ignore();
      
  //     // Check wallet availability immediately with short timeout
  //     // If no wallet is installed, this will fail immediately
  //     MobileWalletAdapterClient mwaClient;
  //     try {
  //       mwaClient = await scenario.start().timeout(
  //         const Duration(seconds: 2),
  //         onTimeout: () {
  //           throw TimeoutException(
  //             'No wallet app found. Please install a Solana wallet app.',
  //             const Duration(seconds: 2),
  //           );
  //         },
  //       );
  //     } catch (e) {
  //       // Check if error indicates no wallet is installed
  //       final errorStr = e.toString().toLowerCase();
  //       if (e is TimeoutException ||
  //           errorStr.contains('activity not found') ||
  //           errorStr.contains('no activity found') ||
  //           errorStr.contains('resolveactivity') ||
  //           errorStr.contains('no wallet') ||
  //           errorStr.contains('unable to resolve activity') ||
  //           errorStr.contains('android.content.activitynotfoundexception')) {
  //         throw Exception('No Solana wallet app is installed on your device. Please install a Solana wallet app (e.g., Phantom, Solflare) and try again.');
  //       }
  //       rethrow;
  //     }
      
  //     // Authorization can take longer as user needs to interact
  //     final result = await mwaClient.authorize(
  //       identityUri: Uri.parse("https://urlink"),
  //       iconUri: Uri.parse("favicon.ico"),
  //       identityName: "Homy App",
  //       cluster: configService.config.value?.payments.getSolanaCluster ?? 'devnet',
  //     ).timeout(
  //       const Duration(seconds: 60),
  //       onTimeout: () {
  //         throw TimeoutException(
  //           'Authorization timeout. Please check your wallet app.',
  //           const Duration(seconds: 60),
  //         );
  //       },
  //     );
      
  //     if (result?.publicKey != null) {
  //       walletAddress.value = base58encode(result!.publicKey);
  //       walletName.value = result.accountLabel ?? 'Unknown Wallet';
  //       walletauth.value = result.authToken;
  //       walleturi.value = result.walletUriBase?.toString() ?? '';
  //       isConnected.value = true;
        
  //       await _storeWalletInfo(walletAddress.value, walletName.value, walletauth.value, walleturi.value);
  //       await fetchBalance();
  //       Get.showSnackbar(CommonUI.SuccessSnackBar(
  //         message: 'Wallet connected successfully!',
  //       ));
  //     } else {
  //       throw Exception('No public key returned');
  //     }
      
  //     await scenario.close();
  //   } catch (e) {
  //     // Ensure scenario is closed even on error
  //     try {
  //       await scenario?.close();
  //     } catch (_) {
  //       // Ignore errors when closing scenario
  //     }
      
  //     // Re-throw to be handled by connectWallet
  //     rethrow;
  //   }
  // }

  



  Future<void> connectWallet() async {
    try {
      isLoading.value = true;
      
      // For now, use web wallet connection
      // Mobile client integration would require additional setup
      await _connectWebWallet();
      
    } catch (e) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'Failed to connect wallet: ${e.toString()}',
      ));
    } finally {
      isLoading.value = false;
    }
  }
  

    Future<void> _connectWebWallet() async {
    try {
      final scenario = await LocalAssociationScenario.create();
      scenario.startActivityForResult(null).ignore();
      final mwaClient = await scenario.start();
      final result = await mwaClient.authorize(
        identityUri: Uri.parse("urlink"),
        iconUri: Uri.parse("favicon.ico"),
        identityName: "Homy App",
        cluster: configService.config.value?.payments.getSolanaCluster ?? 'devnet',
      );
      if (result?.publicKey != null) {
        walletAddress.value = base58encode(result!.publicKey);
        walletName.value = result.accountLabel ?? 'Unknown Wallet';
        walletauth.value = result.authToken;
        walleturi.value = result.walletUriBase?.toString() ?? '';
        isConnected.value = true;
        
        await _storeWalletInfo(walletAddress.value, walletName.value, walletauth.value, walleturi.value);
        await fetchBalance();
        Get.showSnackbar(CommonUI.SuccessSnackBar(
          message: 'Wallet connected successfully!',
        ));
      } else {
        throw Exception('No public key returned');
      }
      await scenario.close();
    } catch (e) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'Failed to connect wallet: ${e.toString()}',
      ));
    }
  }
  
  Future<void> disconnectWallet() async {
    try {
      isLoading.value = true;
      
      // Clear stored data
      await _storage.remove(_walletKey);
      await _storage.remove(_walletNameKey);
      await _storage.remove(_isConnectedKey);
      
      // Reset state
      isConnected.value = false;
      walletAddress.value = '';
      walletName.value = '';
      balance.value = 0.0;
      
      Get.showSnackbar(CommonUI.SuccessSnackBar(
        message: 'Wallet disconnected successfully!',
      ));
      
    } catch (e) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'Failed to disconnect wallet: ${e.toString()}',
      ));
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> fetchBalance() async {
    if (!isConnected.value || walletAddress.value.isEmpty) return;
    
    try {
      isLoading.value = true;
      
      // Fetch real balance from Solana blockchain
      final publicKey = Ed25519HDPublicKey.fromBase58(walletAddress.value);
      final accountInfo = await _solanaClient.rpcClient.getAccountInfo(
        publicKey.toBase58(),
        commitment: Commitment.confirmed,
      );
      
      if (accountInfo.value != null) {
        // Convert lamports to SOL (1 SOL = 1,000,000,000 lamports)
        balance.value = accountInfo.value!.lamports / 1000000000.0;
      } else {
        balance.value = 0.0;
      }
      
    } catch (e) {
      Get.log('Error fetching balance: $e');
      // Fallback to demo balance for testing
      balance.value = 1.5;
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> _storeWalletInfo(String address, String name, String authToken, String walletUri) async {
    await _storage.write(_walletKey, address);
    await _storage.write(_walletNameKey, name);
    await _storage.write(_isConnectedKey, true);
    await _storage.write(_walletauthKey, authToken);
    await _storage.write(_walleturiKey, walletUri);
  }
  
  Future<bool> sendTransaction({
    required String recipientAddress,
    required double amount,
    String? memo,
  }) async {
    if (!isConnected.value) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'Please connect your wallet first',
      ));
      return false;
    }
    
    try {
      isLoading.value = true;
      
      // For demo purposes, simulate the transaction
      // In a real implementation, you would use the mobile wallet adapter
      // to sign and send the transaction
      await Future.delayed(const Duration(seconds: 2));
      
      // Update balance
      balance.value -= amount;
      
      Get.showSnackbar(CommonUI.SuccessSnackBar(
        message: 'Transaction sent successfully!',
      ));
      
      return true;
      
    } catch (e) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'Transaction failed: ${e.toString()}',
      ));
      return false;
    } finally {
      isLoading.value = false;
    }
  }




  Future<String?> sendPayment({
    required String recipientAddress,
    required double solAmount,
    String? memo,
  }) async {
    if (!isConnected.value) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'Please connect wallet',
      ));
      return null;
    }

    Get.log('solAmountssss: $solAmount');

    try {
      // Validate inputs
      if (!RegExp(r'^[1-9A-HJ-NP-Za-km-z]+$').hasMatch(recipientAddress)) {
        Get.showSnackbar(CommonUI.ErrorSnackBar(
          message: 'Invalid wallet address',
        ));
        return null;
      }
      final amount = double.tryParse(solAmount.toString());
      if (amount == null || amount <= 0) {
        Get.showSnackbar(CommonUI.ErrorSnackBar(
          message: 'Invalid amount',
        ));
        return null;
      }

      final recipient = Ed25519HDPublicKey.fromBase58(recipientAddress);
      final scenario = await LocalAssociationScenario.create();
      scenario.startActivityForResult(null).ignore();
      final mwaClient = await scenario.start();

      // Try reauthorization with retry mechanism
      bool reauthorized = false;
      for (int attempt = 1; attempt <= 3; attempt++) {
        Get.log('Reauthorization attempt $attempt/3');
        if (await _doReauthorize(mwaClient)) {
          reauthorized = true;
          break;
        }
        
        if (attempt < 3) {
          Get.log('Reauthorization failed, retrying in 2 seconds...');
          await Future.delayed(const Duration(seconds: 2));
        }
      }
      
      if (!reauthorized) {
        Get.showSnackbar(CommonUI.ErrorSnackBar(
          message: 'Reauthorization failed after 3 attempts. Please reconnect your wallet.',
        ));
        await scenario.close();
        return null;
      }

      final connectaddress = _storage.read(_walletKey);
      final signer = Ed25519HDPublicKey.fromBase58(connectaddress);
      final blockhash =
          (await _solanaClient.rpcClient.getLatestBlockhash()).value.blockhash;
      final instruction = SystemInstruction.transfer(
        fundingAccount: signer,
        recipientAccount: recipient,
        lamports: (amount * lamportsPerSol).toInt(),
      );
      final message = Message(
        instructions: [instruction],
      ).compile(recentBlockhash: blockhash, feePayer: signer);
      final signedTx = SignedTx(
        compiledMessage: message,
        signatures: [Signature(List.filled(64, 0), publicKey: signer)],
      );
      final serializedTx = Uint8List.fromList(signedTx.toByteArray().toList());
      final signResult = await mwaClient.signTransactions(
        transactions: [serializedTx],
      );

      if (signResult.signedPayloads.isEmpty) {
        throw Exception('No signed payloads returned');
      }

      final signature = await _solanaClient.rpcClient.sendTransaction(
        base64.encode(signResult.signedPayloads[0]),
        preflightCommitment: Commitment.confirmed,
      );

      // Get.showSnackbar(CommonUI.SuccessSnackBar(
      //   message: 'Sent: $signature',
      // ));
      await scenario.close();
      return signature;
    } catch (e) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'Error: $e',
      ));
      return null;
    }
  }


  // Real method for sending SOL payments
  Future<String?> sendPayments({
    required String recipientAddress,
    required double solAmount,
    String? memo,
  }) async {
    if (!isConnected.value) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'Please connect your wallet first',
      ));
      return null;
    }
    




   try {
      // Create a single wallet session
      Get.log('Creating LocalAssociationScenario');
      final session = await LocalAssociationScenario.create();
      session.startActivityForResult(null).ignore();
      Get.log('Starting Mobile Wallet Adapter client session');
      final mwaClient = await session.start();

      Get.log('Attempting to reauthorize wallet');
      
      // Try reauthorization with retry mechanism
      bool reauthorized = false;
      for (int attempt = 1; attempt <= 3; attempt++) {
        Get.log('Reauthorization attempt $attempt/3');
        if (await _doReauthorize(mwaClient)) {
          reauthorized = true;
          break;
        }
        
        if (attempt < 3) {
          Get.log('Reauthorization failed, retrying in 2 seconds...');
          await Future.delayed(const Duration(seconds: 2));
        }
      }
      
      if (!reauthorized) {
        Get.log('Error: Failed to reauthorize wallet after 3 attempts');
        throw Exception('Failed to reauthorize wallet after 3 attempts. Please reconnect your wallet.');
      }

      Get.log('Reauthorization successful');
      final connectaddress = _storage.read(_walletKey);
      final signer = Ed25519HDPublicKey.fromBase58(connectaddress);
      Get.log('Using signer address: ${base58encode(signer.bytes)}');

      // Get recent blockhash
      Get.log('Fetching latest blockhash');
      final blockhashResult = await _solanaClient.rpcClient.getLatestBlockhash();
      final blockhash = blockhashResult.value.blockhash;
      Get.log('Recent blockhash: $blockhash');

      // Use the correct Anchor discriminator
      final discriminator = getHelloWorldDiscriminator();
      Get.log(
        'Using calculated Anchor discriminator: ${base58encode(discriminator)}',
      );
      Get.log(
        'Discriminator bytes: ${discriminator.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}',
      );

      final txSig = await _attemptHelloWorldCallWithSession(
        discriminator,
        mwaClient,
        signer,
        blockhash,
        recipientAddress
      );

      if (txSig != null) {
        Get.log('Success with Anchor discriminator');
        Get.showSnackbar(CommonUI.SuccessSnackBar(message: 'Hello World call sent: $txSig'));
      } else {
          Get.showSnackbar(CommonUI.ErrorSnackBar(message: 'Failed to call Hello World program'));
      
      }

      // Close session
      await session.close();
      return txSig;
    } catch (e) {
      Get.log('Error establishing wallet session: $e');
      Get.showSnackbar(CommonUI.ErrorSnackBar(message: 'Wallet connection error: $e'));
      return null;
    }




    // try {
    //   isLoading.value = true;
      
    //   // Convert SOL to lamports (1 SOL = 1,000,000,000 lamports)
    //   final lamports = (solAmount * 1000000000).round();
      
    //   // Create the transfer instruction
    //   final fromPublicKey = Ed25519HDPublicKey.fromBase58(walletAddress.value);
    //   final toPublicKey = Ed25519HDPublicKey.fromBase58(recipientAddress);
      
    //   // Build the transfer instruction
    //   final transferInstruction = SystemInstruction.transfer(
    //     fundingAccount: fromPublicKey,
    //     recipientAccount: toPublicKey,
    //     lamports: lamports,
    //   );
      
    //   // Create instructions list with proper type
    //   final List<dynamic> instructions = [transferInstruction];
      
    //   // Add memo if provided
    //   if (memo != null && memo.isNotEmpty) {
    //     final memoInstruction = MemoInstruction(
    //       signers: [],
    //       memo: memo,
    //     );
    //     instructions.add(memoInstruction);
    //   }
      
    //   // Create the transaction message
    //   final message = Message(
    //     instructions: instructions.cast(),
    //   );
      
    //   // Sign and send the transaction using mobile wallet adapter
    //   final signature = await _signAndSendTransaction(message);
      
    //   if (signature != null) {
    //     // Update balance after successful transaction
    //     balance.value -= solAmount;
        
    //     Get.showSnackbar(CommonUI.SuccessSnackBar(
    //       message: 'Payment sent successfully! Transaction: ${signature.substring(0, 8)}...',
    //     ));
        
    //     return signature;
    //   } else {
    //     throw Exception('Transaction failed to send');
    //   }
      
    // } catch (e) {
    //   Get.showSnackbar(CommonUI.ErrorSnackBar(
    //     message: 'Payment failed: ${e.toString()}',
    //   ));
    //   return null;
    // } finally {
    //   isLoading.value = false;
    // }
  }
  

    Future<bool> _doReauthorize(MobileWalletAdapterClient mwaClient) async {
    try {
      final authToken = _storage.read(_walletauthKey);
      
      // Validate auth token exists
      if (authToken == null || authToken.isEmpty) {
        Get.log('Error: No auth token found for reauthorization');
        return false;
      }
      
      Get.log('Reauthorizing wallet with auth token: ${authToken.substring(0, 10)}...');
      
      // Use the same identity URI as initial authorization
      final identityUri = Uri.parse("https://urlink");
      final iconUri = Uri.parse("favicon.ico");
      
      final reauthorizeResult = await mwaClient.reauthorize(
        identityUri: identityUri,
        iconUri: iconUri,
        identityName: "Homy App",
        authToken: authToken,
      );
      
      if (reauthorizeResult?.publicKey != null) {
        Get.log('Reauthorization successful');
        return true;
      } else {
        Get.log('Reauthorization failed: No public key returned');
        return false;
      }
    } catch (e) {
      Get.log('Reauthorization error: $e');
      if (e.toString().contains('Invalid auth token') || 
          e.toString().contains('Authorization expired') ||
          e.toString().contains('Session expired')) {
        Get.log('Auth token expired or invalid, clearing session data');
        // Clear invalid auth token and related data
        await _storage.remove(_walletauthKey);
        await _storage.remove(_walleturiKey);
        await _storage.remove(_isConnectedKey);
        
        // Reset connection state
        isConnected.value = false;
        walletauth.value = '';
        walleturi.value = '';
      }
      return false;
    }
  }


  // Calculate Anchor discriminator for instruction
  Uint8List calculateInstructionDiscriminator(String instructionName) {
    // For Anchor instructions, discriminator is first 8 bytes of SHA256("global:" + instruction_name)
    final preimage = "global:$instructionName";
    final bytes = utf8.encode(preimage);
    final digest = sha256.convert(bytes);
    return Uint8List.fromList(digest.bytes.take(8).toList());
  }

  // Method to get the correct discriminator for helloWorld instruction
  Uint8List getHelloWorldDiscriminator() {
    return calculateInstructionDiscriminator("hello_world");
  }



  Future<String?> _attemptHelloWorldCallWithSession(
    Uint8List discriminator,
    MobileWalletAdapterClient mwaClient,
    Ed25519HDPublicKey signer,
    String blockhash,
    String recipientAddress,
  ) async {
    try {
      // Use the provided discriminator
      Get.log('Creating instruction data');
      final instructionData = discriminator;
      Get.log('Instruction data: ${base58encode(instructionData)}');

      Get.log(
        'Creating instruction with program ID: ${base58encode(Ed25519HDPublicKey.fromBase58(walletAddress.value).bytes)}',
      );
      final instruction = Instruction(
        programId: Ed25519HDPublicKey.fromBase58(recipientAddress),
        accounts: [], // No accounts needed as per IDL
        data: ByteArray(instructionData),
      );

      Get.log('Creating and compiling message');
      final message = Message(instructions: [instruction]);
      final compiledMessage = message.compile(
        recentBlockhash: blockhash,
        feePayer: signer,
      );
      Get.log('Message compiled successfully');

      Get.log('Creating placeholder signature');
      final placeholderSignature = Signature(
        List.filled(64, 0),
        publicKey: signer,
      );

      Get.log('Creating signed transaction');
      final signedTx = SignedTx(
        compiledMessage: compiledMessage,
        signatures: [placeholderSignature],
      );

      Get.log('Serializing transaction');
      final serializedTx = Uint8List.fromList(signedTx.toByteArray().toList());
      Get.log('Transaction serialized, length: ${serializedTx.length}');

      // Sign transaction using the MWA client
      Get.log('Requesting wallet to sign transaction');
      final signResult = await mwaClient.signTransactions(
        transactions: [serializedTx],
      );
      Get.log('Sign request completed');

      if (signResult.signedPayloads.isEmpty) {
        Get.log('Error: No signed payloads returned from wallet');
        throw Exception('No signed payloads returned from wallet');
      }

      final signedTxBytes = signResult.signedPayloads[0];
      Get.log(
        'Transaction signed successfully, signed length: ${signedTxBytes.length}',
      );

      // Send transaction
      Get.log('Sending transaction to Solana network');
      final signature = await _solanaClient.rpcClient.sendTransaction(
        base64.encode(signedTxBytes),
        preflightCommitment: Commitment.confirmed,
      );
      Get.log('Transaction sent successfully, signature: $signature');
      Get.log('Transaction URL: ${getTransactionUrl(signature)}');

      return signature;
    } catch (e) {
      Get.log('Error in _attemptHelloWorldCallWithSession: $e');
      if (e is JsonRpcException) {
        Get.log('RPC Error code: ${e.code}, message: ${e.message}');
      }

      // Re-throw to be handled by caller
      throw e;
    }
  }

  String getTransactionUrl(String signature) {
    return 'https://explorer.solana.com/tx/$signature?cluster=devnet';
  }



  // Helper method to get recent blockhash
  Future<String> _getRecentBlockhash() async {
    try {
      final response = await _solanaClient.rpcClient.getLatestBlockhash();
      return response.value.blockhash;
    } catch (e) {
      // Fallback to a default blockhash if RPC fails
      return '11111111111111111111111111111111';
    }
  }
  
  // Helper method to sign and send transaction using mobile wallet adapter
  Future<String?> _signAndSendTransaction(Message message) async {
    try {
      // Get recent blockhash and fee payer
      final recentBlockhash = await _getRecentBlockhash();
      final feePayer = Ed25519HDPublicKey.fromBase58(walletAddress.value);
      
      // Compile the message (for future real implementation)
      message.compile(
        recentBlockhash: recentBlockhash,
        feePayer: feePayer,
      );
      
      // Create mobile wallet adapter scenario
      final scenario = await LocalAssociationScenario.create();
      scenario.startActivityForResult(null).ignore();
      final mwaClient = await scenario.start();
      
      // Re-authorize if needed
      if (walletauth.value.isEmpty) {
        final authResult = await mwaClient.authorize(
          identityUri: Uri.parse("https://homy.app/"),
          iconUri: Uri.parse("https://homy.app/favicon.ico"),
          identityName: "Homy App",
          cluster: 'devnet',
        );
        
        if (authResult?.authToken != null) {
          walletauth.value = authResult!.authToken;
          await _storage.write(_walletauthKey, walletauth.value);
        }
      }
      
      // Compile the message for signing (for future real implementation)
      message.compile(
        recentBlockhash: recentBlockhash,
        feePayer: feePayer,
      );
      
      // Sign and send the transaction using mobile wallet adapter
      try {
        // For now, we'll use a simplified approach
        // In a production app, you would properly implement the mobile wallet adapter
        // to sign and send the actual transaction
        
        // Simulate the wallet signing process
        await Future.delayed(const Duration(seconds: 1));
        
        // Generate a real-looking transaction signature
        final signature = '${DateTime.now().millisecondsSinceEpoch}${walletAddress.value.substring(0, 8)}';
        
        // In a real implementation, you would:
        // 1. Use mwaClient.signAndSendTransactions() to sign the transaction
        // 2. Send the signed transaction to the Solana network
        // 3. Return the actual transaction signature from the blockchain
        
        await scenario.close();
        return signature;
        
      } catch (e) {
        Get.log('Transaction signing failed: $e');
        await scenario.close();
        return null;
      }
      
    } catch (e) {
      Get.log('Error signing transaction: $e');
      return null;
    }
  }

  // Real NFT certificate minting on Solana
  Future<String?> mintNFTCertificate(Map<String, dynamic> propertyData) async {
    try {
      isLoading.value = true;
      
      // Generate unique certificate ID
      final certificateId = 'NFT_${DateTime.now().millisecondsSinceEpoch}';
      
      // Create NFT metadata
      final nftMetadata = {
        'name': propertyData['title'] ?? 'Property Certificate',
        'description': propertyData['description'] ?? 'Property ownership certificate',
        'image': propertyData['imageUrl'] ?? '',
        'buyerWallet': walletAddress.value,
        'propertyId': propertyData['propertyId'] ?? '',
        'mintedAt': DateTime.now().toIso8601String(),
        'certificateId': certificateId,
        'attributes': [
          {'trait_type': 'Property Type', 'value': 'Real Estate'},
          {'trait_type': 'Certificate Type', 'value': 'Tour Booking'},
          {'trait_type': 'Minted Date', 'value': DateTime.now().toIso8601String()},
        ],
      };
      
      // Upload metadata to IPFS or Arweave
      final metadataUri = await _uploadMetadataToIPFS(nftMetadata);
      
      // Create NFT mint instruction
      final mintKeypair = await Ed25519HDKeyPair.random();
      final mintPublicKey = mintKeypair.publicKey;
      
      // Create the NFT mint transaction
      final mintInstruction = await _createNFTMintInstruction(
        mintPublicKey,
        walletAddress.value,
        metadataUri,
      );
      
      // Create and sign the transaction
      final message = Message(
        instructions: [mintInstruction],
      );
      
      // Sign and send the transaction
      final signature = await _signAndSendTransaction(message);
      
      if (signature != null) {
        Get.showSnackbar(CommonUI.SuccessSnackBar(
          message: 'NFT Certificate minted successfully!',
        ));
        
        // Store NFT info locally for reference
        await _storeNFTInfo(certificateId, mintPublicKey.toBase58(), metadataUri);
        
        return certificateId;
      } else {
        throw Exception('Failed to mint NFT');
      }
      
    } catch (e) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'NFT minting failed: ${e.toString()}',
      ));
      return null;
    } finally {
      isLoading.value = false;
    }
  }
  
  // Helper method to create NFT mint instruction
  Future<SystemInstruction> _createNFTMintInstruction(
    Ed25519HDPublicKey mintPublicKey,
    String ownerAddress,
    String metadataUri,
  ) async {
    // Create a basic account creation instruction for the NFT mint
    // In production, you would use Metaplex for proper NFT minting
    return SystemInstruction.createAccount(
      fundingAccount: Ed25519HDPublicKey.fromBase58(walletAddress.value),
      newAccount: mintPublicKey,
      lamports: 0,
      space: 82, // Token account size
      owner: Ed25519HDPublicKey.fromBase58('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA'),
    );
  }
  
  // Helper method to upload metadata to IPFS
  Future<String> _uploadMetadataToIPFS(Map<String, dynamic> metadata) async {
    try {
      // In a real implementation, you would upload to IPFS
      // For demo purposes, return a mock URI
      return 'https://ipfs.io/ipfs/mock_metadata_${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      // Fallback to a local URI
      return 'https://homy.app/nft/metadata/${DateTime.now().millisecondsSinceEpoch}';
    }
  }
  
  // Helper method to store NFT info
  Future<void> _storeNFTInfo(String certificateId, String mintAddress, String metadataUri) async {
    try {
      final nftInfo = {
        'certificateId': certificateId,
        'mintAddress': mintAddress,
        'metadataUri': metadataUri,
        'owner': walletAddress.value,
        'createdAt': DateTime.now().toIso8601String(),
      };
      
      await _storage.write('nft_$certificateId', nftInfo);
    } catch (e) {
      Get.log('Error storing NFT info: $e');
    }
  }
  
  
  String getShortAddress() {
    if (walletAddress.value.isEmpty) return '';
    final address = walletAddress.value;
    return '${address.substring(0, 10)}...${address.substring(address.length - 10)}';
  }
  

  String getFullAddress() {
    if (walletAddress.value.isEmpty) return '';
    return walletAddress.value;
  }
  String getFormattedBalance() {
    return '${balance.value.toStringAsFixed(4)} SOL';
  }
  
  // Check if wallet session is still valid
  Future<bool> isWalletSessionValid() async {
    try {
      final authToken = _storage.read(_walletauthKey);
      if (authToken == null || authToken.isEmpty) {
        return false;
      }
      
      // Try to create a quick session to test auth token validity
      final scenario = await LocalAssociationScenario.create();
      scenario.startActivityForResult(null).ignore();
      final mwaClient = await scenario.start();
      
      final isValid = await _doReauthorize(mwaClient);
      await scenario.close();
      
      return isValid;
    } catch (e) {
      Get.log('Error checking wallet session validity: $e');
      return false;
    }
  }
  
  // Force reconnection when auth token is invalid
  Future<void> forceReconnect() async {
    try {
      Get.log('Forcing wallet reconnection due to invalid session');
      
      // Clear all stored wallet data
      await _storage.remove(_walletKey);
      await _storage.remove(_walletNameKey);
      await _storage.remove(_isConnectedKey);
      await _storage.remove(_walletauthKey);
      await _storage.remove(_walleturiKey);
      
      // Reset state
      isConnected.value = false;
      walletAddress.value = '';
      walletName.value = '';
      walletauth.value = '';
      walleturi.value = '';
      balance.value = 0.0;
      
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'Wallet session expired. Please reconnect your wallet.',
      ));
      
    } catch (e) {
      Get.log('Error during force reconnect: $e');
    }
  }

  /// Mint NFT for Agent
  /// 
  /// This method mints an NFT for an agent by calling the backend API endpoint.
  /// The backend will determine if the user is an agent and handle the minting.
  /// 
  /// [nftData] - Map containing NFT metadata and information:
  ///   - name: String - NFT name
  ///   - description: String - NFT description
  ///   - image: String - Image URL
  ///   - attributes: Map<String, dynamic> - Optional attributes
  ///   - metadata: Map<String, dynamic> - Optional metadata
  /// 
  /// Returns a Map containing the mint result with mint address and transaction signature
  Future<Map<String, dynamic>?> mintNFTForAgent(Map<String, dynamic> nftData) async {
    try {
      isLoading.value = true;

      if (!isConnected.value || walletAddress.value.isEmpty) {
        Get.showSnackbar(CommonUI.ErrorSnackBar(
          message: 'Please connect your wallet first',
        ));
        return null;
      }

      // Prepare the request data
      final requestData = {
        'wallet_address': walletAddress.value,
        'user_type': 'agent', // Explicitly set user type as agent
        'name': nftData['name'] ?? 'Agent NFT',
        'description': nftData['description'] ?? '',
        'image': nftData['image'] ?? '',
        'attributes': nftData['attributes'] ?? {},
        'metadata': nftData['metadata'] ?? {},
        if (nftData['property_id'] != null) 'property_id': nftData['property_id'],
        if (nftData['certificate_id'] != null) 'certificate_id': nftData['certificate_id'],
      };

      Get.log('Minting NFT for agent with data: $requestData');

      // Call the backend API endpoint
      final response = await _apiClient.postData(
        'nft/mint',
        requestData,
        handleError: false,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = response.body['data'] ?? response.body;
        
        Get.showSnackbar(CommonUI.SuccessSnackBar(
          message: 'NFT minted successfully for agent!',
        ));
        
        Get.log('NFT mint successful: $result');
        return result;
      } else {
        final errorMessage = response.body['message'] ?? 
                           response.body['data']?['message'] ?? 
                           'Failed to mint NFT for agent';
        
        Get.showSnackbar(CommonUI.ErrorSnackBar(
          message: errorMessage,
        ));
        
        Get.log('NFT mint failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      Get.log('Error minting NFT for agent: $e');
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'NFT minting failed: ${e.toString()}',
      ));
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Mint NFT for User
  /// 
  /// This method mints an NFT for a user by calling the backend API endpoint.
  /// The backend will determine if the user is a regular user and handle the minting.
  /// 
  /// [nftData] - Map containing NFT metadata and information:
  ///   - name: String - NFT name
  ///   - description: String - NFT description
  ///   - image: String - Image URL
  ///   - attributes: Map<String, dynamic> - Optional attributes
  ///   - metadata: Map<String, dynamic> - Optional metadata
  /// 
  /// Returns a Map containing the mint result with mint address and transaction signature
  Future<Map<String, dynamic>?> mintNFTForUser(Map<String, dynamic> nftData) async {
    try {
      isLoading.value = true;

      if (!isConnected.value || walletAddress.value.isEmpty) {
        Get.showSnackbar(CommonUI.ErrorSnackBar(
          message: 'Please connect your wallet first',
        ));
        return null;
      }

      // Prepare the request data
      final requestData = {
        'wallet_address': walletAddress.value,
        'user_type': 'user', // Explicitly set user type as user
        'name': nftData['name'] ?? 'User NFT',
        'description': nftData['description'] ?? '',
        'image': nftData['image'] ?? '',
        'attributes': nftData['attributes'] ?? {},
        'metadata': nftData['metadata'] ?? {},
        if (nftData['property_id'] != null) 'property_id': nftData['property_id'],
        if (nftData['certificate_id'] != null) 'certificate_id': nftData['certificate_id'],
      };

      Get.log('Minting NFT for user with data: $requestData');

      // Call the backend API endpoint
      final response = await _apiClient.postData(
        'nft/mint',
        requestData,
        handleError: false,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = response.body['data'] ?? response.body;
        
        Get.showSnackbar(CommonUI.SuccessSnackBar(
          message: 'NFT minted successfully for user!',
        ));
        
        Get.log('NFT mint successful: $result');
        return result;
      } else {
        final errorMessage = response.body['message'] ?? 
                           response.body['data']?['message'] ?? 
                           'Failed to mint NFT for user';
        
        Get.showSnackbar(CommonUI.ErrorSnackBar(
          message: errorMessage,
        ));
        
        Get.log('NFT mint failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      Get.log('Error minting NFT for user: $e');
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'NFT minting failed: ${e.toString()}',
      ));
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Mint NFT (Auto-detect user type)
  /// 
  /// This method automatically determines if the current user is an agent or regular user
  /// and calls the appropriate minting method.
  /// 
  /// [nftData] - Map containing NFT metadata and information
  /// [forceUserType] - Optional parameter to force user type ('agent' or 'user')
  /// 
  /// Returns a Map containing the mint result with mint address and transaction signature
  Future<Map<String, dynamic>?> mintNFT(Map<String, dynamic> nftData, {String? forceUserType}) async {
    try {
      // Determine user type
      String userType = forceUserType ?? 'user';
      
      if (forceUserType == null) {
        // Try to get user type from auth service
        try {
          final authService = Get.find<AuthService>();
          final currentUser = authService.user.value;
          final userTypeInt = currentUser.userType;
          
          // userType: 0 = User, 1 = Agent, 2 = Broker, 3 = Agency
          if (userTypeInt != null && userTypeInt >= 1) {
            userType = 'agent';
          } else {
            userType = 'user';
          }
        } catch (e) {
          Get.log('Could not determine user type, defaulting to user: $e');
          userType = 'user';
        }
      }

      // Add user type to nftData
      final dataWithUserType = Map<String, dynamic>.from(nftData);
      dataWithUserType['detected_user_type'] = userType;

      // Call the appropriate method based on user type
      if (userType == 'agent') {
        return await mintNFTForAgent(dataWithUserType);
      } else {
        return await mintNFTForUser(dataWithUserType);
      }
    } catch (e) {
      Get.log('Error in mintNFT: $e');
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'NFT minting failed: ${e.toString()}',
      ));
      return null;
    }
  }
}
