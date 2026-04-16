import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double radius;
  final VoidCallback? onTap;

  const AvatarWidget({
    Key? key,
    this.imageUrl,
    required this.name,
    this.radius = 30,
    this.onTap,
  }) : super(key: key);

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || name.trim().isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget avatar;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      avatar = CachedNetworkImage(
        imageUrl: imageUrl!,
        imageBuilder: (ctx, provider) => _avatarWithBorder(context, image: provider),
        placeholder: (ctx, url) => _avatarWithBorder(context),
        errorWidget: (ctx, url, err) => _avatarWithBorder(context),
      );
    } else {
      avatar = _avatarWithBorder(context);
    }

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: avatar);
    }
    return avatar;
  }

  /// 🔵 Avatar with 2px border
  Widget _avatarWithBorder(BuildContext context, {ImageProvider? image}) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(2), // 👈 2px border
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: scheme.primary, // 👈 border color (change if needed)
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundImage: image,
        backgroundColor: image == null ? scheme.primary.withOpacity(0.15) : Colors.transparent,
        child: image == null
            ? Text(
                _initials,
                style: TextStyle(
                  fontSize: radius * 0.65,
                  fontWeight: FontWeight.w700,
                  color: scheme.onPrimary,
                ),
              )
            : null,
      ),
    );
  }
}
