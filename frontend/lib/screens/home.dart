import 'dart:convert';
import 'package:frontend/main.dart';
import 'package:frontend/screens/home.dart';

import 'package:flutter/material.dart';
import 'package:frontend/screens/firstpage.dart';
import 'package:frontend/widgets/events.dart';

import 'package:reown_appkit/reown_appkit.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ReownAppKit? _appKit;
  ReownAppKitModal? _appKitModal;
  bool isConnected = false;

  void _setState(_) => setState(() {});

  void _relayClientError(ErrorEvent? event) {
    debugPrint('[SampleDapp] _relayClientError ${event?.error}');
    _setState('');
  }

  void _onModalConnect(ModalConnect? event) async {
    setState(() {
      isConnected = true;
    });
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => BetChainHomePage(appKitModal: _appKitModal!),
      ),
    );
  }

  void _onModalUpdate(ModalConnect? event) {
    setState(() {});
  }

  void _onModalNetworkChange(ModalNetworkChange? event) {
    setState(() {});
  }

  void _onModalDisconnect(ModalDisconnect? event) {
    print('Modal disconnected');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage()),
    );
  }

  @override
  void dispose() {
    // Unregister event handlers
    _appKitModal!.appKit!.core.removeLogListener(_logListener);

    _appKit!.core.relayClient.onRelayClientError.unsubscribe(_relayClientError);
    _appKit!.core.relayClient.onRelayClientConnect.unsubscribe(_setState);
    _appKit!.core.relayClient.onRelayClientDisconnect.unsubscribe(_setState);
    _appKit!.core.relayClient.onRelayClientMessage.unsubscribe(_onRelayMessage);
    //
    _appKit!.onSessionPing.unsubscribe(_onSessionPing);
    _appKit!.onSessionEvent.unsubscribe(_onSessionEvent);
    //_appKit!.onSessionUpdate.unsubscribe(_onSessionUpdate);
    _appKit!.onSessionConnect.subscribe(_onSessionConnect);
    //
    _appKitModal!.onModalConnect.unsubscribe(_onModalConnect);
    _appKitModal!.onModalUpdate.unsubscribe(_onModalUpdate);
    _appKitModal!.onModalNetworkChange.unsubscribe(_onModalNetworkChange);
    _appKitModal!.onModalDisconnect.unsubscribe(_onModalDisconnect);
    _appKitModal!.onModalError.unsubscribe(_onModalError);
    //
    super.dispose();
  }

  void _onModalError(ModalError? event) {
    // setState(() {});
    // final snackBar = SnackBar(
    //   content: Text(event!.message, style: TextStyle(color: Colors.red)),
    // );
    // ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _registerEventHandlers() async {
    final onLine = _appKit!.core.connectivity.isOnline.value;
    if (!onLine) {
      await Future.delayed(const Duration(milliseconds: 500));
      _registerEventHandlers();
      return;
    }

    final allChains = ReownAppKitModalNetworks.getAllSupportedNetworks();
    for (final chain in allChains) {
      // Loop through the events for that chain
      final namespace = ReownAppKitModalNetworks.getNamespaceForChainId(
        chain.chainId,
      );
      for (final event in getChainEvents(namespace)) {
        _appKit!.registerEventHandler(chainId: chain.chainId, event: event);
      }
    }
  }

  void _onRelayMessage(MessageEvent? args) async {
    if (args != null) {
      try {
        final payloadString = await _appKit!.core.crypto.decode(
          args.topic,
          args.message,
        );
        final data = jsonDecode(payloadString ?? '{}') as Map<String, dynamic>;
        debugPrint('[SampleDapp] _onRelayMessage data $data');
      } catch (e) {
        debugPrint('[SampleDapp] _onRelayMessage error $e');
      }
    }
  }

  void _onSessionPing(SessionPing? args) {
    debugPrint('[SampleDapp] _onSessionPing $args');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Text("SessionPinged, Topic: ${args!.topic}");
      },
    );
  }

  void _onSessionConnect(SessionConnect? event) {
    debugPrint(
      '[SampleDapp] _onSessionConnect ${jsonEncode(event?.session.toJson())}',
    );
  }

  void _onSessionEvent(SessionEvent? args) {
    debugPrint('[SampleDapp] _onSessionEvent $args');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EventWidget(
          title: args!.topic,
          content:
              'Topic: ${args.topic}\nEvent Name: ${args.name}\nEvent Data: ${args.data}',
        );
      },
    );
  }

  void _logListener(String event) {
    debugPrint('[AppKit] $event');
  }

  List<String> getChainEvents(String namespace) {
    switch (namespace) {
      case 'eip155':
        return NetworkUtils.defaultNetworkEvents['eip155']!.toList();
      case 'solana':
        return NetworkUtils.defaultNetworkEvents['solana']!.toList();
      default:
        return [];
    }
  }

  Future<void> initializeService() async {

    _appKit = ReownAppKit(
      core: ReownCore(
        projectId: dotenv.env['PROJECT_ID'].toString(),
        logLevel: LogLevel.all,
      ),
      metadata: PairingMetadata(
        name: 'Artemis',
        description: 'Connecting Wallet to Dapp',
        url: 'https://artemis.com.ng/',
        icons: [
          'https://mms.businesswire.com/media/20240116762864/en/1997714/23/WalletConnect-Icon-Blueberry.jpg',
        ],
        redirect: Redirect(
          // OPTIONAL
          native: 'frontend://',
          universal: 'https://reown.com/exampleapp',
          linkMode: true,
        ),
      ),
    );

    // Register event handlers
    _appKit!.core.relayClient.onRelayClientError.subscribe(_relayClientError);
    _appKit!.core.relayClient.onRelayClientConnect.subscribe(_setState);
    _appKit!.core.relayClient.onRelayClientDisconnect.subscribe(_setState);
    _appKit!.core.relayClient.onRelayClientMessage.subscribe(_onRelayMessage);

    _appKit!.onSessionPing.subscribe(_onSessionPing);
    //_appKit!.onSessionEvent.subscribe(_onSessionEvent);
    //_appKit!.onSessionUpdate.subscribe(_onSessionUpdate);
    _appKit!.onSessionConnect.subscribe(_onSessionConnect);
    //_appKit!.onSessionAuthResponse.subscribe(_onSessionAuthResponse);

    // See https://docs.reown.com/appkit/flutter/core/custom-chains
    // final extraChains = ReownAppKitModalNetworks.extra['eip155']!;
    // ReownAppKitModalNetworks.addSupportedNetworks('eip155', extraChains);
    // ReownAppKitModalNetworks.removeSupportedNetworks('solana');
    // ReownAppKitModalNetworks.removeTestNetworks();

    _appKitModal = ReownAppKitModal(
      context: context,
      appKit: _appKit,
      enableAnalytics: true,
      getBalanceFallback: () async {
        // This method will be triggered if getting the balance from our blockchain API fails
        // You could place here your own getBalance method
        return 0.0;
      },
    );

    _appKitModal!.appKit!.core.addLogListener(_logListener);

    _appKitModal!.onModalConnect.subscribe(_onModalConnect);
    _appKitModal!.onModalUpdate.subscribe(_onModalUpdate);
    _appKitModal!.onModalNetworkChange.subscribe(_onModalNetworkChange);
    _appKitModal!.onModalDisconnect.subscribe(_onModalDisconnect);
    _appKitModal!.onModalError.subscribe(_onModalError);

    await _appKitModal!.init();
    await _registerEventHandlers();

    final allChains = ReownAppKitModalNetworks.getAllSupportedNetworks();
    // Loop through all the chain data
    for (final chain in allChains) {
      // Loop through the events for that chain
      final namespace = ReownAppKitModalNetworks.getNamespaceForChainId(
        chain.chainId,
      );
      for (final event in getChainEvents(namespace)) {
        _appKit!.registerEventHandler(chainId: chain.chainId, event: event);
      }
    }
  }

  @override
  void initState() {
    initializeService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (mounted) {
      print(_appKitModal!.onModalConnect);
    }

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 40),
          child: Center(
            child: Column(
              spacing: 10,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Image.network(
                  "https://boostylabs.com/wp-content/uploads/2024/12/1_dH0FTGqFrIIhdzpmLnm-ug.jpg",
                  isAntiAlias: true,
                ),
                Text(
                  'Welcome to Artemis',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  'Experience seamless betting with secure transactions and easy access to your funds',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 1),
                GestureDetector(
                  onTap: () {
                    if (_appKitModal!.isConnected) {
                      navigatorKey.currentState!.pushReplacement(
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  BetChainHomePage(appKitModal: _appKitModal!),
                        ),
                      );
                    }
                  },
                  child: SizedBox(
                    width: 200,
                    child: AppKitModalNetworkSelectButton(
                      appKit: _appKitModal!,
                      context: context,
                    ),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: AppKitModalConnectButton(
                    appKit: _appKitModal!,
                    context: context,
                  ),
                ),

                ElevatedButton(
                  onPressed: () async {
                    final decimalUnits = (decimals.first as BigInt); // decimals value from `decimals` contract function
                    final transferValue = _formatValue(0.23, decimals: decimalUnits); // your format value function

// Transfer USDT
  // Transfer 0.01 amount of Token using Smart Contract's transfer function
  final result = await _appKitModal!.requestWriteContract(
    topic: _appKitModal!.session!.topic,
    chainId: _appKitModal!.selectedChain!.chainId,
    deployedContract: deployedContract,
    functionName: 'transfer',
    transaction: Transaction(
      from: EthereumAddress.fromHex(_appKitModal!.session?.getAddress(namespace)), // sender address
    ),
    parameters: [
       0.23 USDT
    ],
  );

                  }
                  child: Text('Set up Event')
                )
              ],
            ),
          ),
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
