// lib/screens/admin/admin_dashboard.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../services/database_service.dart';
import '../../widgets/common/screen_with_nav.dart';
import '../../models/user_model.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Map<String, dynamic> _stats = {};
  List<int> _monthly = List.filled(6, 0);
  List<UserModel> _recentUsers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      DatabaseService.getAdminStats(),
      DatabaseService.getMonthlyRegistrations(),
      DatabaseService.getAllUsers(),
    ]);
    if (!mounted) return;
    setState(() {
      _stats       = results[0] as Map<String, dynamic>;
      _monthly     = results[1] as List<int>;
      _recentUsers =
          (results[2] as List<UserModel>).take(5).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenWithNav(
      title: 'Admin Dashboard',
      currentRoute: '/admin',
      isAdmin: true,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 700;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Stats row ───────────────────────────────
                        _buildStatsRow(isWide),
                        const SizedBox(height: 24),

                        // ── Charts + Recent users ────────────────────
                        if (isWide)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 3, child: _buildLineChart()),
                              const SizedBox(width: 20),
                              Expanded(flex: 2, child: _buildPieChart()),
                            ],
                          )
                        else ...[
                          _buildLineChart(),
                          const SizedBox(height: 20),
                          _buildPieChart(),
                        ],
                        const SizedBox(height: 24),

                        // ── Recent users ────────────────────────────
                        _buildRecentUsers(),
                        const SizedBox(height: 24),

                        // ── Quick links ─────────────────────────────
                        _buildQuickLinks(context),
                      ],
                    );
                  },
                ),
              ),
            ),
    );
  }

  // ── Stats row ──────────────────────────────────────────────────────────────
  Widget _buildStatsRow(bool isWide) {
    final fmt = NumberFormat('#,##0');
    final cards = [
      _StatItem(
        label: 'Total Users',
        value: '${_stats['totalUsers'] ?? 0}',
        icon: Icons.people_outline,
        iconColor: AppColors.primary,
        bgColor: AppColors.primaryLight,
        onTap: () => Navigator.pushNamed(context, '/admin/users'),
      ),
      _StatItem(
        label: 'Active Users',
        value: '${_stats['activeUsers'] ?? 0}',
        icon: Icons.person_outline,
        iconColor: AppColors.success,
        bgColor: AppColors.success.withOpacity(0.12),
        onTap: () => Navigator.pushNamed(context, '/admin/users'),
      ),
      _StatItem(
        label: 'Cycle Entries',
        value: '${_stats['totalCycles'] ?? 0}',
        icon: Icons.calendar_month_outlined,
        iconColor: AppColors.pending,
        bgColor: AppColors.pending.withOpacity(0.12),
        onTap: null,
      ),
      _StatItem(
        label: 'Total Revenue',
        value: 'Le ${fmt.format(_stats['totalRevenue'] ?? 0)}',
        icon: Icons.payments_outlined,
        iconColor: AppColors.navy,
        bgColor: AppColors.navy.withOpacity(0.08),
        onTap: () => Navigator.pushNamed(context, '/admin/payments'),
      ),
    ];

    if (isWide) {
      return Row(
        children: cards
            .map((c) => Expanded(child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: c,
                )))
            .toList(),
      );
    }
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: cards,
    );
  }

  // ── Line chart ─────────────────────────────────────────────────────────────
  Widget _buildLineChart() {
    final monthLabels = _last6MonthLabels();
    final spots = List.generate(
      6,
      (i) => FlSpot(i.toDouble(), _monthly[i].toDouble()),
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E7EA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('User Registrations (last 6 months)',
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) =>
                      const FlLine(color: Color(0xFFE0E7EA), strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (v, m) => Text(
                        v.toInt().toString(),
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (v, m) {
                        final i = v.toInt();
                        if (i < 0 || i >= 6) return const SizedBox();
                        return Text(monthLabels[i],
                            style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary));
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withOpacity(0.08),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Pie chart ──────────────────────────────────────────────────────────────
  Widget _buildPieChart() {
    final pending   = (_stats['pendingOrders']   ?? 0) as int;
    final confirmed = (_stats['confirmedOrders'] ?? 0) as int;
    final cancelled = (_stats['cancelledOrders'] ?? 0) as int;
    final total     = (_stats['totalOrders']     ?? 0) as int;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E7EA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Orders Overview',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: total == 0
                ? const Center(
                    child: Text('No orders yet',
                        style: TextStyle(color: AppColors.textSecondary)))
                : PieChart(
                    PieChartData(
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                      sections: [
                        if (confirmed > 0)
                          PieChartSectionData(
                            value: confirmed.toDouble(),
                            color: AppColors.success,
                            radius: 55,
                            title: '$confirmed',
                            titleStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600),
                          ),
                        if (pending > 0)
                          PieChartSectionData(
                            value: pending.toDouble(),
                            color: AppColors.pending,
                            radius: 55,
                            title: '$pending',
                            titleStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600),
                          ),
                        if (cancelled > 0)
                          PieChartSectionData(
                            value: cancelled.toDouble(),
                            color: AppColors.error,
                            radius: 55,
                            title: '$cancelled',
                            titleStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600),
                          ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          _legend(AppColors.success, 'Confirmed', confirmed),
          const SizedBox(height: 4),
          _legend(AppColors.pending, 'Pending', pending),
          const SizedBox(height: 4),
          _legend(AppColors.error, 'Cancelled', cancelled),
        ],
      ),
    );
  }

  Widget _legend(Color color, String label, int count) {
    return Row(
      children: [
        Container(
            width: 10, height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
        const Spacer(),
        Text('$count',
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  // ── Recent users ───────────────────────────────────────────────────────────
  Widget _buildRecentUsers() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E7EA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                const Text('Recent Users',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.textPrimary)),
                const Spacer(),
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/admin/users'),
                  child: const Text('View all'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (_recentUsers.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text('No users yet.',
                  style: TextStyle(color: AppColors.textSecondary)),
            )
          else
            ...List.generate(_recentUsers.length, (i) {
              final u = _recentUsers[i];
              return Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary,
                      radius: 18,
                      child: Text(
                        u.displayName.isNotEmpty
                            ? u.displayName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(u.displayName),
                    subtitle: Text(u.email),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: u.isActive
                            ? AppColors.success.withOpacity(0.12)
                            : AppColors.inactive.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        u.isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: u.isActive
                                ? AppColors.success
                                : AppColors.inactive),
                      ),
                    ),
                    onTap: () => Navigator.pushNamed(
                        context, '/admin/user-detail',
                        arguments: u.id),
                  ),
                  if (i < _recentUsers.length - 1)
                    const Divider(height: 1, indent: 56),
                ],
              );
            }),
        ],
      ),
    );
  }

  // ── Quick links ────────────────────────────────────────────────────────────
  Widget _buildQuickLinks(BuildContext context) {
    final links = [
      _Link('Manage Users', Icons.people_outline, '/admin/users'),
      _Link('Manage Orders', Icons.receipt_long_outlined, '/admin/payments'),
      _Link('Manage Content', Icons.article_outlined, '/admin/content'),
    ];
    return Column(
      children: links
          .map((l) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: Icon(l.icon, color: AppColors.primary),
                  title: Text(l.label),
                  trailing: const Icon(Icons.chevron_right,
                      color: AppColors.textSecondary),
                  onTap: () => Navigator.pushNamed(context, l.route),
                ),
              ))
          .toList(),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  List<String> _last6MonthLabels() {
    final now    = DateTime.now();
    final months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    return List.generate(6, (i) {
      final m = DateTime(now.year, now.month - 5 + i);
      return months[m.month - 1];
    });
  }
}

// ── Small helpers ─────────────────────────────────────────────────────────────
class _StatItem extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color iconColor, bgColor;
  final VoidCallback? onTap;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0E7EA)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: bgColor, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(height: 10),
            Text(value,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _Link {
  final String label, route;
  final IconData icon;
  const _Link(this.label, this.icon, this.route);
}