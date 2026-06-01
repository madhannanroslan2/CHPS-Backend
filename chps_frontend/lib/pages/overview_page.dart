import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../api_client.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key, required this.api});
  final ApiClient api;

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> with TickerProviderStateMixin {
  Map<String, dynamic>? _stats;
  bool _loading = true;
  String? _error;
  late AnimationController _counterCtrl;
  late Animation<double> _counterAnim;

  @override
  void initState() {
    super.initState();
    _counterCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _counterAnim = CurvedAnimation(parent: _counterCtrl, curve: Curves.easeOutCubic);
    _load();
  }

  @override
  void dispose() {
    _counterCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await widget.api.get('/reports/dashboard-stats');
      setState(() => _stats = Map<String, dynamic>.from(data));
      _counterCtrl.forward(from: 0);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth < 900;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }

    final stats = _stats ?? {};
    final cardData = [
      _StatCardData(
        label: 'Households',
        value: (stats['total_households'] ?? 0) as num,
        icon: Icons.home_work_rounded,
        gradientColors: const [Color(0xFF10B981), Color(0xFF059669)],
        growth: '+12%',
        growthUp: true,
      ),
      _StatCardData(
        label: 'Residents',
        value: (stats['total_residents'] ?? 0) as num,
        icon: Icons.people_alt_rounded,
        gradientColors: const [Color(0xFF3B82F6), Color(0xFF2563EB)],
        growth: '+8%',
        growthUp: true,
      ),
      _StatCardData(
        label: 'Immunizations',
        value: (stats['total_immunizations'] ?? 0) as num,
        icon: Icons.vaccines_rounded,
        gradientColors: const [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
        growth: '+23%',
        growthUp: true,
      ),
      _StatCardData(
        label: 'Medical History',
        value: (stats['total_medical_histories'] ?? 0) as num,
        icon: Icons.medical_information_rounded,
        gradientColors: const [Color(0xFFEC4899), Color(0xFFDB2777)],
        growth: '+5%',
        growthUp: true,
      ),
      _StatCardData(
        label: 'Reports',
        value: (stats['total_reports'] ?? 0) as num,
        icon: Icons.summarize_rounded,
        gradientColors: const [Color(0xFFF97316), Color(0xFFEA580C)],
        growth: '+18%',
        growthUp: true,
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHero(context),
          const SizedBox(height: 28),
          _buildStatCards(context, cardData, isTablet),
          const SizedBox(height: 28),
          _buildAnalyticsSection(context),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back,',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Healthcare Dashboard',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Monitor and manage your community health data at a glance.',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCards(BuildContext context, List<_StatCardData> cards, bool isTablet) {
    if (isTablet) {
      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: cards.map((card) => SizedBox(
          width: (MediaQuery.sizeOf(context).width - 24 - 24 - 16) / 2,
          child: _StatCard(data: card, anim: _counterAnim),
        )).toList(),
      );
    }
    return Row(
      children: cards.map((card) {
        final i = cards.indexOf(card);
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: i == 0 ? 0 : 16),
            child: _StatCard(data: card, anim: _counterAnim),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAnalyticsSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Analytics Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      size: 14,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'This Month',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 260,
            child: _buildBarChart(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barColors = [
      const Color(0xFF14B8A6),
      const Color(0xFF3B82F6),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFFF97316),
    ];
    final categories = ['Households', 'Residents', 'Immunizations', 'Med History', 'Reports'];
    final stats = _stats ?? {};
    final values = [
      (stats['total_households'] ?? 0).toDouble(),
      (stats['total_residents'] ?? 0).toDouble(),
      (stats['total_immunizations'] ?? 0).toDouble(),
      (stats['total_medical_histories'] ?? 0).toDouble(),
      (stats['total_reports'] ?? 0).toDouble(),
    ];
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final ceiling = maxVal <= 0 ? 100.0 : ((maxVal / 10).ceil() * 10).toDouble();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: ceiling,
        minY: 0,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${categories[group.x.toInt()]}\n${rod.toY.toInt()}',
                TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= categories.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    categories[idx],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: ceiling / 4,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(values.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: values[i],
                color: barColors[i],
                width: 32,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _StatCardData {
  final String label;
  final num value;
  final IconData icon;
  final List<Color> gradientColors;
  final String growth;
  final bool growthUp;

  const _StatCardData({
    required this.label,
    required this.value,
    required this.icon,
    required this.gradientColors,
    required this.growth,
    required this.growthUp,
  });
}

class _StatCard extends StatelessWidget {
  final _StatCardData data;
  final Animation<double> anim;

  const _StatCard({required this.data, required this.anim});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayValue = AnimatedBuilder(
      animation: anim,
      builder: (context, child) {
        final animatedVal = (data.value * anim.value).toInt();
        return Text(
          _formatNumber(animatedVal),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        );
      },
    );

    return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.95, end: 1.0),
        duration: const Duration(milliseconds: 200),
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.02),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: data.gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: data.gradientColors[0].withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(data.icon, color: Colors.white, size: 20),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: data.growthUp
                          ? const Color(0xFF10B981).withValues(alpha: 0.1)
                          : const Color(0xFFEF4444).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          data.growthUp ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                          size: 12,
                          color: data.growthUp ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          data.growth,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: data.growthUp ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              displayValue,
              const SizedBox(height: 4),
              Text(
                data.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return n.toString();
  }
}
