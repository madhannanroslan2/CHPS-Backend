import 'package:flutter/material.dart';
import '../api_client.dart';

class AiPage extends StatefulWidget {
  final ApiClient api;
  const AiPage({super.key, required this.api});

  @override
  State<AiPage> createState() => _AiPageState();
}

class _AiPageState extends State<AiPage> with TickerProviderStateMixin {
  final _controller = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _messages = <_ChatMessage>[];
  bool _loading = false;
  bool _showWelcome = true;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  static const _teal = Color(0xFF0F766E);
  static const _emerald = Color(0xFF10B981);
  static const _bg = Color(0xFFF8FAFC);
  static const _card = Colors.white;
  static const _border = Color(0xFFE5E7EB);
  static const _text = Color(0xFF111827);
  static const _textSecondary = Color(0xFF6B7280);

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final prompt = _controller.text.trim();
    if (prompt.isEmpty) return;
    setState(() {
      _showWelcome = false;
      _messages.add(_ChatMessage(role: 'user', text: prompt, time: DateTime.now()));
      _loading = true;
      _controller.clear();
    });
    _scrollDown();
    try {
      final reply = await widget.api.askAi(prompt);
      if (!mounted) return;
      setState(() => _messages.add(_ChatMessage(role: 'assistant', text: reply, time: DateTime.now())));
      _scrollDown();
    } catch (e) {
      if (!mounted) return;
      setState(() => _messages.add(_ChatMessage(role: 'assistant', text: 'Error: $e', time: DateTime.now())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  void _quickAction(String label) {
    _controller.text = label;
    _send();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWide = MediaQuery.sizeOf(context).width > 1100;
    final bgColor = isDark ? const Color(0xFF0F172A) : _bg;
    final cardColor = isDark ? const Color(0xFF1E293B) : _card;
    final textColor = isDark ? Colors.white : _text;
    final textSec = isDark ? const Color(0xFF94A3B8) : _textSecondary;
    final borderColor = isDark ? const Color(0xFF334155) : _border;

    return Container(
      color: bgColor,
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: _messages.isEmpty && _showWelcome
                      ? SingleChildScrollView(
                          padding: EdgeInsets.symmetric(horizontal: isWide ? 64 : 24, vertical: 32),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 720),
                              child: _buildWelcomeSection(isDark, cardColor, textColor, textSec, borderColor),
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollCtrl,
                          padding: EdgeInsets.fromLTRB(isWide ? 64 : 24, 24, isWide ? 64 : 24, 24),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) => _buildMessageBubble(_messages[index], isDark, cardColor, textColor, textSec),
                        ),
                ),
                if (_loading) _buildTypingIndicator(isDark, cardColor, textSec),
                _buildInputArea(isDark, cardColor, borderColor, textSec),
              ],
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildWelcomeSection(bool isDark, Color cardColor, Color textColor, Color textSec, Color borderColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 24),
        AnimatedBuilder(
          animation: _pulseAnim,
          builder: (context, child) => Transform.scale(scale: _pulseAnim.value, child: child),
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_teal, _emerald], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: _teal.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6)),
              ],
            ),
            child: const Center(child: Icon(Icons.psychology_rounded, color: Colors.white, size: 36)),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          "Hello! I'm your CHPS Healthcare Assistant.",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: textColor, letterSpacing: -0.3),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'How can I help you today?',
          style: TextStyle(fontSize: 15, color: textSec),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        _buildQuickActions(isDark, cardColor, textColor, textSec, borderColor),
        const SizedBox(height: 32),
        _buildCapabilityBadges(isDark, textColor, borderColor),
      ],
    );
  }

  Widget _buildQuickActions(bool isDark, Color cardColor, Color textColor, Color textSec, Color borderColor) {
    final actions = [
      ('Analyze Medical History', Icons.medical_information_rounded, 'Analyze recent medical histories and identify health trends across all residents in the community.'),
      ('Generate Health Reports', Icons.summarize_rounded, 'Create comprehensive health reports with key metrics, immunization coverage, and population health statistics.'),
      ('Immunization Insights', Icons.vaccines_rounded, 'View immunization completion rates, overdue vaccines, and coverage analysis by purok or household.'),
      ('Household Statistics', Icons.home_work_rounded, 'Breakdown of households by purok, family size distribution, and household demographic data.'),
      ('Resident Lookup', Icons.people_alt_rounded, 'Find detailed resident information including medical history, immunizations, and family connections.'),
      ('Health Recommendations', Icons.tips_and_updates_rounded, 'Get AI-powered recommendations for community health programs, disease prevention, and resource allocation.'),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: actions.map((a) {
        final label = a.$1;
        final icon = a.$2;
        final desc = a.$3;
        return _QuickActionCard(
          label: label,
          icon: icon,
          description: desc,
          cardColor: cardColor,
          textColor: textColor,
          textSec: textSec,
          borderColor: borderColor,
          isDark: isDark,
          onTap: () => _quickAction(label),
        );
      }).toList(),
    );
  }

  Widget _buildCapabilityBadges(bool isDark, Color textColor, Color borderColor) {
    final badges = [
      ('Resident Analysis', Icons.people_rounded),
      ('Medical Records', Icons.medical_services_rounded),
      ('Report Generation', Icons.description_rounded),
      ('Healthcare Insights', Icons.insights_rounded),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: badges.map((b) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _emerald.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _emerald.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(b.$2, size: 14, color: _emerald),
              const SizedBox(width: 6),
              Text(b.$1, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _emerald)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMessageBubble(_ChatMessage msg, bool isDark, Color cardColor, Color textColor, Color textSec) {
    final isUser = msg.role == 'user';
    final timeStr = '${msg.time.hour}:${msg.time.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width > 900 ? 600 : MediaQuery.sizeOf(context).width * 0.85),
          child: Column(
            crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (!isUser)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6, left: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 24, height: 24,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [_teal, _emerald]),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.psychology_rounded, size: 14, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Text('CHPS AI', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _teal)),
                    ],
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isUser ? _teal : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                    bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      msg.text,
                      style: TextStyle(fontSize: 14, color: isUser ? Colors.white : textColor, height: 1.5),
                    ),
                    const SizedBox(height: 4),
                    Text(timeStr, style: TextStyle(fontSize: 11, color: isUser ? Colors.white.withValues(alpha: 0.6) : textSec)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(bool isDark, Color cardColor, Color textSec) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width > 900 ? 600 : MediaQuery.sizeOf(context).width * 0.85),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 6, left: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 24, height: 24,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [_teal, _emerald]),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.psychology_rounded, size: 14, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Text('CHPS AI', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _teal)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _dot(color: _teal, delay: 0),
                    const SizedBox(width: 4),
                    _dot(color: _teal, delay: 200),
                    const SizedBox(width: 4),
                    _dot(color: _teal, delay: 400),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dot({required Color color, required int delay}) {
    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (context, child) {
        final phase = ((_pulseCtrl.value * 1000 + delay) % 1000) / 1000;
        final size = 6.0 + phase * 4.0;
        return Container(width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
      },
    );
  }

  Widget _buildInputArea(bool isDark, Color cardColor, Color borderColor, Color textSec) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : _bg,
        border: Border(top: BorderSide(color: borderColor.withValues(alpha: 0.5))),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attachment_rounded, size: 20),
                  color: textSec,
                  onPressed: () {},
                  style: IconButton.styleFrom(minimumSize: const Size(36, 36), padding: EdgeInsets.zero),
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Ask anything about residents, households, immunizations, or medical records...',
                      hintStyle: TextStyle(fontSize: 13, color: textSec),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                      isDense: true,
                    ),
                    style: TextStyle(fontSize: 14, color: isDark ? Colors.white : _text),
                    maxLines: 1,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.mic_rounded, size: 20),
                  color: textSec,
                  onPressed: () {},
                  style: IconButton.styleFrom(minimumSize: const Size(36, 36), padding: EdgeInsets.zero),
                ),
                const SizedBox(width: 4),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [_teal, _emerald]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, size: 18, color: Colors.white),
                    onPressed: _send,
                    style: IconButton.styleFrom(minimumSize: const Size(36, 36), padding: EdgeInsets.zero),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}

class _QuickActionCard extends StatefulWidget {
  final String label;
  final IconData icon;
  final String description;
  final Color cardColor;
  final Color textColor;
  final Color textSec;
  final Color borderColor;
  final bool isDark;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.label,
    required this.icon,
    required this.description,
    required this.cardColor,
    required this.textColor,
    required this.textSec,
    required this.borderColor,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: 220,
        transform: _hovered ? Matrix4.translationValues(0, -4, 0) : Matrix4.identity(),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _hovered ? const Color(0xFF10B981).withValues(alpha: 0.4) : widget.borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: _hovered ? 0.08 : 0.03),
                    blurRadius: _hovered ? 16 : 8,
                    offset: Offset(0, _hovered ? 6 : 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(widget.icon, size: 18, color: const Color(0xFF10B981)),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.label,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: widget.textColor),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.description,
                    style: TextStyle(fontSize: 11, color: widget.textSec, height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String role;
  final String text;
  final DateTime time;
  _ChatMessage({required this.role, required this.text, DateTime? time}) : time = time ?? DateTime.now();
}
