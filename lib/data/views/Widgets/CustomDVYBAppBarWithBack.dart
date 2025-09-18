import 'package:flutter/material.dart';


class CustomDVYBAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomDVYBAppBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(88.2474136352539);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 88.2474136352539,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF61C2FF), // #61C2FF
            Color(0xFFFFFFFF), // #FFFFFF
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Image.asset(
            'assets/images/DVYBL.png',
            height: 40,
            fit: BoxFit.fill,
            errorBuilder: (context, error, stackTrace) {
              return Text(
                'DVYB',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// Alternative version with back button support
class CustomDVYBAppBarWithBack extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onBackPressed;
  final bool showBackButton;

  const CustomDVYBAppBarWithBack({
    Key? key,
    this.onBackPressed,
    this.showBackButton = true,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(88.2474136352539);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 393,
      height: 88.2474136352539,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF61C2FF), // #61C2FF
            Color(0xFFFFFFFF), // #FFFFFF
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: 33,
          right: 16,
          bottom: 24,
          left: 16,
        ),
        child: Row(
          children: [
            if (showBackButton) ...[
              GestureDetector(
                onTap: onBackPressed ?? () => Navigator.of(context).pop(),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              SizedBox(width: 16),
            ],
            Expanded(
              child: Center(
                child: Image.asset(
                  'assets/images/DVYBL.png', height: 90, width: 90,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback if image is not found
                    return Text(
                      'DVYB',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
            ),
            if (showBackButton) SizedBox(width: 40), // Balance the layout
          ],
        ),
      ),
    );
  }
}

// Usage example:
//
// For basic usage without back button:
// appBar: CustomDVYBAppBar(),
//
// For usage with back button:
// appBar: CustomDVYBAppBarWithBack(
//   onBackPressed: () => Get.back(),
// ),
//
// For usage without back button:
// appBar: CustomDVYBAppBarWithBack(
//   showBackButton: false,
// ),