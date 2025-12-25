import 'package:BookMyTeacher/presentation/widgets/show_success_alert.dart';
import 'package:flutter/material.dart';
import '../../core/constants/endpoints.dart';
import '../../services/api_service.dart';

class WalletSection extends StatefulWidget {
  const WalletSection({super.key});

  @override
  State<WalletSection> createState() => _WalletSectionState();
}

class _WalletSectionState extends State<WalletSection> {
  Map<String, dynamic>? walletData;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadWallet();
  }

  Future<void> loadWallet() async {
    try {
      final data = await ApiService().fetchWalletData();
      setState(() {
        walletData = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading wallet: $e')));
    }
  }

  void openMyWallet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => WalletBottomSheet(walletData: walletData ?? {}),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Wallet",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              InkWell(
                onTap: openMyWallet,
                child: Row(
                  children: const [
                    Text(
                      "My Wallet",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_right, size: 20),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Wallet Cards Row
          Row(
            children: [
              buildWalletCard(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF)],
                ),

                // gradient: const LinearGradient(
                //     colors: [Color(0xFFB9FBC0), Color(0xFF98F5E1)]),
                imageUrl:
                    "${Endpoints.domain}/assets/mobile-app/icons/green-coin.png",
                value: "${walletData?['green']['balance'] ?? 0}",
                title: "Green Coin",
              ),
              const SizedBox(width: 8),
              buildWalletCard(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF)],
                ),
                // gradient: const LinearGradient(
                //     colors: [Color(0xFFFFE29D), Color(0xFFFFC1C1)]),
                imageUrl:
                    "${Endpoints.domain}/assets/mobile-app/icons/rupee-coin.png",
                value: "₹ ${walletData?['rupee']['balance'] ?? 0}",
                title: "Rupees",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildWalletCard({
    required String imageUrl,
    required String value,
    required String title,
    required Gradient gradient,
  }) {
    return Expanded(
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Image.network(imageUrl, height: 60, width: 60),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ===================== BOTTOM SHEET ======================

class WalletBottomSheet extends StatefulWidget {
  final Map<String, dynamic> walletData;

  const WalletBottomSheet({super.key, required this.walletData});

  @override
  State<WalletBottomSheet> createState() => _WalletBottomSheetState();
}

class _WalletBottomSheetState extends State<WalletBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool greenRequestPending = false;
  bool rupeeRequestPending = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _showTransactionDetail(BuildContext context, Map<String, dynamic> tx) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(tx['title']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _detailRow("Type", tx['type']),
            _detailRow("Amount/Coin", "₹${tx['amount']}"),
            _detailRow("Date", tx['date']),
            _detailRow("Status", tx['status']),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.black54, fontSize: 13),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final green = widget.walletData['green'] ?? {};
    final rupee = widget.walletData['rupee'] ?? {};

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 40),
                const Text(
                  "My Wallet",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            //
            // // Tabs
            TabBar(
              controller: _tabController,
              labelColor: Colors.green.shade800,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.green,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: "Green Coins"),
                Tab(text: "Rupees"),
              ],
            ),
            const SizedBox(height: 10),
            //
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildGreenCoinTab(green, scrollController),
                  _buildRupeesTab(rupee, scrollController),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    return Placeholder();
  }

  Widget _buildGreenCoinTab(
    Map<String, dynamic> data,
    ScrollController controller,
  ) {
    final balance = (data['balance'] ?? 0).toDouble();
    final target = (data['target'] ?? 1000).toDouble();
    final progress = (balance / target).clamp(0.0, 1.0);

    final history = List<Map<String, dynamic>>.from(data['history'] ?? []);

    return SingleChildScrollView(
      controller: controller,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _walletSummaryCard(
            iconUrl:
                "${Endpoints.domain}/assets/mobile-app/icons/green-coin.png",
            title: "Green Coins",
            value: balance.toString(),
            color: Colors.green.shade50,
          ),
          const SizedBox(height: 10),

          _progressSection(
            balance,
            target,
            progress,
            "Convert to Rupees",
            greenRequestPending,
            onPressed: () async {
              setState(() => greenRequestPending = true);
              print('object');
              final result = await ApiService().convertToRupees(balance);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result['message'] ?? 'Conversion submitted'),
                ),
              );
            },

            // onPressed: () {
            //   setState(() => greenRequestPending = !greenRequestPending);
            //   // Call API here to request conversion
            // },
          ),
          const SizedBox(height: 20),

          _historyList(history, "Green Coin History"),
        ],
      ),
    );
  }

  Widget _buildRupeesTab(
    Map<String, dynamic> data,
    ScrollController controller,
  ) {
    final balance = (data['balance'] ?? 0).toDouble();
    final target = (data['target'] ?? 5000).toDouble();
    final progress = (balance / target).clamp(0.0, 1.0);

    final history = List<Map<String, dynamic>>.from(data['history'] ?? []);

    return SingleChildScrollView(
      controller: controller,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _walletSummaryCard(
            iconUrl:
                "${Endpoints.domain}/assets/mobile-app/icons/rupee-coin.png",
            title: "Rupees",
            value: "₹$balance",
            color: Colors.yellow.shade50,
          ),
          const SizedBox(height: 10),

          _progressSection(
            balance,
            target,
            progress,
            "Transfer to Bank",
            rupeeRequestPending,
            onPressed: () async {
              setState(() => rupeeRequestPending = true);
              final result = await ApiService().transferToBank(balance);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result['message'] ?? 'Transfer submitted'),
                ),
              );
            },

            // onPressed: () {
            //   setState(() => rupeeRequestPending = !rupeeRequestPending);
            //   // Call API here to request transfer
            // },
          ),
          const SizedBox(height: 20),

          _historyList(history, "Rupee Transaction History"),
        ],
      ),
    );
  }

  Widget _walletSummaryCard({
    required String iconUrl,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Image.network(iconUrl, height: 50, width: 50),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _progressSection(
    double balance,
    double target,
    double progress,
    String buttonText,
    bool isPending, {
    required VoidCallback onPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Progress: ₹$balance / ₹$target",
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.shade200,
          color: Colors.green,
          minHeight: 8,
          borderRadius: BorderRadius.circular(10),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: isPending || progress < 1.0 ? null : onPressed,
          // onPressed: () async {
          //   if (balance >= target) {
          //     setState(() => rupeeRequestPending = true);
          //     if (!isPending) {
          //       final result = await ApiService().transferToBank(balance);
          //       showSuccessAlert(
          //         context,
          //         title: result['success'] == true ? "Success!" : "failed",
          //         subtitle: result['message'] ?? 'Transfer submitted',
          //         timer: 6,
          //         color: result['success'] == true ? Colors.green : Colors.red,
          //         showButton: false, // 👈 hide/show button easily
          //       );
          //     } else {
          //       showSuccessAlert(
          //         context,
          //         title: "failed",
          //         subtitle: 'You have already submitted request',
          //         timer: 6,
          //         color: Colors.red,
          //         showButton: false, // 👈 hide/show button easily
          //       );
          //     }
          //
          //     // ScaffoldMessenger.of(context).showSnackBar(
          //     //   SnackBar(
          //     //     content: Text(result['message'] ?? 'Transfer submitted'),
          //     //   ),
          //     // );
          //   } else {
          //     ScaffoldMessenger.of(context).showSnackBar(
          //       SnackBar(content: Text('Your target not archived')),
          //     );
          //   }
          // },

          icon: Icon(
            isPending ? Icons.hourglass_bottom : Icons.swap_horiz,
            color: Colors.white,
          ),
          label: Text(
            isPending ? "Request Pending" : buttonText,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: balance >= target
                ? Colors.greenAccent
                : Colors.black26,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _historyList(List<Map<String, dynamic>> history, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        if (history.isEmpty)
          const Text(
            "No transactions found",
            style: TextStyle(color: Colors.black54),
          )
        else
          ...history.map(
            (tx) => Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading: Icon(
                  tx['type'] == 'credit'
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  color: tx['type'] == 'credit' ? Colors.green : Colors.red,
                ),
                title: Text(tx['title']),
                subtitle: Text(tx['date']),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.remove_red_eye_rounded,
                    color: Colors.teal,
                  ),
                  onPressed: () => _showTransactionDetail(context, tx),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
