import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:we_spilit/core/constants/app_colors.dart';
import 'package:we_spilit/provider/admin_provider.dart';

class AdminAnalyticsScreen extends StatelessWidget {
  const AdminAnalyticsScreen({super.key});

  // Colour palette for pie slices
  static const _pieColors = [
    Color(0xFF7B1FA2),
    Color(0xFFE91E63),
    AppColors.accent,
    AppColors.success,
    AppColors.warning,
    Color(0xFF5C6BC0),
  ];

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();
    final catMap = adminProvider.categoryDistribution;
    final monthMap = adminProvider.usersPerMonth;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: const Color(0xFF7B1FA2),
            title: Text('Analytics',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700, color: Colors.white)),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Pie Chart — Category Distribution ─────────────────
                _sectionTitle(context, 'User Categories'),
                const SizedBox(height: 12),
                Container(
                  height: 300,
                  padding: const EdgeInsets.all(20),
                  decoration: _cardDeco(context),
                  child: catMap.isEmpty
                      ? _emptyState(context, 'No category data yet')
                      : Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: PieChart(
                                PieChartData(
                                  sectionsSpace: 3,
                                  centerSpaceRadius: 48,
                                  sections: catMap.entries
                                      .toList()
                                      .asMap()
                                      .entries
                                      .map((e) {
                                    final idx = e.key % _pieColors.length;
                                    final entry = e.value;
                                    final pct = adminProvider.totalUsers > 0
                                        ? entry.value /
                                            adminProvider.totalUsers *
                                            100
                                        : 0.0;
                                    return PieChartSectionData(
                                      color: _pieColors[idx],
                                      value: entry.value.toDouble(),
                                      title: '${pct.toStringAsFixed(0)}%',
                                      radius: 60,
                                      titleStyle: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: catMap.entries
                                    .toList()
                                    .asMap()
                                    .entries
                                    .map((e) {
                                  final idx = e.key % _pieColors.length;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: _pieColors[idx],
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            '${e.value.key} (${e.value.value})',
                                            style: GoogleFonts.inter(
                                                fontSize: 12),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                ),

                const SizedBox(height: 24),

                // ── Bar Chart — Users Per Month ────────────────────────
                _sectionTitle(context, 'New Users (Last 6 Months)'),
                const SizedBox(height: 12),
                Container(
                  height: 260,
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                  decoration: _cardDeco(context),
                  child: monthMap.isEmpty
                      ? _emptyState(context, 'No monthly data yet')
                      : BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: (monthMap.values.reduce(
                                        (a, b) => a > b ? a : b)
                                    .toDouble() +
                                2),
                            barTouchData:
                                BarTouchData(enabled: false),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 28,
                                  getTitlesWidget: (v, _) => Text(
                                    v.toInt().toString(),
                                    style: GoogleFonts.inter(fontSize: 10),
                                  ),
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (v, _) {
                                    final keys =
                                        monthMap.keys.toList();
                                    final idx = v.toInt();
                                    if (idx < 0 || idx >= keys.length) {
                                      return const SizedBox.shrink();
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        keys[idx],
                                        style:
                                            GoogleFonts.inter(fontSize: 9),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              topTitles: const AxisTitles(
                                  sideTitles:
                                      SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(
                                  sideTitles:
                                      SideTitles(showTitles: false)),
                            ),
                            gridData: FlGridData(
                              horizontalInterval: 1,
                              getDrawingHorizontalLine: (v) => FlLine(
                                color: Theme.of(context)
                                    .dividerColor
                                    .withOpacity(0.5),
                                strokeWidth: 1,
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups: monthMap.entries
                                .toList()
                                .asMap()
                                .entries
                                .map((e) {
                              return BarChartGroupData(
                                x: e.key,
                                barRods: [
                                  BarChartRodData(
                                    toY: e.value.value.toDouble(),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF7B1FA2),
                                        Color(0xFFE91E63)
                                      ],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                    width: 22,
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(6)),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                ),

                const SizedBox(height: 24),

                // ── Stats summary ──────────────────────────────────────
                _sectionTitle(context, 'Summary'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: _cardDeco(context),
                  child: Column(
                    children: [
                      _statRow(context, 'Total Users',
                          '${adminProvider.totalUsers}'),
                      _divider(context),
                      _statRow(context, 'Active Users',
                          '${adminProvider.activeUsers}'),
                      _divider(context),
                      _statRow(
                          context,
                          'Inactive Users',
                          '${adminProvider.totalUsers - adminProvider.activeUsers}'),
                      _divider(context),
                      _statRow(
                          context,
                          'Unique Categories',
                          '${adminProvider.categoryDistribution.keys.length}'),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) =>
      Text(title,
          style: GoogleFonts.inter(
              fontSize: 16, fontWeight: FontWeight.w700));

  BoxDecoration _cardDeco(BuildContext context) => BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      );

  Widget _emptyState(BuildContext context, String msg) => Center(
        child: Text(msg,
            style: GoogleFonts.inter(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.4))),
      );

  Widget _statRow(BuildContext context, String label, String value) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: GoogleFonts.inter(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6))),
            Text(value,
                style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          ],
        ),
      );

  Widget _divider(BuildContext context) =>
      Divider(height: 1, color: Theme.of(context).dividerColor);
}
