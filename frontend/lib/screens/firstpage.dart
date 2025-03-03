import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:frontend/main.dart';
import 'package:frontend/screens/home.dart' show MyHomePage;
import 'package:reown_appkit/reown_appkit.dart';

class BetChainHomePage extends StatefulWidget {
  final ReownAppKitModal appKitModal;
  const BetChainHomePage({super.key, required this.appKitModal,});

  @override
  State<BetChainHomePage> createState() => _BetChainHomePageState();
}

class _BetChainHomePageState extends State<BetChainHomePage> {
  
  void _setState(_) => setState(() {});

  void _relayClientError(ErrorEvent? event) {
    debugPrint('[SampleDapp] _relayClientError ${event?.error}');
    _setState('');
  }

  void _onModalConnect(ModalConnect? event) async {
    
  }

  void _onModalUpdate(ModalConnect? event) {
    setState(() {});
  }

  void _onModalNetworkChange(ModalNetworkChange? event) {
    setState(() {});
  }

  void _onModalDisconnect(ModalDisconnect? event) {
    print('Modal disconnected');
    navigatorKey.currentState!.pushReplacement(
      MaterialPageRoute(builder: (context) => MyHomePage()),
    );
    
  }


  void _onModalError(ModalError? event) {
    setState(() {});
    final snackBar = SnackBar(
      content: Text(event!.message, style: TextStyle(color: Colors.red)),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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

  @override
  void dispose() {
    widget.appKitModal.onModalConnect.unsubscribe(_onModalConnect);
    widget.appKitModal.onModalUpdate.unsubscribe(_onModalUpdate);
    widget.appKitModal.onModalNetworkChange.unsubscribe(_onModalNetworkChange);
    widget.appKitModal.onModalDisconnect.unsubscribe(_onModalDisconnect);
    widget.appKitModal.onModalError.unsubscribe(_onModalError);
    widget.appKitModal.onModalDisconnect.unsubscribe(
      _onModalDisconnect,
    );
    widget.appKitModal.appKit!.onSessionConnect.unsubscribe(
      _onSessionConnect,
    );
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    widget.appKitModal.onModalConnect.subscribe(_onModalConnect);
    widget.appKitModal.onModalUpdate.subscribe(_onModalUpdate);
    widget.appKitModal.onModalNetworkChange.subscribe(_onModalNetworkChange);
    widget.appKitModal.onModalDisconnect.subscribe(_onModalDisconnect);
    widget.appKitModal.onModalError.subscribe(_onModalError);
    //
    widget.appKitModal.appKit!.onSessionConnect.subscribe(
      _onSessionConnect,
    );
    widget.appKitModal.onModalDisconnect.subscribe(
      _onModalDisconnect,
    );
  }

  @override
  Widget build(BuildContext context) {
    //widget.appKitModal.onModalDisconnect.subscribe(_onModalDisconnect);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 30),
              child: Text(
                'Welcome to Artemis',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            // Sports categories
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  _buildSportCategory(
                    Icons.sports_soccer,
                    'Football',
                    Colors.indigo.shade100,
                  ),
                  _buildSportCategory(
                    Icons.sports_basketball,
                    'Basketball',
                    Colors.indigo.shade100,
                  ),
                  _buildSportCategory(
                    Icons.sports_tennis,
                    'Tennis',
                    Colors.indigo.shade100,
                  ),
                  _buildSportCategory(
                    Icons.sports_esports,
                    'Esports',
                    Colors.indigo.shade100,
                  ),
                  _buildSportCategory(
                    Icons.more_horiz,
                    'More',
                    Colors.indigo.shade100,
                  ),
                ],
              ),
            ),
            // Popular bets section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Popular Bets',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            _buildPopularBetCard(
              'Champions League Final',
              'Real Madrid vs Liverpool',
              'assets/images/champions_league.jpg',
            ),
            const SizedBox(height: 12),
            _buildPopularBetCard(
              'NBA Finals',
              'Lakers vs Celtics',
              'assets/images/nba_finals.jpg',
            ),
            const SizedBox(height: 24),
            // Connect wallet section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Connect Wallet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              spacing: 2,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: AppKitModalConnectButton(
                    appKit: widget.appKitModal,
                    // custom: ElevatedButton(
                    //   onPressed: () {
                    //     widget.appKit.disconnect();
                    //   },
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: Colors.indigo.shade500,
                    //     minimumSize: const Size(double.infinity, 56),
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(12),
                    //     ),
                    // ),
                    // child: const Text(
                    //   'Connect Wallet',
                    //   style: TextStyle(
                    //     fontSize: 16,
                    //     fontWeight: FontWeight.bold,
                    //     color: Colors.white,
                    //   ),
                    // ),
                  ),
                ),
                AppKitModalAccountButton(
                        appKitModal: widget.appKitModal,
                      ),
                // Expanded(
                //   child: Padding(
                //     padding: const EdgeInsets.all(4),
                //     child: Visibility(
                //       visible: widget.appKitModal.isConnected,
                //       child: 
                //     ),
                //   ),
                // ),
              ],
            ),

            const Spacer(),
            // Bottom navigation bar
            Container(
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavBarItem(Icons.home, 'Home', true),
                  _buildNavBarItem(Icons.view_list, 'Bets', false),
                  _buildNavBarItem(
                    Icons.account_balance_wallet,
                    'Wallet',
                    false,
                  ),
                  _buildNavBarItem(Icons.person, 'Profile', false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSportCategory(IconData icon, String label, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 80,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.indigo.shade600, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.indigo.shade800),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularBetCard(String title, String subtitle, String imagePath) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: Container(
                width: 80,
                height: 80,
                color: Colors.grey.shade300,
                // In a real app, use Image.asset or Image.network
                child: const Icon(Icons.sports, size: 30),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBarItem(IconData icon, String label, bool isSelected) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isSelected ? Colors.indigo.shade600 : Colors.grey.shade500,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.indigo.shade600 : Colors.grey.shade500,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
        if (isSelected)
          Container(
            height: 2,
            width: 20,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.indigo.shade600,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
      ],
    );
  }
}
