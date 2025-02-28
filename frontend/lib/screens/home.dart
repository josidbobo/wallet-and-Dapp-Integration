import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/screens/firstpage.dart';
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
  }

  void _onModalUpdate(ModalConnect? event) {
    setState(() {});
  }

  void _onModalNetworkChange(ModalNetworkChange? event) {
    setState(() {});
  }

  void _onModalDisconnect(ModalDisconnect? event) {
    setState(() {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    });
  }

  void _onModalError(ModalError? event) {
    setState(() {});
  }

  Future<void> _registerEventHandlers() async {
    final onLine = _appKit!.core.connectivity.isOnline.value;
    if (!onLine) {
      await Future.delayed(const Duration(milliseconds: 500));
      _registerEventHandlers();
      return;
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

  void _logListener(String event) {
    debugPrint('[AppKit] $event');
  }

  Future<void> initializeService() async {
    // appKitModal = ReownAppKitModal(
    //   context: context,
    //   projectId: dotenv.env['PROJECT_ID'],
    //   metadata: const PairingMetadata(
    //     name: 'Artemis',
    //     description: 'Connecting Wallet to Dapp',
    //     url: 'https://example.com/',
    //     icons: [
    //       'https://mms.businesswire.com/media/20240116762864/en/1997714/23/WalletConnect-Icon-Blueberry.jpg',
    //     ],
    //     redirect: Redirect(
    //       // OPTIONAL
    //       native: 'frontend://',
    //       universal: 'https://reown.com/exampleapp',
    //       linkMode: true,
    //     ),
    //   ),
    // );

    _appKit = ReownAppKit(
      core: ReownCore(
        projectId: dotenv.env['PROJECT_ID'].toString(),
        logLevel: LogLevel.all,
      ),
      metadata: PairingMetadata(
        name: 'Artemis',
        description: 'Connecting Wallet to Dapp',
        url: 'https://example.com/',
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

    // _pageDatas = [
    //   PageData(
    //     page: ConnectPage(appKitModal: _appKitModal!),
    //     title: StringConstants.connectPageTitle,
    //     icon: Icons.home,
    //   ),
    //   PageData(
    //     page: PairingsPage(appKitModal: _appKitModal!),
    //     title: StringConstants.pairingsPageTitle,
    //     icon: Icons.vertical_align_center_rounded,
    //   ),
    //   PageData(
    //     page: SettingsPage(
    //       appKitModal: _appKitModal!,
    //       linkMode: linkModeEnabled,
    //       socials: socialsEnabled,
    //       reinitialize: (bool value, String storageKey) async {
    //         final result = await showDialog<bool>(
    //           context: context,
    //           builder: (BuildContext context) {
    //             return AlertDialog(
    //               content: Text('App will be closed to apply changes'),
    //               actions: [
    //                 TextButton(
    //                   onPressed: () => Navigator.of(context).pop(false),
    //                   child: Text('Cancel'),
    //                 ),
    //                 TextButton(
    //                   onPressed: () => Navigator.of(context).pop(true),
    //                   child: Text('Ok'),
    //                 ),
    //               ],
    //             );
    //           },
    //         );
    //         if (result == true) {
    //           // appkit_sample_socials
    //           await prefs.setBool(storageKey, value);
    //           if (!kDebugMode) {
    //             exit(0);
    //           }
    //         }
    //       },
    //     ),
    //     title: StringConstants.settingsPageTitle,
    //     icon: Icons.settings,
    //   ),
    // ];

    await _appKitModal!.init();
    await _registerEventHandlers();

    final allChains = ReownAppKitModalNetworks.getAllSupportedNetworks();
    // Loop through all the chain data
    // for (final chain in allChains) {
    //   // Loop through the events for that chain
    //   final namespace = ReownAppKitModalNetworks.getNamespaceForChainId(
    //     chain.chainId,
    //   );
    //   for (final event in getChainEvents(namespace)) {
    //     _appKit!.registerEventHandler(
    //       chainId: chain.chainId,
    //       event: event,
    //     );
    //   }
  }

  @override
  void initState() {
    initializeService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //print(dotenv.env['PROJECT_ID']);

    // AppKit Modal instance

    // Register here the event callbacks on the service you'd like to use. See `Events` section.
    if (isConnected) {
      print('User connected');
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BetChainHomePage(appKit: _appKitModal!),
        ),
      );
      print('Connected modal to wallet');
    }
    // appKitModal.onModalConnect.subscribe((ModalConnect? event) {

    // });

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 40),
          child: Column(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Text(
              //   'Welcome to Artemis! One stop for all things Onchain betting',
              //   textAlign: TextAlign.center,
              //   style: Theme.of(
              //     context,
              //   ).textTheme.headlineMedium?.copyWith(color: Colors.blue),
              // ),
              const SizedBox(height: 1),
              AppKitModalNetworkSelectButton(appKit: _appKitModal!),
              AppKitModalConnectButton(
                appKit: _appKitModal!,
                // custom: ElevatedButton(
                //   child: Text('Connect Wallet'),
                //   onPressed: () {

                //   },
                // ),
              ),
            ],
          ),
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
