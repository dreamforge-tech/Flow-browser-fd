// widgets/browser_webview.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../providers/browser_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/constants.dart';

class BrowserWebView extends StatefulWidget {
  final Function(InAppWebViewController)? onWebViewCreated;

  const BrowserWebView({super.key, this.onWebViewCreated});

  @override
  State<BrowserWebView> createState() => _BrowserWebViewState();
}

class _BrowserWebViewState extends State<BrowserWebView> {
  InAppWebViewController? _controller;
  double _progress = 0;

  @override
  Widget build(BuildContext context) {
    final browserProvider = context.watch<BrowserProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final currentTab = browserProvider.currentTab;

    if (currentTab.url == 'about:blank') {
      return _buildStartPage(browserProvider, settingsProvider);
    }

    return Stack(
      children: [
        InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(currentTab.url)),
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            javaScriptCanOpenWindowsAutomatically: false,
            mediaPlaybackRequiresUserGesture: false,
            allowsInlineMediaPlayback: true,
            useOnLoadResource: settingsProvider.blockTrackers,
            useShouldOverrideUrlLoading: true,
          ),
          onWebViewCreated: (controller) {
            _controller = controller;
            widget.onWebViewCreated?.call(controller);
          },
          onLoadStart: (controller, url) {
            setState(() => _progress = 0);
            currentTab.isLoading = true;
          },
          onProgressChanged: (controller, progress) {
            setState(() => _progress = progress / 100);
          },
          onLoadStop: (controller, url) async {
            currentTab.isLoading = false;
            if (url != null) {
              browserProvider.updateCurrentTab(
                url: url.toString(),
                title: await controller.getTitle() ?? url.toString(),
              );
            }
          },
          onTitleChanged: (controller, title) {
            if (title != null) {
              browserProvider.updateCurrentTab(title: title);
            }
          },
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            final url = navigationAction.request.url;
            if (url != null && settingsProvider.blockTrackers) {
              final urlString = url.toString();
              if (AppConstants.trackerBlocklist.any((domain) => 
                  urlString.contains(domain))) {
                return NavigationActionPolicy.CANCEL;
              }
            }
            return NavigationActionPolicy.ALLOW;
          },
        ),
        if (_progress < 1.0)
          LinearProgressIndicator(
            value: _progress,
            backgroundColor: Colors.transparent,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppConstants.primaryColor,
            ),
          ),
      ],
    );
  }

  Widget _buildStartPage(BrowserProvider provider, SettingsProvider settings) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppConstants.backgroundGradient,
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: AppConstants.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppConstants.primaryColor.withOpacity(0.5),
                      blurRadius: 60,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.language,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    AppConstants.primaryColor,
                    AppConstants.secondaryColor,
                    AppConstants.tertiaryColor,
                  ],
                ).createShader(bounds),
                child: const Text(
                  'Flow Browser',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Workspace: ${provider.currentWorkspace.name}',
                style: TextStyle(
                  color: AppConstants.primaryColor.withOpacity(0.7),
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter a URL or search query above to start browsing',
                style: TextStyle(
                  color: AppConstants.primaryColor.withOpacity(0.5),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  if (settings.vpnEnabled)
                    _buildStatusChip(
                      Icons.shield,
                      'VPN Active',
                      AppConstants.tertiaryColor,
                    ),
                  if (settings.proxyEnabled)
                    _buildStatusChip(
                      Icons.shield,
                      'Proxy Active',
                      Colors.green,
                    ),
                  _buildStatusChip(
                    Icons.lock,
                    'Security: ${settings.securityLevel.toUpperCase()}',
                    AppConstants.primaryColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
