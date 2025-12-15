import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';

class ZagNavigationBarBadge extends badges.Badge {
  ZagNavigationBarBadge({
    Key? key,
    required String text,
    required IconData icon,
    required bool showBadge,
    required bool isActive,
  }) : super(
          key: key,
          badgeStyle: badges.BadgeStyle(
            badgeColor: ZagColours.currentAccent.dimmed(),
            elevation: ZagUI.ELEVATION,
            shape: badges.BadgeShape.circle,
          ),
          badgeAnimation: const badges.BadgeAnimation.scale(
            animationDuration:
                Duration(milliseconds: ZagUI.ANIMATION_SPEED_SCROLLING),
          ),
          position: badges.BadgePosition.topEnd(
            top: -ZagUI.DEFAULT_MARGIN_SIZE,
            end: -ZagUI.DEFAULT_MARGIN_SIZE,
          ),
          badgeContent: Text(
            text,
            style: const TextStyle(color: Colors.white),
          ),
          child: Builder(
            builder: (BuildContext context) => Icon(
              icon,
              color: isActive
                  ? ZagColours.currentAccent
                  : Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black87,
            ),
          ),
          showBadge: showBadge,
        );
}
