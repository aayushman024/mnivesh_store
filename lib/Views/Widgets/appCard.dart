import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:mnivesh_store/Themes/AppTextStyle.dart';
import '../../Models/appModel.dart';
import '../../Providers/download_state_provider.dart';
import 'download_button.dart';

class AppInfoCardUI extends StatefulWidget {
  final AppModel app;
  final bool isChecking;
  final bool isInstalled;
  final bool updateAvailable;
  final String? installedVersion;
  final DownloadState? downloadState;

  final VoidCallback onDownload;
  final VoidCallback onCancelDownload;
  final VoidCallback onUninstall;
  final VoidCallback onOpenApp;

  const AppInfoCardUI({
    super.key,
    required this.app,
    required this.isChecking,
    required this.isInstalled,
    required this.updateAvailable,
    this.installedVersion,
    this.downloadState,
    required this.onDownload,
    required this.onCancelDownload,
    required this.onUninstall,
    required this.onOpenApp,
  });

  @override
  State<AppInfoCardUI> createState() => _AppInfoCardUIState();
}

class _AppInfoCardUIState extends State<AppInfoCardUI> {
  Color get activeColor {
    final Map<String, Color> colorMap = {
      'red': const Color(0xFFE57373),
      'yellow': const Color(0xFFFFE082),
      'green': const Color(0xFF81C784),
      'blue': const Color(0xFF64B5F6),
      'violet': const Color(0xFF9575CD),
      'magenta': const Color(0xFFCE93D8),
      'teal': const Color(0xFF4DB6AC),
      'cyan': const Color(0xFF4DD0E1),
      'orange': const Color(0xFFFFB74D),
      'amber': const Color(0xFFFFD54F),
      'indigo': const Color(0xFF7986CB),
      'pink': const Color(0xFFF06292),
      'lime': const Color(0xFFDCE775),
      'deepPurple': const Color(0xFF9575CD),
    };
    return colorMap[widget.app.colorKey.toLowerCase()] ?? colorMap['violet']!;
  }

  String _parseHtmlForPreview(String htmlString) {
    var text = htmlString.replaceAll(RegExp(r'<br\s*/?>'), '\n');
    text = text.replaceAll(RegExp(r'</p>'), '\n\n');
    text = text.replaceAll(RegExp(r'</li>'), '\n');
    text = text.replaceAll(RegExp(r'<[^>]*>'), '');
    text = text
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');
    return text.trim();
  }

  void _openExpandedView(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black54,
        barrierDismissible: true,
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: Stack(
              children: [
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(color: Colors.black.withOpacity(0.2)),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 90,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: _ExpandedCardContent(
                        parentWidget: widget,
                        activeColor: activeColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color baseDarkBg = const Color(0xFF1E1E2C);
    final Color darkButtonBg = Color.alphaBlend(
      activeColor.withOpacity(0.1),
      const Color(0xFF151520),
    );
    final Color cardBgColor = Color.alphaBlend(
      activeColor.withOpacity(0.04),
      baseDarkBg,
    );
    final Color lightContentColor = Color.lerp(
      activeColor,
      Colors.white,
      0.85,
    )!;
    final TextStyle descStyle = AppTextStyle.light.normal(Colors.grey[300]!);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Card(
        color: cardBgColor,
        shadowColor: activeColor.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: activeColor.withOpacity(0.2), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon Hero
                  Hero(
                    tag: '${widget.app.packageName}_icon',
                    child: SizedBox(
                      height: 50,
                      child: Image.network(widget.app.icon),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name Hero
                        Hero(
                          tag: '${widget.app.packageName}_name',
                          child: Material(
                            type: MaterialType.transparency,
                            child: Text(
                              widget.app.appName,
                              style: AppTextStyle.bold.large(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Version Pill Hero
                        Hero(
                          tag: '${widget.app.packageName}_version',
                          child: Material(
                            type: MaterialType.transparency,
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                _VersionPill(
                                  label: "v${widget.app.version}",
                                  color: activeColor.withOpacity(0.15),
                                  border: activeColor.withOpacity(0.4),
                                  textColor: activeColor,
                                  icon: Icons.grid_view_rounded,
                                ),
                                if (widget.updateAvailable &&
                                    widget.installedVersion != null)
                                  _VersionPill(
                                    label:
                                        "Installed v${widget.installedVersion}",
                                    color: Colors.amber.withOpacity(0.1),
                                    border: Colors.amber.withOpacity(0.4),
                                    textColor: Colors.amber,
                                    icon: Icons.warning_amber_outlined,
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () => _openExpandedView(context),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 2,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.updateAvailable
                                      ? "What's New"
                                      : "See Details",
                                  style: AppTextStyle.bold
                                      .small(activeColor)
                                      .copyWith(
                                        decoration: TextDecoration.underline,
                                        decorationColor: activeColor
                                            .withOpacity(0.5),
                                      ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 10,
                                  color: activeColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.isInstalled)
                    PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.more_vert, color: Colors.grey[400]),
                      color: const Color(0xFF2C2C35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.white.withOpacity(0.1)),
                      ),
                      onSelected: (value) {
                        if (value == 'uninstall') widget.onUninstall();
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'uninstall',
                          child: Row(
                            children: [
                              const Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                                size: 20,
                              ),
                              Text(
                                '  Uninstall ${widget.app.appName}',
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 18),

              // 🔴 NO HERO HERE (Fixed Overflow)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.12),
                    width: 1,
                  ),
                ),
                child: Text(
                  _parseHtmlForPreview(widget.app.description),
                  style: descStyle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: _ActionButtons(
                  widget: widget,
                  activeColor: activeColor,
                  bg: darkButtonBg,
                  fg: lightContentColor,
                  packageName: widget.app.packageName,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpandedCardContent extends StatelessWidget {
  final AppInfoCardUI parentWidget;
  final Color activeColor;

  const _ExpandedCardContent({
    required this.parentWidget,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    const Color baseDarkBg = Color(0xFF1E1E2C);
    final Color cardBgColor = Color.alphaBlend(
      activeColor.withOpacity(0.04),
      baseDarkBg,
    );
    final Color darkButtonBg = Color.alphaBlend(
      activeColor.withOpacity(0.1),
      const Color(0xFF151520),
    );
    final Color lightContentColor = Color.lerp(
      activeColor,
      Colors.white,
      0.85,
    )!;

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: activeColor.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    // Name Hero Destination
                    child: Hero(
                      tag: '${parentWidget.app.packageName}_name',
                      child: Material(
                        type: MaterialType.transparency,
                        child: Text(
                          parentWidget.app.appName,
                          style: AppTextStyle.bold.large().copyWith(
                            fontSize: 22,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white70,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white10, height: 30),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Icon Hero Destination
                        Hero(
                          tag: '${parentWidget.app.packageName}_icon',
                          child: SizedBox(
                            height: 60,
                            child: Image.network(parentWidget.app.icon),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Version Pill Hero Destination
                            Hero(
                              tag: '${parentWidget.app.packageName}_version',
                              child: Material(
                                type: MaterialType.transparency,
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  children: [
                                    _VersionPill(
                                      label: "v${parentWidget.app.version}",
                                      color: activeColor.withOpacity(0.15),
                                      border: activeColor.withOpacity(0.4),
                                      textColor: activeColor,
                                      icon: Icons.grid_view_rounded,
                                    ),
                                    if (parentWidget.updateAvailable &&
                                        parentWidget.installedVersion != null)
                                      _VersionPill(
                                        label:
                                            "Installed v${parentWidget.installedVersion}",
                                        color: Colors.amber.withOpacity(0.1),
                                        border: Colors.amber.withOpacity(0.4),
                                        textColor: Colors.amber,
                                        icon: Icons.warning_amber_outlined,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            if (!parentWidget.isInstalled)
                              Text(
                                "Not Installed",
                                style: AppTextStyle.light.small(Colors.grey),
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Changelog
                    if (parentWidget.app.changelog != null &&
                        parentWidget.app.changelog!.isNotEmpty) ...[
                      Text(
                        "What's New",
                        style: AppTextStyle.bold.large(activeColor),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(0, 18, 18, 16),
                        decoration: BoxDecoration(
                          color: activeColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: activeColor.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: HtmlWidget(
                          parentWidget.app.changelog!,
                          textStyle: AppTextStyle.light.normal(
                            Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    Text(
                      "About this App",
                      style: AppTextStyle.bold.large(activeColor),
                    ),
                    const SizedBox(height: 12),

                    // 🔴 NO HERO HERE (Simple HTML Widget)
                    HtmlWidget(
                      parentWidget.app.description,
                      textStyle: AppTextStyle.light
                          .normal(Colors.grey[300]!)
                          .copyWith(height: 1.6, fontSize: 15),
                      customStylesBuilder: (element) {
                        if (element.localName == 'strong' ||
                            element.localName == 'b') {
                          return {'color': 'white', 'font-weight': 'bold'};
                        }
                        if (element.localName == 'h1' ||
                            element.localName == 'h2') {
                          return {'color': 'white', 'margin-bottom': '10px'};
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
                border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(0.05)),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: _ActionButtons(
                  widget: parentWidget,
                  activeColor: activeColor,
                  bg: darkButtonBg,
                  fg: lightContentColor,
                  packageName: parentWidget.app.packageName,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// HELPER WIDGETS
// ---------------------------------------------------------------------------

class _VersionPill extends StatelessWidget {
  final String label;
  final Color color;
  final Color border;
  final Color textColor;
  final IconData icon;

  const _VersionPill({
    required this.label,
    required this.color,
    required this.border,
    required this.textColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 5),
          Text(label, style: AppTextStyle.bold.small(textColor)),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final AppInfoCardUI widget;
  final Color activeColor;
  final Color bg;
  final Color fg;
  final String packageName;

  const _ActionButtons({
    required this.widget,
    required this.activeColor,
    required this.bg,
    required this.fg,
    required this.packageName,
  });

  @override
  Widget build(BuildContext context) {
    Widget buildMainBtn() {
      if (widget.isChecking)
        return Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: fg),
          ),
        );
      if (widget.downloadState != null && widget.downloadState!.isDownloading)
        return DownloadButton(
          activeColor: activeColor,
          bg: bg,
          fg: fg,
          progress: widget.downloadState!.progress,
          onCancel: widget.onCancelDownload,
        );
      if (widget.isInstalled) {
        return widget.updateAvailable
            ? _Button(
                icon: Icons.system_update,
                label: "Update",
                onTap: widget.onDownload,
                bg: bg,
                fg: fg,
                activeColor: activeColor,
              )
            : _Button(
                icon: Icons.check_circle,
                label: "Installed",
                onTap: widget.onOpenApp,
                bg: bg,
                fg: fg,
                activeColor: activeColor,
              );
      }
      return _Button(
        icon: Icons.download_rounded,
        label: "Download Now",
        onTap: widget.onDownload,
        bg: bg,
        fg: fg,
        activeColor: activeColor,
      );
    }

    return Row(
      children: [
        Expanded(
          // Main Button Hero
          child: Hero(
            tag: '${packageName}_btn_main',
            child: Material(
              type: MaterialType.transparency,
              child: buildMainBtn(),
            ),
          ),
        ),
        if (widget.isInstalled) ...[
          const SizedBox(width: 12),
          // Open Button Hero
          Hero(
            tag: '${packageName}_btn_open',
            child: Material(
              type: MaterialType.transparency,
              child: _OpenButton(
                activeColor: activeColor,
                onTap: widget.onOpenApp,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Button extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color bg;
  final Color fg;
  final Color activeColor;

  const _Button({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.bg,
    required this.fg,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        elevation: 0,
        side: BorderSide(color: activeColor, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: fg, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyle.bold.normal(fg).copyWith(height: 1.3),
          ),
        ],
      ),
    );
  }
}

class _OpenButton extends StatelessWidget {
  final Color activeColor;
  final VoidCallback onTap;

  const _OpenButton({required this.activeColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: activeColor.withOpacity(0.15),
          foregroundColor: activeColor,
          elevation: 0,
          side: BorderSide(color: activeColor.withOpacity(0.5), width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Icon(Icons.open_in_new, color: activeColor, size: 18),
      ),
    );
  }
}
