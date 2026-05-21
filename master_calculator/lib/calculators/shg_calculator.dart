import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../services/history_service.dart';

class SHGCalculator extends StatefulWidget {
  const SHGCalculator({super.key});

  @override
  State<SHGCalculator> createState() => _SHGCalculatorState();
}

class _SHGCalculatorState extends State<SHGCalculator> with SingleTickerProviderStateMixin {
  // =====================================================
  // CONTROLLERS
  // =====================================================

  late TabController _tabController;

  final TextEditingController membersController = TextEditingController();
  final TextEditingController monthsController = TextEditingController();
  final TextEditingController weeklySavingController = TextEditingController(text: "10");
  final TextEditingController fourthWeekController = TextEditingController(text: "20");
  final TextEditingController loanController = TextEditingController();
  final TextEditingController loanMonthsController = TextEditingController();
  final TextEditingController fineController = TextEditingController(text: "5");
  final TextEditingController absentController = TextEditingController(text: "0");
  final TextEditingController presentController = TextEditingController();

  // =====================================================
  // VALUES
  // =====================================================

  bool isHindi = true;
  bool latePayment = false;
  bool _isLoading = false;
  final GlobalKey _dashboardKey = GlobalKey();

  // Savings Tab Values
  double totalSavings = 0;
  double monthlySavings = 0;
  double yearlySavings = 0;
  double totalFine = 0;
  double totalCollection = 0;
  double groupFund = 0;

  // Loan Tab Values
  double interest = 0;
  double totalPayable = 0;
  double monthlyEMI = 0;
  double activeLoan = 0;
  double interestEarned = 0;

  // Bank Loan Tab Values
  double bankLoanInterest = 0;
  double bankLoanPayable = 0;

  // Dashboard Values
  int totalMembers = 0;
  double totalSavingsAll = 0;
  double totalFineAll = 0;
  double activeLoanAll = 0;
  double interestEarnedAll = 0;
  double groupFundAll = 0;

  // Meeting Management
  int totalAbsent = 0;
  int totalPresent = 0;

  // =====================================================
  // TRANSLATION
  // =====================================================

  Map<String, Map<String, String>> _translations = {
    "Hindi": {
      "appTitle": "जीविका एसएचजी कैलकुलेटर",
      "savings": "बचत",
      "loan": "लोन",
      "penalty": "जुर्माना",
      "bankLoan": "बैंक लोन",
      "dashboard": "डैशबोर्ड",
      "groupSavingSystem": "सामूहिक बचत प्रणाली",
      "totalMembers": "सदस्य संख्या",
      "totalMonths": "कितने महीने",
      "weeklySaving": "साप्ताहिक बचत (₹)",
      "fourthWeekSaving": "चौथे सप्ताह बचत (₹)",
      "calculateSavings": "बचत निकालें",
      "totalSavings": "कुल बचत",
      "monthlySavings": "मासिक बचत",
      "yearlySavings": "वार्षिक बचत",
      "totalCollection": "कुल संग्रह",
      "groupFund": "समूह फंड",
      "loanInterest": "लोन और ब्याज",
      "loanAmount": "लोन राशि (₹)",
      "loanMonths": "अवधि (महीने)",
      "paymentDelayed": "3 महीने से भुगतान नहीं हुआ?",
      "calculateInterest": "ब्याज निकालें",
      "totalInterest": "कुल ब्याज",
      "totalPayable": "कुल देय राशि",
      "monthlyEMI": "मासिक EMI",
      "activeLoan": "सक्रिय लोन",
      "interestEarned": "अर्जित ब्याज",
      "meetingPenalty": "बैठक जुर्माना",
      "absentMembers": "अनुपस्थित सदस्य",
      "presentMembers": "उपस्थित सदस्य",
      "finePerMember": "प्रति सदस्य जुर्माना (₹)",
      "calculateFine": "जुर्माना निकालें",
      "totalFine": "कुल जुर्माना",
      "bankLoanSystem": "बैंक लोन प्रणाली",
      "bankLoanAmount": "बैंक लोन राशि (₹)",
      "loanDuration": "लोन अवधि (महीने)",
      "calculateBankLoan": "बैंक हिसाब निकालें",
      "bankInterest": "बैंक ब्याज",
      "totalBankPayable": "कुल बैंक भुगतान",
      "shareReport": "रिपोर्ट साझा करें",
      "copyReport": "रिपोर्ट कॉपी करें",
      "savedToHistory": "इतिहास में सहेजा गया",
      "members": "सदस्य",
      "savingsLabel": "बचत",
      "fineLabel": "जुर्माना",
      "loanLabel": "लोन",
      "interestLabel": "ब्याज",
      "fundLabel": "फंड",
    },
    "English": {
      "appTitle": "Jeevika SHG Calculator",
      "savings": "Savings",
      "loan": "Loan",
      "penalty": "Penalty",
      "bankLoan": "Bank Loan",
      "dashboard": "Dashboard",
      "groupSavingSystem": "Group Saving System",
      "totalMembers": "Total Members",
      "totalMonths": "Total Months",
      "weeklySaving": "Weekly Saving (₹)",
      "fourthWeekSaving": "4th Week Saving (₹)",
      "calculateSavings": "Calculate Savings",
      "totalSavings": "Total Savings",
      "monthlySavings": "Monthly Savings",
      "yearlySavings": "Yearly Savings",
      "totalCollection": "Total Collection",
      "groupFund": "Group Fund",
      "loanInterest": "Loan & Interest",
      "loanAmount": "Loan Amount (₹)",
      "loanMonths": "Duration (Months)",
      "paymentDelayed": "Payment delayed 3 months?",
      "calculateInterest": "Calculate Interest",
      "totalInterest": "Total Interest",
      "totalPayable": "Total Payable",
      "monthlyEMI": "Monthly EMI",
      "activeLoan": "Active Loan",
      "interestEarned": "Interest Earned",
      "meetingPenalty": "Meeting Penalty",
      "absentMembers": "Absent Members",
      "presentMembers": "Present Members",
      "finePerMember": "Fine Per Member (₹)",
      "calculateFine": "Calculate Fine",
      "totalFine": "Total Fine",
      "bankLoanSystem": "Bank Loan System",
      "bankLoanAmount": "Bank Loan Amount (₹)",
      "loanDuration": "Loan Duration (Months)",
      "calculateBankLoan": "Calculate Bank Loan",
      "bankInterest": "Bank Interest",
      "totalBankPayable": "Total Bank Payable",
      "shareReport": "Share Report",
      "copyReport": "Copy Report",
      "savedToHistory": "Saved to history",
      "members": "Members",
      "savingsLabel": "Savings",
      "fineLabel": "Fine",
      "loanLabel": "Loan",
      "interestLabel": "Interest",
      "fundLabel": "Fund",
    },
  };

  String getText(String key) {
    String lang = isHindi ? "Hindi" : "English";
    return _translations[lang]?[key] ?? key;
  }

  // =====================================================
  // INIT
  // =====================================================

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    membersController.dispose();
    monthsController.dispose();
    weeklySavingController.dispose();
    fourthWeekController.dispose();
    loanController.dispose();
    loanMonthsController.dispose();
    fineController.dispose();
    absentController.dispose();
    presentController.dispose();
    super.dispose();
  }

  // =====================================================
  // CALCULATE SAVINGS
  // =====================================================

  void calculateSavings() {
    int members = int.tryParse(membersController.text) ?? 0;
    int months = int.tryParse(monthsController.text) ?? 0;
    double weekly = double.tryParse(weeklySavingController.text) ?? 10;
    double fourthWeek = double.tryParse(fourthWeekController.text) ?? 20;

    double monthlySaving = (weekly * 3) + fourthWeek;
    totalSavings = members * monthlySaving * months;
    monthlySavings = members * monthlySaving;
    yearlySavings = totalSavings;
    totalCollection = totalSavings + totalFine;
    groupFund = totalCollection + interestEarned;

    setState(() {});
    HapticFeedback.mediumImpact();
    _saveToHistory("Savings", "₹${totalSavings.toStringAsFixed(2)}");
  }

  // =====================================================
  // CALCULATE LOAN
  // =====================================================

  void calculateLoan() {
    double principal = double.tryParse(loanController.text) ?? 0;
    int months = int.tryParse(loanMonthsController.text) ?? 0;
    double rate = (latePayment && months >= 3) ? 0.02 : 0.01;

    interest = principal * rate * months;
    totalPayable = principal + interest;
    monthlyEMI = totalPayable / months;
    activeLoan = principal;
    interestEarned = interest;

    setState(() {});
    HapticFeedback.mediumImpact();
    _saveToHistory("Loan", "₹${totalPayable.toStringAsFixed(2)}");
  }

  // =====================================================
  // CALCULATE FINE
  // =====================================================

  void calculateFine() {
    int absent = int.tryParse(absentController.text) ?? 0;
    double fine = double.tryParse(fineController.text) ?? 5;
    int present = int.tryParse(presentController.text) ?? 0;

    totalFine = absent * fine;
    totalAbsent = absent;
    totalPresent = present;
    totalCollection = totalSavings + totalFine;
    groupFund = totalCollection + interestEarned;

    setState(() {});
    HapticFeedback.mediumImpact();
    _saveToHistory("Fine", "₹${totalFine.toStringAsFixed(2)}");
  }

  // =====================================================
  // CALCULATE BANK LOAN
  // =====================================================

  void calculateBankLoan() {
    double principal = double.tryParse(loanController.text) ?? 0;
    int months = int.tryParse(loanMonthsController.text) ?? 0;
    double rate = 0.015;

    bankLoanInterest = principal * rate * months;
    bankLoanPayable = principal + bankLoanInterest;

    setState(() {});
    HapticFeedback.mediumImpact();
    _saveToHistory("Bank Loan", "₹${bankLoanPayable.toStringAsFixed(2)}");
  }

  // =====================================================
  // UPDATE DASHBOARD
  // =====================================================

  void updateDashboard() {
    totalMembers = int.tryParse(membersController.text) ?? 0;
    totalSavingsAll = totalSavings;
    totalFineAll = totalFine;
    activeLoanAll = activeLoan;
    interestEarnedAll = interestEarned;
    groupFundAll = groupFund;

    setState(() {});
  }

  // =====================================================
  // SAVE TO HISTORY
  // =====================================================

  Future<void> _saveToHistory(String type, String result) async {
    await HistoryService.addToHistory(
      expression: "$type Calculation",
      result: result,
      calculatorType: "SHG",
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(getText("savedToHistory")), duration: const Duration(seconds: 1)),
    );
  }

  // =====================================================
  // SHARE REPORT
  // =====================================================

  Future<void> _shareReport() async {
    try {
      setState(() => _isLoading = true);

      final RenderRepaintBoundary boundary = _dashboardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final Directory directory = await getTemporaryDirectory();
      final File imagePath = await File('${directory.path}/shg_report.png').create();
      await imagePath.writeAsBytes(pngBytes);

      final String shareText = """
Jeevika SHG Report
==================
${getText("totalMembers")}: ${totalMembers > 0 ? totalMembers : "N/A"}
${getText("totalSavings")}: ₹${totalSavingsAll.toStringAsFixed(2)}
${getText("totalFine")}: ₹${totalFineAll.toStringAsFixed(2)}
${getText("activeLoan")}: ₹${activeLoanAll.toStringAsFixed(2)}
${getText("interestEarned")}: ₹${interestEarnedAll.toStringAsFixed(2)}
${getText("groupFund")}: ₹${groupFundAll.toStringAsFixed(2)}
==================
${getText("shareReport")}
      """;

      await Share.shareXFiles([XFile(imagePath.path)], text: shareText);
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      _copyReport();
    }
  }

  void _copyReport() {
    String report = """
Jeevika SHG Report
==================
${getText("totalMembers")}: ${totalMembers > 0 ? totalMembers : "N/A"}
${getText("totalSavings")}: ₹${totalSavingsAll.toStringAsFixed(2)}
${getText("totalFine")}: ₹${totalFineAll.toStringAsFixed(2)}
${getText("activeLoan")}: ₹${activeLoanAll.toStringAsFixed(2)}
${getText("interestEarned")}: ₹${interestEarnedAll.toStringAsFixed(2)}
${getText("groupFund")}: ₹${groupFundAll.toStringAsFixed(2)}
    """;
    Clipboard.setData(ClipboardData(text: report));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Report copied!"), duration: Duration(seconds: 1)),
    );
  }

  // =====================================================
  // RESULT CARD
  // =====================================================

  Widget resultCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withOpacity(.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(.15),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 4),
                Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 24)),
              ],
            ),
          )
        ],
      ),
    );
  }

  // =====================================================
  // INPUT FIELD
  // =====================================================

  Widget inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // =====================================================
  // DASHBOARD CARD
  // =====================================================

  Widget _buildDashboardCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withOpacity(0.1), color.withOpacity(0.05)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  // =====================================================
  // BUILD DASHBOARD TAB
  // =====================================================

  Widget buildDashboardTab() {
    updateDashboard();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: RepaintBoundary(
        key: _dashboardKey,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                children: [
                  Text(getText("dashboard"), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                  const SizedBox(height: 20),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.2,
                    children: [
                      _buildDashboardCard(getText("members"), totalMembers.toString(), Icons.groups, Colors.blue),
                      _buildDashboardCard(getText("savingsLabel"), "₹${totalSavingsAll.toStringAsFixed(0)}", Icons.savings, Colors.green),
                      _buildDashboardCard(getText("fineLabel"), "₹${totalFineAll.toStringAsFixed(0)}", Icons.warning, Colors.red),
                      _buildDashboardCard(getText("loanLabel"), "₹${activeLoanAll.toStringAsFixed(0)}", Icons.account_balance, Colors.orange),
                      _buildDashboardCard(getText("interestLabel"), "₹${interestEarnedAll.toStringAsFixed(0)}", Icons.trending_up, Colors.purple),
                      _buildDashboardCard(getText("fundLabel"), "₹${groupFundAll.toStringAsFixed(0)}", Icons.account_balance_wallet, Colors.teal),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _shareReport,
                      icon: const Icon(Icons.share),
                      label: Text(getText("shareReport")),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // BUILD SAVINGS TAB
  // =====================================================

  Widget buildSavingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                Text(getText("groupSavingSystem"), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                const SizedBox(height: 20),
                inputField(controller: membersController, label: getText("totalMembers"), icon: Icons.groups),
                inputField(controller: monthsController, label: getText("totalMonths"), icon: Icons.calendar_month),
                inputField(controller: weeklySavingController, label: getText("weeklySaving"), icon: Icons.currency_rupee),
                inputField(controller: fourthWeekController, label: getText("fourthWeekSaving"), icon: Icons.savings),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: calculateSavings,
                    icon: const Icon(Icons.calculate),
                    label: Text(getText("calculateSavings")),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                  ),
                )
              ],
            ),
          ),
          if (totalCollection > 0) ...[
            resultCard(title: getText("totalSavings"), value: "₹${totalSavings.toStringAsFixed(0)}", color: Colors.green, icon: Icons.savings),
            resultCard(title: getText("monthlySavings"), value: "₹${monthlySavings.toStringAsFixed(0)}", color: Colors.blue, icon: Icons.calendar_month),
            resultCard(title: getText("yearlySavings"), value: "₹${yearlySavings.toStringAsFixed(0)}", color: Colors.purple, icon: Icons.calendar_today),
            resultCard(title: getText("totalCollection"), value: "₹${totalCollection.toStringAsFixed(0)}", color: Colors.indigo, icon: Icons.account_balance_wallet),
            resultCard(title: getText("groupFund"), value: "₹${groupFund.toStringAsFixed(0)}", color: Colors.teal, icon: Icons.account_balance),
          ]
        ],
      ),
    );
  }

  // =====================================================
  // BUILD LOAN TAB
  // =====================================================

  Widget buildLoanTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                Text(getText("loanInterest"), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                const SizedBox(height: 20),
                inputField(controller: loanController, label: getText("loanAmount"), icon: Icons.currency_rupee),
                inputField(controller: loanMonthsController, label: getText("loanMonths"), icon: Icons.calendar_month),
                SwitchListTile(
                  value: latePayment,
                  onChanged: (val) => setState(() => latePayment = val),
                  title: Text(getText("paymentDelayed")),
                  activeColor: Colors.red,
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: calculateLoan,
                    icon: const Icon(Icons.calculate),
                    label: Text(getText("calculateInterest")),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                  ),
                )
              ],
            ),
          ),
          if (totalPayable > 0) ...[
            resultCard(title: getText("totalInterest"), value: "₹${interest.toStringAsFixed(2)}", color: Colors.red, icon: Icons.trending_up),
            resultCard(title: getText("totalPayable"), value: "₹${totalPayable.toStringAsFixed(2)}", color: Colors.green, icon: Icons.payments),
            resultCard(title: getText("monthlyEMI"), value: "₹${monthlyEMI.toStringAsFixed(2)}", color: Colors.indigo, icon: Icons.calendar_today),
            resultCard(title: getText("activeLoan"), value: "₹${activeLoan.toStringAsFixed(2)}", color: Colors.orange, icon: Icons.account_balance),
            resultCard(title: getText("interestEarned"), value: "₹${interestEarned.toStringAsFixed(2)}", color: Colors.purple, icon: Icons.trending_up),
          ]
        ],
      ),
    );
  }

  // =====================================================
  // BUILD PENALTY TAB
  // =====================================================

  Widget buildPenaltyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                Text(getText("meetingPenalty"), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                const SizedBox(height: 20),
                inputField(controller: absentController, label: getText("absentMembers"), icon: Icons.person_off),
                inputField(controller: presentController, label: getText("presentMembers"), icon: Icons.person),
                inputField(controller: fineController, label: getText("finePerMember"), icon: Icons.warning),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: calculateFine,
                    icon: const Icon(Icons.calculate),
                    label: Text(getText("calculateFine")),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                  ),
                )
              ],
            ),
          ),
          if (totalFine > 0) ...[
            resultCard(title: getText("totalFine"), value: "₹${totalFine.toStringAsFixed(0)}", color: Colors.red, icon: Icons.warning),
            resultCard(title: getText("totalCollection"), value: "₹${totalCollection.toStringAsFixed(0)}", color: Colors.indigo, icon: Icons.account_balance_wallet),
          ]
        ],
      ),
    );
  }

  // =====================================================
  // BUILD BANK LOAN TAB
  // =====================================================

  Widget buildBankLoanTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                Text(getText("bankLoanSystem"), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                const SizedBox(height: 20),
                inputField(controller: loanController, label: getText("bankLoanAmount"), icon: Icons.account_balance),
                inputField(controller: loanMonthsController, label: getText("loanDuration"), icon: Icons.calendar_month),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: calculateBankLoan,
                    icon: const Icon(Icons.calculate),
                    label: Text(getText("calculateBankLoan")),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                  ),
                )
              ],
            ),
          ),
          if (bankLoanPayable > 0) ...[
            resultCard(title: getText("bankInterest"), value: "₹${bankLoanInterest.toStringAsFixed(2)}", color: Colors.orange, icon: Icons.trending_up),
            resultCard(title: getText("totalBankPayable"), value: "₹${bankLoanPayable.toStringAsFixed(2)}", color: Colors.indigo, icon: Icons.account_balance_wallet),
          ]
        ],
      ),
    );
  }

  // =====================================================
  // UI
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xffeef5f0),
      appBar: AppBar(
        backgroundColor: const Color(0xff0f3d63),
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.groups_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Text(getText("appTitle"), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => setState(() => isHindi = !isHindi),
            icon: const Icon(Icons.language, color: Colors.white),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(icon: const Icon(Icons.dashboard), text: getText("dashboard")),
            Tab(icon: const Icon(Icons.savings), text: getText("savings")),
            Tab(icon: const Icon(Icons.currency_rupee), text: getText("loan")),
            Tab(icon: const Icon(Icons.warning), text: getText("penalty")),
            Tab(icon: const Icon(Icons.account_balance), text: getText("bankLoan")),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildDashboardTab(),
          buildSavingsTab(),
          buildLoanTab(),
          buildPenaltyTab(),
          buildBankLoanTab(),
        ],
      ),
    );
  }
}