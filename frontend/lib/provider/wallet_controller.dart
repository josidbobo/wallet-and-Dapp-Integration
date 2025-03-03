import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/main.dart';
import 'package:frontend/screens/home.dart';
import 'package:reown_appkit/modal/appkit_modal_impl.dart';
import 'package:reown_appkit/reown_appkit.dart';

class WalletControllerProvider extends StateNotifier<ReownAppKitModal?> {
  WalletControllerProvider() : super(null);

  void updateModal(ReownAppKitModal appKitModal) {
    state = appKitModal;
  }

  // List<String> getCountry() {
  //   return state;
  // }
  void _relayClientError(ErrorEvent? event) {
    debugPrint('[SampleDapp] _relayClientError ${event?.error}');
  }

  void _onModalConnect(ModalConnect? event) async {
    navigatorKey.currentState!.pushReplacement(
      MaterialPageRoute(builder: (context) => MyHomePage()),
    );
  }

  void _onModalUpdate(ModalConnect? event) {
    //setState(() {});
  }

  void _onModalNetworkChange(ModalNetworkChange? event) {
    // setState(() {});
  }

  void _onModalDisconnect(ModalDisconnect? event) {
    navigatorKey.currentState!.pushReplacement(
      MaterialPageRoute(builder: (context) => MyHomePage()),
    );
  }

  void disposee(WidgetRef ref) {
    // Unregister event handlers
    state!.appKit!.core.removeLogListener(_logListener);

    ref
        .read(appKitProvider)
        .core
        .relayClient
        .onRelayClientError
        .unsubscribe(_relayClientError);
    ref
        .read(appKitProvider)
        .core
        .relayClient
        .onRelayClientConnect
        .unsubscribe(_setState);
    ref
        .read(appKitProvider)
        .core
        .relayClient
        .onRelayClientDisconnect
        .unsubscribe(_setState);
    // ref
    //     .read(appKitProvider)
    //     .core
    //     .relayClient
    //     .onRelayClientMessage
    //     .unsubscribe(_onRelayMessage);
    //
    ref.read(appKitProvider).onSessionPing.unsubscribe(_onSessionPing);
    // _appKit!.onSessionEvent.unsubscribe(_onSessionEvent);
    //_appKit!.onSessionUpdate.unsubscribe(_onSessionUpdate);
    ref.read(appKitProvider).onSessionConnect.subscribe(_onSessionConnect);
    //
    state!.onModalConnect.unsubscribe(_onModalConnect);
    state!.onModalUpdate.unsubscribe(_onModalUpdate);
    state!.onModalNetworkChange.unsubscribe(_onModalNetworkChange);
    state!.onModalDisconnect.unsubscribe(_onModalDisconnect);
    state!.onModalError.unsubscribe(onModalError);
    //
  }

  void _setState(_) => {};

  void onModalError(ModalError? event) {
    //setState(() {});
    // final snackBar = SnackBar(
    //   content: Text(event!.message, style: TextStyle(color: Colors.red)),
    //   behavior: SnackBarBehavior.floating,
    // );
    // ScaffoldMessenger.of(context).showSnackBar(snackBar);
    print('The error is: ${event!.message}');
  }

  Future<void> registerEventHandlers(WidgetRef ref) async {
    final onLine = ref.read(appKitProvider).core.connectivity.isOnline.value;
    if (!onLine) {
      await Future.delayed(const Duration(milliseconds: 500));
      registerEventHandlers(ref);
      return;
    }
  }

  // void _onRelayMessage(MessageEvent? args) async {
  //   WidgetRef ref;
  //   if (args != null) {
  //     try {
  //       final payloadString = await ref
  //           .read(appKitProvider)
  //           .core
  //           .crypto
  //           .decode(args.topic, args.message);
  //       final data = jsonDecode(payloadString ?? '{}') as Map<String, dynamic>;
  //       debugPrint('[SampleDapp] _onRelayMessage data $data');
  //     } catch (e) {
  //       debugPrint('[SampleDapp] _onRelayMessage error $e');
  //     }
  //   }
  // }

  void _onSessionPing(SessionPing? args) {
    debugPrint('[SampleDapp] _onSessionPing $args');
    // showDialog(
    //   context: context,
    //   builder: (BuildContext context) {
    //     return Text("SessionPinged, Topic: ${args!.topic}");
    //   },
    // );
  }

  void _onSessionConnect(SessionConnect? event) {
    debugPrint(
      '[SampleDapp] _onSessionConnect ${jsonEncode(event?.session.toJson())}',
    );
  }

  void _logListener(String event) {
    debugPrint('[AppKit] $event');
  }

  void subscribeToEvents(WidgetRef ref) {
    // Unregister event handlers
    state!.appKit!.core.addLogListener(_logListener);

    ref
        .read(appKitProvider)
        .core
        .relayClient
        .onRelayClientError
        .subscribe(_relayClientError);
    ref
        .read(appKitProvider)
        .core
        .relayClient
        .onRelayClientConnect
        .subscribe(_setState);
    ref
        .read(appKitProvider)
        .core
        .relayClient
        .onRelayClientDisconnect
        .subscribe(_setState);
    // ref
    //     .read(appKitProvider)
    //     .core
    //     .relayClient
    //     .onRelayClientMessage
    //     .unsubscribe(_onRelayMessage);
    //
    ref.read(appKitProvider).onSessionPing.subscribe(_onSessionPing);
    // _appKit!.onSessionEvent.unsubscribe(_onSessionEvent);
    //_appKit!.onSessionUpdate.unsubscribe(_onSessionUpdate);
    ref.read(appKitProvider).onSessionConnect.subscribe(_onSessionConnect);
    //
    state!.onModalConnect.subscribe(_onModalConnect);
    state!.onModalUpdate.subscribe(_onModalUpdate);
    state!.onModalNetworkChange.subscribe(_onModalNetworkChange);
    state!.onModalDisconnect.subscribe(_onModalDisconnect);
    state!.onModalError.subscribe(onModalError);
    //
  }
}

final controllerProvider =
    StateNotifierProvider<WalletControllerProvider, ReownAppKitModal?>((ref) {
      return WalletControllerProvider();
    });

class AppKitProvider extends StateNotifier<ReownAppKit> {
  AppKitProvider()
    : super(
        ReownAppKit(
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
        ),
      );
}

final appKitProvider = StateNotifierProvider<AppKitProvider, ReownAppKit>((
  ref,
) {
  return AppKitProvider();
});
