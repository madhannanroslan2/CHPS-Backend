import 'package:flutter/material.dart';
import '../api_client.dart';
import '../models.dart';

class ResourceTablePage extends StatefulWidget {
  final ApiClient api;
  final ResourceDef resource;

  const ResourceTablePage({super.key, required this.api, required this.resource});

  @override
  State<ResourceTablePage> createState() => _ResourceTablePageState();
}

class _ResourceTablePageState extends State<ResourceTablePage> {
  late Future<List<dynamic>> _future;
  final _formData = <String, dynamic>{};
  
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _future = widget.api.list(widget.resource.path);
  }

  Future<void> _refresh() async {
    setState(() => _future = widget.api.list(widget.resource.path));
  }

  Future<void> _createOrUpdate([Map<String, dynamic>? item]) async {
    _formData.clear();
    if (item != null) {
      _formData.addAll(item);
    }
    final title = widget.resource.title;
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) {
        if (title == 'Residents') return _buildResidentForm(item);
        if (title == 'Reports') return _buildReportForm(item);
        return _buildModernForm(item);
      },
    );
    if (saved != true) return;
    try {
      final id = item?['id'] as int?;
      await widget.api.save(widget.resource.path, _formData, id);
      _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  static const _resourceIcons = <String, IconData>{
    'households': Icons.home_work_outlined,
    'residents': Icons.people_alt_outlined,
    'immunizations': Icons.vaccines_outlined,
    'medical history': Icons.medical_information_outlined,
    'reports': Icons.summarize_rounded,
  };

  static const _fieldIcons = <String, IconData>{
    'household_id': Icons.groups_outlined,
    'household_number': Icons.tag_rounded,
    'purok': Icons.location_on_outlined,
    'head_of_family': Icons.person_outline,
    'first_name': Icons.person_outline,
    'last_name': Icons.person_outline,
    'gender': Icons.wc_outlined,
    'birth_date': Icons.calendar_month_outlined,
    'age': Icons.badge_outlined,
    'contact_number': Icons.phone_outlined,
    'resident_id': Icons.assignment_ind_outlined,
    'vaccine_name': Icons.science_outlined,
    'dose_number': Icons.format_list_numbered_rounded,
    'administered_by': Icons.person_outline,
    'diagnosis': Icons.health_and_safety_outlined,
    'treatment': Icons.medical_services_outlined,
    'remarks': Icons.notes_rounded,
    'report_title': Icons.description_outlined,
    'description': Icons.article_outlined,
    'generated_by': Icons.person_outline,
  };

  Widget _buildResidentForm(Map<String, dynamic>? item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = MediaQuery.sizeOf(context).width < 600;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final maxH = MediaQuery.sizeOf(context).height * 0.8;
    final formKey = GlobalKey<FormState>();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: isMobile ? const EdgeInsets.all(16) : const EdgeInsets.symmetric(horizontal: 64, vertical: 40),
      contentPadding: EdgeInsets.zero,
      titlePadding: EdgeInsets.zero,
      buttonPadding: EdgeInsets.zero,
      content: Container(
        width: isMobile ? null : 520,
        constraints: BoxConstraints(maxWidth: 600, maxHeight: maxH),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildResidentHeader(item, isDark),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _residentField('household_id', isDark, isMobile ? null : const EdgeInsets.only(bottom: 16)),
                      if (isMobile) ...[
                        _residentField('first_name', isDark, const EdgeInsets.only(bottom: 16)),
                        _residentField('last_name', isDark, const EdgeInsets.only(bottom: 16)),
                        _residentField('gender', isDark, const EdgeInsets.only(bottom: 16)),
                        _residentField('birth_date', isDark, const EdgeInsets.only(bottom: 16)),
                        _residentField('age', isDark, const EdgeInsets.only(bottom: 16)),
                        _residentField('contact_number', isDark),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(child: _residentField('first_name', isDark, const EdgeInsets.only(right: 8, bottom: 16))),
                            Expanded(child: _residentField('last_name', isDark, const EdgeInsets.only(left: 8, bottom: 16))),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(child: _residentField('gender', isDark, const EdgeInsets.only(right: 8, bottom: 16))),
                            Expanded(child: _residentField('birth_date', isDark, const EdgeInsets.only(left: 8, bottom: 16))),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(child: _residentField('age', isDark, const EdgeInsets.only(right: 8, bottom: 16))),
                            Expanded(child: _residentField('contact_number', isDark, const EdgeInsets.only(left: 8, bottom: 16))),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              _buildFormActions(formKey, item, 'Resident', isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormActions(GlobalKey<FormState> formKey, Map<String, dynamic>? item, String title, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 20),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context, false),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              side: BorderSide(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB)),
              foregroundColor: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF6B7280),
            ),
            child: const Text('Cancel', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 10),
          Material(
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(context, true);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(colors: [Color(0xFF0F766E), Color(0xFF10B981)], begin: Alignment.centerLeft, end: Alignment.centerRight),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_outline, size: 16, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(item == null ? 'Add $title' : 'Save', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResidentHeader(Map<String, dynamic>? item, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF0F766E).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person_add_alt_1_rounded, color: Color(0xFF0F766E), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              item == null ? 'Add Resident' : 'Edit Resident',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: isDark ? Colors.white : const Color(0xFF111827),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 20),
            onPressed: () => Navigator.pop(context, false),
            style: IconButton.styleFrom(
              backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              minimumSize: const Size(32, 32),
              padding: EdgeInsets.zero,
              foregroundColor: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _residentField(String field, bool isDark, [EdgeInsets? margin]) {
    final value = _formData[field]?.toString() ?? '';
    final icon = _fieldIcons[field] ?? Icons.edit_outlined;
    final label = field.replaceAll('_', ' ').split(' ').map((s) => s[0].toUpperCase() + s.substring(1)).join(' ');

    if (field == 'gender') {
      return Padding(
        padding: margin ?? EdgeInsets.zero,
        child: DropdownButtonFormField<String>(
          initialValue: value.isEmpty ? null : value,
          decoration: _inputDecoration(icon, label, isDark),
          style: TextStyle(fontSize: 13, color: isDark ? Colors.white : const Color(0xFF111827)),
          dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          items: ['Male', 'Female', 'Other'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
          onChanged: (val) {
            if (val != null) _formData[field] = val;
          },
          validator: (val) => val == null || val.isEmpty ? 'Required' : null,
        ),
      );
    }

    if (field == 'birth_date') {
      final controller = TextEditingController(text: value);
      return Padding(
        padding: margin ?? EdgeInsets.zero,
        child: TextFormField(
          readOnly: true,
          controller: controller,
          decoration: _inputDecoration(icon, label, isDark).copyWith(
            hintText: 'MM / DD / YY',
            hintStyle: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF4B5563) : const Color(0xFF9CA3AF)),
          ),
          style: TextStyle(fontSize: 13, color: isDark ? Colors.white : const Color(0xFF111827)),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.tryParse(value) ?? DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              final formatted = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
              _formData[field] = formatted;
              controller.text = formatted;
            }
          },
          validator: (val) => val == null || val.isEmpty ? 'Required' : null,
        ),
      );
    }

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: TextFormField(
        initialValue: value,
        decoration: _inputDecoration(icon, label, isDark),
        style: TextStyle(fontSize: 13, color: isDark ? Colors.white : const Color(0xFF111827)),
        keyboardType: field == 'age' || field == 'household_id' ? TextInputType.number : TextInputType.text,
        onChanged: (val) => _formData[field] = val,
        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
      ),
    );
  }

  InputDecoration _inputDecoration(IconData icon, String label, bool isDark) {
    return InputDecoration(
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 12, right: 8),
        child: Icon(icon, size: 18, color: const Color(0xFF0F766E)),
      ),
      labelText: label,
      labelStyle: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0F766E), width: 1.5),
      ),
      filled: true,
      fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      isDense: true,
    );
  }

  Widget _buildReportForm(Map<String, dynamic>? item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = MediaQuery.sizeOf(context).width < 600;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final maxH = MediaQuery.sizeOf(context).height * 0.8;

    final formKey = GlobalKey<FormState>();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: isMobile ? const EdgeInsets.all(16) : const EdgeInsets.symmetric(horizontal: 64, vertical: 40),
      contentPadding: EdgeInsets.zero,
      titlePadding: EdgeInsets.zero,
      buttonPadding: EdgeInsets.zero,
      content: Container(
        width: isMobile ? null : 520,
        constraints: BoxConstraints(maxWidth: 600, maxHeight: maxH),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildModernHeader(item, 'Report', isDark),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                  child: Column(
                    children: [
                      if (isMobile) ...[
                        _reportField('report_title', isDark, const EdgeInsets.only(bottom: 16)),
                        _reportField('description', isDark, const EdgeInsets.only(bottom: 16)),
                        _reportField('generated_by', isDark),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(child: _reportField('report_title', isDark, const EdgeInsets.only(right: 8, bottom: 16))),
                            Expanded(child: _reportField('generated_by', isDark, const EdgeInsets.only(left: 8, bottom: 16))),
                          ],
                        ),
                        _reportField('description', isDark, const EdgeInsets.only(bottom: 0)),
                      ],
                    ],
                  ),
                ),
              ),
              _buildFormActions(formKey, item, 'Report', isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _reportField(String field, bool isDark, [EdgeInsets? margin]) {
    final value = _formData[field]?.toString() ?? '';
    final icon = _fieldIcons[field] ?? Icons.edit_outlined;
    final label = field.replaceAll('_', ' ').split(' ').map((s) => s[0].toUpperCase() + s.substring(1)).join(' ');

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: TextFormField(
        initialValue: value,
        maxLines: field == 'description' ? 3 : 1,
        decoration: _inputDecoration(icon, label, isDark),
        style: TextStyle(fontSize: 13, color: isDark ? Colors.white : const Color(0xFF111827)),
        onChanged: (val) => _formData[field] = val,
        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget _buildModernForm(Map<String, dynamic>? item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = MediaQuery.sizeOf(context).width < 600;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final maxH = MediaQuery.sizeOf(context).height * 0.8;
    final title = widget.resource.title;

    final formKey = GlobalKey<FormState>();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: isMobile ? const EdgeInsets.all(16) : const EdgeInsets.symmetric(horizontal: 64, vertical: 40),
      contentPadding: EdgeInsets.zero,
      titlePadding: EdgeInsets.zero,
      buttonPadding: EdgeInsets.zero,
      content: Container(
        width: isMobile ? null : 480,
        constraints: BoxConstraints(maxWidth: 560, maxHeight: maxH),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildModernHeader(item, title, isDark),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                  child: Column(
                    children: widget.resource.columns.map((field) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildModernField(field, isDark),
                      );
                    }).toList(),
                  ),
                ),
              ),
              _buildFormActions(formKey, item, title, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader(Map<String, dynamic>? item, String title, bool isDark) {
    final icon = _resourceIcons[title.toLowerCase()] ?? Icons.edit_outlined;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF0F766E).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF0F766E), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              item == null ? 'Add $title' : 'Edit $title',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: isDark ? Colors.white : const Color(0xFF111827),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 20),
            onPressed: () => Navigator.pop(context, false),
            style: IconButton.styleFrom(
              backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              minimumSize: const Size(32, 32),
              padding: EdgeInsets.zero,
              foregroundColor: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernField(String field, bool isDark) {
    final value = _formData[field]?.toString() ?? '';
    final icon = _fieldIcons[field] ?? Icons.edit_outlined;
    final label = field.replaceAll('_', ' ').split(' ').map((s) => s[0].toUpperCase() + s.substring(1)).join(' ');

    return TextFormField(
      initialValue: value,
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 12, right: 8),
          child: Icon(icon, size: 18, color: const Color(0xFF0F766E)),
        ),
        labelText: label,
        labelStyle: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0F766E), width: 1.5),
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        isDense: true,
      ),
      style: TextStyle(fontSize: 13, color: isDark ? Colors.white : const Color(0xFF111827)),
      onChanged: (val) => _formData[field] = val,
      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
    );
  }

  Future<void> _delete(Map<String, dynamic> item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Delete'),
        content: Text('Delete ${widget.resource.title} #${item['id']}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await widget.api.delete(widget.resource.path, (item['id'] ?? 0) as int);
      _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final headerBg = isDark ? const Color(0xFF0F766E) : const Color(0xFF14B8A6);

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
                decoration: BoxDecoration(
                  color: cardColor,
                  border: Border(bottom: BorderSide(color: borderColor)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.resource.title,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${items.length} records',
                            style: TextStyle(fontSize: 13, color: textMuted),
                          ),
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () => _createOrUpdate(),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('New Record'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF14B8A6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      ),
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
                            Icon(Icons.inbox_rounded, size: 48, color: textMuted),
                            const SizedBox(height: 12),
                            Text('No ${widget.resource.title.toLowerCase()} found',
                                style: TextStyle(fontSize: 16, color: textMuted)),
                          ],
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          return Container(
                            margin: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderColor),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(left: 16, right: 8),
                                    color: headerBg,
                                    height: 44,
                                    child: Row(
                                      children: [
                                        SizedBox(width: 60, child: _headerCell('ID')),
                                        ...widget.resource.columns.map((col) {
                                          return Expanded(child: _headerCell(
                                            col.replaceAll('_', ' ').split(' ').map((s) => s[0].toUpperCase() + s.substring(1)).join(' '),
                                          ));
                                        }),
                                        SizedBox(width: 100, child: _headerCell('Actions', align: TextAlign.right)),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: items.length,
                                      itemBuilder: (context, index) {
                                        final item = items[index];
                                        final isEven = index % 2 == 0;
                                        final isHovered = _hoveredIndex == index;

                                        return MouseRegion(
                                          onEnter: (_) => setState(() => _hoveredIndex = index),
                                          onExit: (_) => setState(() => _hoveredIndex = null),
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 150),
                                            padding: const EdgeInsets.only(left: 16, right: 8),
                                            height: 52,
                                            decoration: BoxDecoration(
                                              color: isHovered
                                                  ? (isDark ? const Color(0xFF1E3A5F) : const Color(0xFFE8F5F0))
                                                  : isEven
                                                      ? (isDark ? const Color(0xFF1A2332) : const Color(0xFFFAFAFA))
                                                      : cardColor,
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: isHovered
                                                      ? const Color(0xFF14B8A6).withValues(alpha: 0.3)
                                                      : borderColor.withValues(alpha: 0.5),
                                                ),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                SizedBox(width: 60, child: _dataCell(item['id']?.toString() ?? '-', textMuted)),
                                                ...widget.resource.columns.map((col) {
                                                  return Expanded(child: _dataCell(item[col]?.toString() ?? '-', textMuted));
                                                }),
                                                SizedBox(
                                                  width: 100,
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: [
                                                      _actionButton(
                                                        Icons.edit_rounded,
                                                        const Color(0xFF14B8A6),
                                                        () => _createOrUpdate(Map<String, dynamic>.from(item)),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      _actionButton(
                                                        Icons.delete_rounded,
                                                        Colors.red.shade400,
                                                        () => _delete(item),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
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

  Widget _headerCell(String text, {TextAlign align = TextAlign.left}) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 12,
        letterSpacing: 0.5,
      ),
      textAlign: align,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _dataCell(String text, Color textColor) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _actionButton(IconData icon, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: 34,
      height: 34,
      child: IconButton(
        icon: Icon(icon, size: 16),
        onPressed: onPressed,
        color: color,
        style: IconButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
