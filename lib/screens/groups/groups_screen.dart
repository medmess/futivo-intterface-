import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/localization/app_language.dart';
import '../../services/backend_api_service.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final BackendApiService _backend = BackendApiService();
  late Future<List<FantasyGroupDto>> _groupsFuture;

  @override
  void initState() {
    super.initState();
    _groupsFuture = _backend.getMyGroups();
  }

  Future<void> _reload() async {
    setState(() => _groupsFuture = _backend.getMyGroups());
    await _groupsFuture;
  }

  Future<void> _showCreateGroupDialog() async {
    final controller = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (_) {
        return _GroupDialog(
          title: context.t('createGroup'),
          hint: context.t('groupName'),
          buttonText: context.t('create'),
          controller: controller,
          onSubmit: () async {
            final name = controller.text.trim();
            if (name.isEmpty) return;
            Navigator.pop(context);

            try {
              final group = await _backend.createGroup(name);
              if (!mounted) return;
              _showMessage(
                trReplace(context.t('groupCreated'), {'id': group.code}),
              );
              await _reload();
            } catch (_) {
              if (!mounted) return;
              _showMessage(context.t('backendUnavailable'));
            }
          },
        );
      },
    );

    controller.dispose();
  }

  Future<void> _showJoinGroupDialog() async {
    final controller = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (_) {
        return _GroupDialog(
          title: context.t('joinGroup'),
          hint: context.t('enterGroupId'),
          buttonText: context.t('join'),
          controller: controller,
          onSubmit: () async {
            final code = controller.text.trim().toUpperCase();
            if (code.isEmpty) return;
            Navigator.pop(context);

            try {
              await _backend.joinGroup(code);
              if (!mounted) return;
              _showMessage(context.t('groupJoined'));
              await _reload();
            } catch (_) {
              if (!mounted) return;
              _showMessage(context.t('groupNotFound'));
            }
          },
        );
      },
    );

    controller.dispose();
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), backgroundColor: AppColors.surface),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      onRefresh: _reload,
      child: FutureBuilder<List<FantasyGroupDto>>(
        future: _groupsFuture,
        builder: (context, snapshot) {
          final groups = snapshot.data ?? const <FantasyGroupDto>[];
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            children: [
              const _HeroCard(),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.add_rounded,
                      title: context.t('createGroup'),
                      onTap: _showCreateGroupDialog,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.login_rounded,
                      title: context.t('joinGroup'),
                      onTap: _showJoinGroupDialog,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              Text(
                context.t('yourGroups'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              if (snapshot.connectionState == ConnectionState.waiting)
                const _LoadingGroups()
              else if (snapshot.hasError)
                _StateCard(
                  message: context.t('backendStartHint'),
                  onRetry: _reload,
                )
              else if (groups.isEmpty)
                const _EmptyGroups()
              else
                ...groups.map((group) => _GroupCard(group: group)),
              const SizedBox(height: 26),
              Text(
                context.t('weeklyTop'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              const _EmptyLeaderboard(),
            ],
          );
        },
      ),
    );
  }
}

class _GroupDialog extends StatelessWidget {
  final String title;
  final String hint;
  final String buttonText;
  final TextEditingController controller;
  final Future<void> Function() onSubmit;

  const _GroupDialog({
    required this.title,
    required this.hint,
    required this.buttonText,
    required this.controller,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
        ),
      ),
      content: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        textCapitalization: TextCapitalization.characters,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),
          filled: true,
          fillColor: AppColors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            context.t('cancel'),
            style: const TextStyle(color: Colors.white54),
          ),
        ),
        ElevatedButton(
          onPressed: onSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: Text(
            buttonText,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFF8B1026), AppColors.background],
        ),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.26)),
      ),
      child: Row(
        children: [
          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.16),
            ),
            child: const Icon(
              Icons.groups_rounded,
              color: AppColors.teal,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.t('competeFriends'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.t('groupsSubtitle'),
                  style: const TextStyle(
                    color: Colors.white54,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          height: 62,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.teal),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final FantasyGroupDto group;

  const _GroupCard({required this.group});

  @override
  Widget build(BuildContext context) {
    final isFull = group.members >= group.maxMembers;

    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Icon(Icons.groups_rounded, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 15.5,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${group.members}/${group.maxMembers} ${context.t('members')}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.52),
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'ID: ${group.code}',
                  style: const TextStyle(
                    color: AppColors.teal,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: isFull
                  ? Colors.red.withValues(alpha: 0.13)
                  : AppColors.primary.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              isFull ? context.t('fullStatus') : context.t('openStatus'),
              style: TextStyle(
                color: isFull ? Colors.redAccent : AppColors.teal,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _StateCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          const Icon(Icons.dns_rounded, color: AppColors.teal, size: 34),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(context.t('refresh')),
          ),
        ],
      ),
    );
  }
}

class _LoadingGroups extends StatelessWidget {
  const _LoadingGroups();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }
}

class _EmptyGroups extends StatelessWidget {
  const _EmptyGroups();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Center(
        child: Text(
          context.t('noGroups'),
          style: const TextStyle(
            color: Colors.white54,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _EmptyLeaderboard extends StatelessWidget {
  const _EmptyLeaderboard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Center(
        child: Text(
          context.t('noLeaderboard'),
          style: const TextStyle(
            color: Colors.white54,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
