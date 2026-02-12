import 'package:flutter/material.dart';

class DashboardFilters extends StatefulWidget {
  final String? selectedDeviceType;
  final String? selectedStatus;
  final int selectedHours;
  final Function(String?) onDeviceTypeChanged;
  final Function(String?) onStatusChanged;
  final Function(int) onHoursChanged;
  final VoidCallback onClearFilters;

  const DashboardFilters({
    super.key,
    this.selectedDeviceType,
    this.selectedStatus,
    required this.selectedHours,
    required this.onDeviceTypeChanged,
    required this.onStatusChanged,
    required this.onHoursChanged,
    required this.onClearFilters,
  });

  @override
  State<DashboardFilters> createState() => _DashboardFiltersState();
}

class _DashboardFiltersState extends State<DashboardFilters> {
  bool _isExpanded = false;

  bool get hasActiveFilters =>
      widget.selectedDeviceType != null ||
      widget.selectedStatus != null ||
      widget.selectedHours != 24;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 14 : 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00D4FF).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.filter_list_rounded,
                        size: 20,
                        color: Color(0xFF00D4FF),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Filtros',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (hasActiveFilters) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00D4FF), Color(0xFF0066FF)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Ativo',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Row(
                  children: [
                    if (hasActiveFilters)
                      IconButton(
                        onPressed: () {
                          widget.onClearFilters();
                        },
                        icon: const Icon(Icons.clear_rounded),
                        color: Colors.red[300],
                        tooltip: 'Limpar filtros',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.red.withOpacity(0.1),
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                    Icon(
                      _isExpanded
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_isExpanded) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildFilterChip(
                  label: 'Tipo',
                  value: widget.selectedDeviceType,
                  options: const ['ESP32', 'ESP8266', 'Arduino'],
                  onChanged: widget.onDeviceTypeChanged,
                  icon: Icons.memory,
                ),
                _buildFilterChip(
                  label: 'Status',
                  value: widget.selectedStatus,
                  options: const ['ONLINE', 'OFFLINE'],
                  onChanged: widget.onStatusChanged,
                  icon: Icons.circle,
                ),
                _buildTimeFilter(),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String? value,
    required List<String> options,
    required Function(String?) onChanged,
    required IconData icon,
  }) {
    final isActive = value != null;

    return PopupMenuButton<String>(
      onSelected: onChanged,
      color: const Color(0xFF0A0E27),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  colors: [Color(0xFF00D4FF), Color(0xFF0066FF)],
                )
              : null,
          color: isActive ? null : const Color(0xFF0A0E27),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? Colors.transparent
                : Colors.white.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              value ?? label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.arrow_drop_down_rounded, size: 20, color: Colors.white),
          ],
        ),
      ),
      itemBuilder: (context) => [
        if (value != null)
          PopupMenuItem<String>(
            value: null,
            child: Row(
              children: [
                Icon(Icons.clear_rounded, size: 18, color: Colors.red[300]),
                const SizedBox(width: 12),
                Text(
                  'Limpar filtro',
                  style: TextStyle(
                    color: Colors.red[300],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        if (value != null) const PopupMenuDivider(),
        ...options.map(
          (option) => PopupMenuItem<String>(
            value: option,
            child: Row(
              children: [
                Icon(
                  value == option
                      ? Icons.check_circle_rounded
                      : Icons.circle_outlined,
                  size: 18,
                  color: value == option
                      ? const Color(0xFF00D4FF)
                      : Colors.white.withOpacity(0.5),
                ),
                const SizedBox(width: 12),
                Text(
                  option,
                  style: TextStyle(
                    color: value == option
                        ? const Color(0xFF00D4FF)
                        : Colors.white,
                    fontWeight: value == option
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeFilter() {
    final isActive = widget.selectedHours != 24;

    return PopupMenuButton<int>(
      onSelected: widget.onHoursChanged,
      color: const Color(0xFF0A0E27),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  colors: [Color(0xFF00D4FF), Color(0xFF0066FF)],
                )
              : null,
          color: isActive ? null : const Color(0xFF0A0E27),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? Colors.transparent
                : Colors.white.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.schedule_rounded, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              widget.selectedHours == 24
                  ? 'Período'
                  : widget.selectedHours >= 24
                  ? '${widget.selectedHours ~/ 24}d'
                  : '${widget.selectedHours}h',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.arrow_drop_down_rounded,
              size: 20,
              color: Colors.white,
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        _buildTimeMenuItem(1, '1 hora'),
        _buildTimeMenuItem(6, '6 horas'),
        _buildTimeMenuItem(12, '12 horas'),
        _buildTimeMenuItem(24, '24 horas'),
        _buildTimeMenuItem(48, '2 dias'),
        _buildTimeMenuItem(168, '7 dias'),
        _buildTimeMenuItem(720, '30 dias'),
      ],
    );
  }

  PopupMenuItem<int> _buildTimeMenuItem(int hours, String label) {
    final isSelected = widget.selectedHours == hours;

    return PopupMenuItem<int>(
      value: hours,
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
            size: 18,
            color: isSelected
                ? const Color(0xFF00D4FF)
                : Colors.white.withOpacity(0.5),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF00D4FF) : Colors.white,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
