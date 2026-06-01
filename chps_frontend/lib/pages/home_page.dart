import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_client.dart';
import '../models.dart';
import '../widgets/admin_sidebar.dart';
import '../main.dart';
import 'auth_page.dart';
import 'overview_page.dart';
import 'resource_table_page.dart';
import 'patients_page.dart';
import 'ai_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.api});
  final ApiClient api;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  bool _sidebarCollapsed = false;
  String _adminEmail = 'Admin';

  final List<String> _pageKeys = const [
    'overview',
    'households',
    'residents',
    'patients',
    'immunizations',
    'medical history',
    'reports',
    'ai assistant',
  ];

  @override
  void initState() {
    super.initState();
    _loadAdminEmail();
  }

  Future<void> _loadAdminEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token != null) {
      try {
        final parts = token.split('.');
        if (parts.length == 3) {
          final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
          final data = jsonDecode(payload) as Map<String, dynamic>;
          final email = data['sub']?.toString() ?? data['email']?.toString() ?? 'Admin';
          if (mounted) setState(() => _adminEmail = email);
        }
      } catch (_) {}
    }
  }

  Future<void> _signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    widget.api.clearToken();
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AuthPage(api: widget.api)));
  }

  Widget _buildPage(int index) {
    final key = _pageKeys[index];
    switch (key) {
      case 'overview':
        return OverviewPage(api: widget.api);
      case 'patients':
        return PatientsPage(api: widget.api);
      case 'reports':
        return ResourceTablePage(api: widget.api, resource: resourceDefs[4]);
      case 'ai assistant':
        return AiPage(api: widget.api);
      default:
        return ResourceTablePage(api: widget.api, resource: resourceDefs[index <= 2 ? index - 1 : index - 2]);
    }
  }

  String get _currentTitle {
    final key = _pageKeys[selectedIndex];
    return key.split(' ').map((s) => s[0].toUpperCase() + s.substring(1)).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final compact = MediaQuery.sizeOf(context).width < 840;
    return Scaffold(
      drawer: compact
          ? NavigationDrawer(
              selectedIndex: selectedIndex,
              onDestinationSelected: (i) {
                if (i == _pageKeys.length) {
                  Navigator.pop(context);
                  _signOut();
                } else {
                  setState(() => selectedIndex = i);
                  Navigator.pop(context);
                }
              },
              children: [
                Padding(padding: const EdgeInsets.all(16), child: AdminSidebarHeader(compact: true, dark: isDark)),
                ...List.generate(_pageKeys.length, (i) {
                  final key = _pageKeys[i];
                  String label = key;
                  IconData icon = Icons.dashboard_rounded;
                  if (key == 'patients') {
                    label = 'Patients';
                    icon = Icons.people_rounded;
                  } else if (key == 'reports') {
                    label = 'Reports';
                    icon = Icons.summarize_rounded;
                  } else if (key == 'ai assistant') {
                    label = 'AI Assistant';
                    icon = Icons.smart_toy_rounded;
                  } else if (key == 'households') {
                    label = 'Households';
                    icon = Icons.home_work_outlined;
                  } else if (key == 'residents') {
                    label = 'Residents';
                    icon = Icons.people_alt_outlined;
                  } else if (key == 'immunizations') {
                    label = 'Immunizations';
                    icon = Icons.vaccines_outlined;
                  } else if (key == 'medical history') {
                    label = 'Medical History';
                    icon = Icons.medical_information_outlined;
                  }
                  return NavigationDrawerDestination(icon: Icon(icon), label: Text(label));
                }),
                const NavigationDrawerDestination(icon: Icon(Icons.logout_rounded), label: Text('Sign Out')),
              ],
            )
          : null,
      body: Row(
        children: [
          if (!compact)
            AdminSidebar(
              active: _pageKeys[selectedIndex],
              collapsed: _sidebarCollapsed,
              onToggle: () => setState(() => _sidebarCollapsed = !_sidebarCollapsed),
              onEntrySelected: (key) => setState(() => selectedIndex = _pageKeys.indexOf(key)),
              onSignOut: _signOut,
            ),
          Expanded(
            child: Column(
              children: [
                _buildTopNav(theme, compact, isDark),
                Expanded(
                  child: IndexedStack(
                    index: selectedIndex,
                    children: List.generate(_pageKeys.length, (i) => _buildPage(i)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopNav(ThemeData theme, bool compact, bool isDark) {
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dateStr = '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}, ${now.year}';
    final bgColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 28, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            if (compact)
              Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              ),
            if (!compact)
              Text(
                _currentTitle == 'Overview' ? 'Dashboard' : _currentTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            const Spacer(),
            _buildDateChip(dateStr, isDark),
            const SizedBox(width: 12),
            _buildIconButton(
              icon: ChpsApp.of(context).themeMode == ThemeMode.dark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
              tooltip: 'Toggle theme',
              onPressed: () => ChpsApp.of(context).toggleTheme(),
              isDark: isDark,
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              tooltip: 'Profile',
              offset: const Offset(0, 48),
              icon: CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFF0F766E),
                child: Text(
                  _adminEmail.isNotEmpty ? _adminEmail[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              onSelected: (value) {
                if (value == 'profile') {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      title: const Text('Profile'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: const Color(0xFF0F766E),
                                child: Text(
                                  _adminEmail.isNotEmpty ? _adminEmail[0].toUpperCase() : 'U',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text('User', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    SizedBox(height: 4),
                                    Text('User email', style: TextStyle(color: Color(0xff64748b))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.logout, color: Colors.red),
                            title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
                            onTap: () async {
                              Navigator.pop(ctx);
                              final prefs = await SharedPreferences.getInstance();
                              await prefs.remove('access_token');
                              widget.api.clearToken();
                              if (!context.mounted) return;
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => AuthPage(api: widget.api)),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'profile',
                  child: ListTile(
                    leading: Icon(Icons.person),
                    title: Text('My Profile'),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateChip(String date, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today_rounded,
            size: 14,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
          const SizedBox(width: 8),
          Text(
            date,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0),
        ),
      ),
      child: IconButton(
        tooltip: tooltip,
        icon: Icon(icon, size: 18),
        onPressed: onPressed,
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          minimumSize: const Size(38, 38),
        ),
      ),
    );
  }
}
