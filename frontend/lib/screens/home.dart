import 'package:flutter/material.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key,});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  @override
  Widget build(BuildContext context){
    
  final appKitModal = ReownAppKitModal(
      context: context,
      projectId: dotenv.env['PROJECT_ID'],
      metadata: const PairingMetadata(
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
    //print(dotenv.env['PROJECT_ID']);

    // AppKit Modal instance
    appKitModal.init();
    // Register here the event callbacks on the service you'd like to use. See `Events` section.

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Here you can connect your wallet"),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            AppKitModalNetworkSelectButton(appKit: appKitModal),
            AppKitModalConnectButton(appKit: appKitModal),
            Visibility(
              visible: appKitModal.isConnected,
              child: AppKitModalAccountButton(appKitModal: appKitModal),
            ),
            Text('', style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
       // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
