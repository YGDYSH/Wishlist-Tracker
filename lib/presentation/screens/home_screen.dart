import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../data/models/wishlist_item.dart';
import '../../data/repositories/api_repository.dart';
import '../../data/repositories/wishlist_repository.dart';
import '../../services/session_service.dart';
import '../../services/theme_service.dart';
import '../../services/notification_service.dart';
import '../../services/sync_service.dart';
import '../helpers.dart';
import '../widgets/dashboard_summary.dart';
import '../widgets/empty_state.dart';
import '../widgets/home_header.dart';
import '../widgets/wishlist_card.dart';
import 'login_screen.dart';
import 'statistics_screen.dart';
import 'wishlist_detail_screen.dart';
import 'wishlist_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WishlistRepository _repository = WishlistRepository();

  // API (online) wishlist state. Hive remains the offline/local CRUD store.
  List<WishlistItem> _apiWishlists = [];
  bool _apiLoading = true;
  String? _apiError;

  String _query = '';
  FilterOption _filter = FilterOption.all;
  SortOption _sort = SortOption.terbaru;

  @override
  void initState() {
    super.initState();
    _loadApiWishlists();
  }

  Future<void> _loadApiWishlists() async {
    final userId = SessionService.userId;
    if (userId == null) {
      setState(() {
        _apiLoading = false;
        _apiError = 'Session tidak valid. Silakan login ulang.';
      });
      return;
    }
    setState(() {
      _apiLoading = true;
      _apiError = null;
    });
    try {
      // 1) Push pending local changes to the server (two-way sync).
      await SyncService.pushAll();
      // 2) Pull the server list.
      final list = await ApiRepository.getWishlists(userId);
      // 3) Merge remote items into local Hive so both stores converge.
      await SyncService.mergeRemote(list);
      if (!mounted) return;
      setState(() {
        _apiWishlists = list;
        _apiError = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _apiError = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _apiError = 'Gagal memuat wishlist dari server.');
    } finally {
      if (mounted) setState(() => _apiLoading = false);
    }
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await SessionService.logout();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  List<WishlistItem> _filteredItems(List<WishlistItem> all) =>
      applyFilters(items: all, query: _query, filter: _filter, sort: _sort);

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SortSheet(
        selected: _sort,
        onSelect: (s) {
          setState(() => _sort = s);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(
        selected: _filter,
        onSelect: (f) {
          setState(() => _filter = f);
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _openForm([WishlistItem? existing]) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            WishlistFormScreen(repository: _repository, existingItem: existing),
      ),
    );
    if (result == true && mounted) {
      NotificationService.rescheduleAllReminders();
    }
  }

  Future<void> _openDetail(WishlistItem item) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            WishlistDetailScreen(repository: _repository, item: item),
      ),
    );
    if (result == true && mounted) {
      NotificationService.rescheduleAllReminders();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wishlist berhasil dihapus')),
      );
    }
  }

  void _openStats() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StatisticsScreen(repository: _repository),
      ),
    );
  }

@override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: ThemeService.isDark,
      builder: (context, isDark, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(SessionService.userName ?? 'Wishlist Tracker'),
            actions: [
              IconButton(
                onPressed: () => ThemeService.toggleTheme(),
                icon: Icon(
                  isDark ? Icons.dark_mode : Icons.light_mode,
                  size: 22,
                ),
                tooltip: 'Theme',
              ),
              IconButton(
                onPressed: _apiLoading ? null : _loadApiWishlists,
                icon: const Icon(Icons.refresh),
                tooltip: 'Muat ulang dari server',
              ),
              IconButton(
                onPressed: _confirmLogout,
                icon: const Icon(Icons.logout),
                tooltip: 'Logout',
              ),
            ],
          ),
          body: child!,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openForm(),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('Tambah'),
          ),
        );
      },
      child: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: _repository.listenable,
          builder: (context, box, child) {
            final allItems = _repository.getAll();
            final items = _filteredItems(allItems);

            if (allItems.isEmpty) {
              return Column(
                children: [
                  HomeHeader(),
                  _ApiStatusBanner(
                    loading: _apiLoading,
                    error: _apiError,
                    count: _apiWishlists.length,
                    onRetry: _loadApiWishlists,
                  ),
                  Expanded(child: EmptyState(onAdd: () => _openForm())),
                ],
              );
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HomeHeader(),
                  _ApiStatusBanner(
                    loading: _apiLoading,
                    error: _apiError,
                    count: _apiWishlists.length,
                    onRetry: _loadApiWishlists,
                  ),
                  DashboardSummary(items: allItems),
                  _SearchFilterBar(
                    query: _query,
                    filter: _filter,
                    sort: _sort,
                    onQueryChanged: (q) => setState(() => _query = q),
                    onTapFilter: _showFilterSheet,
                    onTapSort: _showSortSheet,
                    onTapStats: _openStats,
                  ),
                  if (items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(48),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 48,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: AppDimens.spacingMd),
                            Text(
                              'Tidak ditemukan wishlist yang sesuai.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          ...items.map(
                            (item) => WishlistCard(
                              item: item,
                              onTap: () => _openDetail(item),
                            ),
                          ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Search / filter / sort bar
// ---------------------------------------------------------------------------

/// Shows the state of the online (API) wishlist fetch.
/// Hive data is always displayed below regardless of this banner.
class _ApiStatusBanner extends StatelessWidget {
  final bool loading;
  final String? error;
  final int count;
  final VoidCallback onRetry;

  const _ApiStatusBanner({
    required this.loading,
    required this.error,
    required this.count,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    late final Color background;
    late final Color foreground;
    late final IconData icon;
    late final String text;

    if (loading) {
      background = colorScheme.surfaceContainerHighest;
      foreground = colorScheme.onSurfaceVariant;
      icon = Icons.cloud_sync_outlined;
      text = 'Memuat wishlist dari server...';
    } else if (error != null) {
      background = AppColors.error.withValues(alpha: 0.08);
      foreground = AppColors.error;
      icon = Icons.cloud_off_outlined;
      text = error!;
    } else {
      background = AppColors.secondary.withValues(alpha: 0.12);
      foreground = colorScheme.onSurface;
      icon = Icons.cloud_done_outlined;
      text = 'Server: $count wishlist tersinkron';
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      ),
      child: Row(
        children: [
          if (loading)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Icon(icon, size: 18, color: foreground),
          const SizedBox(width: AppDimens.spacingSm),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: foreground),
            ),
          ),
          if (!loading && error != null)
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Coba lagi', style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
    );
  }
}

class _SearchFilterBar extends StatelessWidget {
  final String query;
  final FilterOption filter;
  final SortOption sort;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onTapFilter;
  final VoidCallback onTapSort;
  final VoidCallback onTapStats;

  const _SearchFilterBar({
    required this.query,
    required this.filter,
    required this.sort,
    required this.onQueryChanged,
    required this.onTapFilter,
    required this.onTapSort,
    required this.onTapStats,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            onChanged: onQueryChanged,
            decoration: InputDecoration(
              hintText: 'Cari wishlist...',
              prefixIcon: const Icon(Icons.search, size: 20),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: AppDimens.spacingSm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  icon: Icons.filter_list_rounded,
                  label: filter.label,
                  onTap: onTapFilter,
                ),
                const SizedBox(width: AppDimens.spacingSm),
                _FilterChip(
                  icon: Icons.sort_rounded,
                  label: sort.label,
                  onTap: onTapSort,
                ),
                const SizedBox(width: AppDimens.spacingSm),
                _FilterChip(
                  icon: Icons.bar_chart_rounded,
                  label: 'Statistik',
                  onTap: onTapStats,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FilterChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.surfaceContainerHighest),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: colorScheme.onSurface),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom sheets
// ---------------------------------------------------------------------------

class _SortSheet extends StatelessWidget {
  final SortOption selected;
  final ValueChanged<SortOption> onSelect;

  const _SortSheet({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.pagePadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppDimens.spacingMd),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const Text(
                'Urutkan berdasarkan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppDimens.spacingMd),
              RadioGroup<SortOption>(
                groupValue: selected,
                onChanged: (v) => onSelect(v!),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: SortOption.values
                      .map(
                        (opt) => RadioListTile<SortOption>(
                          title: Text(opt.label),
                          value: opt,
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterSheet extends StatelessWidget {
  final FilterOption selected;
  final ValueChanged<FilterOption> onSelect;

  const _FilterSheet({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.pagePadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppDimens.spacingMd),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const Text(
                'Filter wishlist',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppDimens.spacingMd),
              RadioGroup<FilterOption>(
                groupValue: selected,
                onChanged: (v) => onSelect(v!),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: FilterOption.values
                      .map(
                        (opt) => RadioListTile<FilterOption>(
                          title: Text(opt.label),
                          value: opt,
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
