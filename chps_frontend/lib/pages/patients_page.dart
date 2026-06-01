import 'package:flutter/material.dart';
import '../api_client.dart';

class PatientsPage extends StatefulWidget {
  final ApiClient api;
  const PatientsPage({super.key, required this.api});

  @override
  State<PatientsPage> createState() => _PatientsPageState();
}

class _PatientsPageState extends State<PatientsPage> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.api.list('/patients');
  }

  Future<void> _refresh() {
    setState(() => _future = widget.api.list('/patients'));
    return _future;
  }

  void _showDetails(Map<String, dynamic> patient) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    final textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 64, vertical: 40),
        contentPadding: EdgeInsets.zero,
        titlePadding: EdgeInsets.zero,
        buttonPadding: EdgeInsets.zero,
        content: Container(
          width: 520,
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.85),
          decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailHeader(patient, isDark, ctx),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      _detailSection('Personal Information', [
                        _detailRow('Full Name', '${patient['first_name'] ?? '-'} ${patient['last_name'] ?? '-'}'),
                        _detailRow('Gender', patient['gender']?.toString() ?? '-'),
                        _detailRow('Birth Date', patient['birth_date']?.toString() ?? '-'),
                        _detailRow('Age', patient['age']?.toString() ?? '-'),
                        _detailRow('Contact #', patient['contact_number']?.toString() ?? '-'),
                      ], textColor, textMuted, borderColor, isDark),
                      const SizedBox(height: 20),
                      _detailSection('Household Information', [
                        _detailRow('Household ID', patient['household_id']?.toString() ?? '-'),
                        _detailRow('Household #', patient['household_number']?.toString() ?? '-'),
                        _detailRow('Purok', patient['purok']?.toString() ?? '-'),
                        _detailRow('Head of Family', patient['head_of_family']?.toString() ?? '-'),
                      ], textColor, textMuted, borderColor, isDark),
                      const SizedBox(height: 20),
                      _detailSection('Immunizations', [
                        ..._buildImmunizationList(patient, textColor, textMuted, borderColor, isDark),
                      ], textColor, textMuted, borderColor, isDark),
                      const SizedBox(height: 20),
                      _detailSection('Medical History', [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(patient['medical_summary']?.toString() ?? 'None', style: TextStyle(fontSize: 14, color: textColor)),
                        ),
                      ], textColor, textMuted, borderColor, isDark),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailHeader(Map<String, dynamic> patient, bool isDark, BuildContext ctx) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0F766E), Color(0xFF10B981)], begin: Alignment.centerLeft, end: Alignment.centerRight),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: Text(
              '${(patient['first_name']?.toString() ?? '?')[0].toUpperCase()}${(patient['last_name']?.toString() ?? '?')[0].toUpperCase()}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${patient['first_name'] ?? '-'} ${patient['last_name'] ?? '-'}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.3),
                ),
                const SizedBox(height: 2),
                Text(
                  'Patient #${patient['id']}',
                  style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8)),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildImmunizationList(Map<String, dynamic> patient, Color textColor, Color textMuted, Color borderColor, bool isDark) {
    final immunizations = patient['immunizations'] as List<dynamic>? ?? [];
    if (immunizations.isEmpty) {
      return [
        Text('None', style: TextStyle(fontSize: 14, color: textColor)),
      ];
    }
    return immunizations.asMap().entries.map((entry) {
      final i = entry.value as Map<String, dynamic>;
      final idx = entry.key;
      return Padding(
        padding: EdgeInsets.only(bottom: idx < immunizations.length - 1 ? 10 : 0),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.vaccines_outlined, size: 16, color: const Color(0xFF0F766E)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      i['vaccine_name']?.toString() ?? '-',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _detailSmallRow('Dose', 'Dose ${i['dose_number'] ?? '-'}', textMuted),
              const SizedBox(height: 4),
              _detailSmallRow('Administered By', i['administered_by']?.toString() ?? '-', textMuted),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _detailSmallRow(String label, String value, Color textMuted) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(label, style: TextStyle(fontSize: 12, color: textMuted)),
        ),
        Expanded(
          child: Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textMuted)),
        ),
      ],
    );
  }

  Widget _detailSection(String title, List<Widget> rows, Color textColor, Color textMuted, Color borderColor, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF0F766E), letterSpacing: 0.3)),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows),
        ),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyle(fontSize: 13, color: const Color(0xFF64748B))),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF111827))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    final textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return FutureBuilder<List<dynamic>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snapshot.data ?? [];

        return Container(
          color: bgColor,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                decoration: BoxDecoration(color: cardColor, border: Border(bottom: BorderSide(color: borderColor))),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Patients',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.3, color: textColor),
                          ),
                          const SizedBox(height: 2),
                          Text('${items.length} total — click a name to view details', style: TextStyle(fontSize: 13, color: textMuted)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, size: 20),
                      color: textMuted,
                      onPressed: _refresh,
                      tooltip: 'Refresh',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.people_outline_rounded, size: 48, color: textMuted),
                            const SizedBox(height: 12),
                            Text('No patients found', style: TextStyle(fontSize: 16, color: textMuted)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => SizedBox(height: isDark ? 6 : 4),
                        itemBuilder: (context, i) {
                          final patient = items[i] as Map<String, dynamic>;
                          final name = '${patient['first_name'] ?? '-'} ${patient['last_name'] ?? '-'}';
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                final fresh = await widget.api.get('/patients/${patient['id']}');
                                if (!mounted) return;
                                _showDetails(fresh);
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: borderColor),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.03),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: const Color(0xFF0F766E).withValues(alpha: 0.1),
                                      child: Text(
                                        name[0].toUpperCase(),
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F766E)),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textColor)),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Patient #${patient['id']}',
                                            style: TextStyle(fontSize: 12, color: textMuted),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0F766E).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        patient['gender']?.toString() ?? '-',
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF0F766E)),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(Icons.chevron_right_rounded, size: 20, color: textMuted),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
