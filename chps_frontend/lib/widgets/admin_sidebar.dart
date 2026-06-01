import 'package:flutter/material.dart';

class AdminSidebarHeader extends StatelessWidget {
  final bool compact;
  final bool dark;
  final bool collapsed;

  const AdminSidebarHeader({
    super.key,
    required this.compact,
    required this.dark,
    this.collapsed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.local_hospital_outlined,
            color: Colors.white,
            size: collapsed ? 22 : 24,
          ),
        ),
        if (!compact && !collapsed) ...[
          const SizedBox(width: 12),
          const Text(
            'CHPS Admin',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ],
      ],
    );
  }
}

class AdminSidebar extends StatefulWidget {
  final String active;
  final ValueChanged<String> onEntrySelected;
  final bool collapsed;
  final VoidCallback onToggle;
  final VoidCallback? onSignOut;

  const AdminSidebar({
    super.key,
    required this.active,
    required this.onEntrySelected,
    required this.collapsed,
    required this.onToggle,
    this.onSignOut,
  });

  @override
  State<AdminSidebar> createState() => _AdminSidebarState();
}

class _AdminSidebarState extends State<AdminSidebar> {
  String? _hoveredKey;

  static const _sidebarItems = [
    _SidebarItemData(icon: Icons.dashboard_rounded, label: 'Overview', key: 'overview'),
    _SidebarItemData(icon: Icons.home_work_outlined, label: 'Households', key: 'households'),
    _SidebarItemData(icon: Icons.people_alt_outlined, label: 'Residents', key: 'residents'),
    _SidebarItemData(icon: Icons.person_rounded, label: 'Patients', key: 'patients'),
    _SidebarItemData(icon: Icons.vaccines_outlined, label: 'Immunizations', key: 'immunizations'),
    _SidebarItemData(icon: Icons.medical_information_outlined, label: 'Medical History', key: 'medical history'),
    _SidebarItemData(icon: Icons.summarize_rounded, label: 'Reports', key: 'reports'),
    _SidebarItemData(icon: Icons.smart_toy_rounded, label: 'AI Assistant', key: 'ai assistant'),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: widget.collapsed ? 72 : 260,
      decoration: const BoxDecoration(
        color: Color(0xFF0F766E),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(widget.collapsed ? 18 : 20, 20, widget.collapsed ? 18 : 16, 16),
            child: Row(
              children: [
                AdminSidebarHeader(compact: widget.collapsed, dark: false, collapsed: widget.collapsed),
                if (!widget.collapsed) const Spacer(),
                if (!widget.collapsed)
                  InkWell(
                    onTap: widget.onToggle,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.menu_open_rounded, size: 18, color: Color(0xFFE8F5F0)),
                    ),
                  ),
              ],
            ),
          ),
          Divider(height: 1, color: const Color(0xFF2A8D70).withValues(alpha: 0.5)),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: widget.collapsed ? 10 : 12, vertical: 4),
              children: _sidebarItems.map((item) {
                final isActive = widget.active == item.key;
                final isHovered = _hoveredKey == item.key;
                return Padding(
                  padding: EdgeInsets.only(bottom: widget.collapsed ? 8 : 2),
                  child: Tooltip(
                    message: widget.collapsed ? item.label : '',
                    child: MouseRegion(
                      onEnter: (_) => setState(() => _hoveredKey = item.key),
                      onExit: (_) => setState(() => _hoveredKey = null),
                      child: InkWell(
                        onTap: () => widget.onEntrySelected(item.key),
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(
                            horizontal: widget.collapsed ? 0 : 14,
                            vertical: widget.collapsed ? 14 : 12,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? Colors.white.withValues(alpha: 0.18)
                                : isHovered
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: widget.collapsed
                              ? Center(
                                  child: Icon(
                                    item.icon,
                                    size: 22,
                                    color: isActive ? Colors.white : const Color(0xFFA0C8B8),
                                  ),
                                )
                              : Row(
                                  children: [
                                    Icon(
                                      item.icon,
                                      size: 20,
                                      color: isActive ? Colors.white : const Color(0xFFA0C8B8),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Text(
                                        item.label,
                                        style: TextStyle(
                                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                                          fontSize: 14,
                                          color: isActive ? Colors.white : const Color(0xFFE8F5F0),
                                        ),
                                      ),
                                    ),
                                    if (isActive)
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.collapsed ? 10 : 12),
            child: MouseRegion(
              onEnter: (_) => setState(() => _hoveredKey = 'signout'),
              onExit: (_) => setState(() => _hoveredKey = null),
              child: InkWell(
                onTap: () => widget.onSignOut?.call(),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(
                    horizontal: widget.collapsed ? 0 : 14,
                    vertical: widget.collapsed ? 14 : 12,
                  ),
                  decoration: BoxDecoration(
                    color: _hoveredKey == 'signout'
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: widget.collapsed
                      ? const Center(
                          child: Icon(Icons.logout_rounded, size: 22, color: Color(0xFFA0C8B8)),
                        )
                      : Row(
                          children: [
                            const Icon(Icons.logout_rounded, size: 20, color: Color(0xFFA0C8B8)),
                            const SizedBox(width: 14),
                            const Text(
                              'Sign Out',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Color(0xFFE8F5F0),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SidebarItemData {
  final IconData icon;
  final String label;
  final String key;
  const _SidebarItemData({required this.icon, required this.label, required this.key});
}
