import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/browser_provider.dart';

class BrowserTabs extends StatelessWidget {
  const BrowserTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final browserProvider = Provider.of<BrowserProvider>(context);
    return Container(
      height: 40,
      color: Colors.grey[200],
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: browserProvider.tabs.length,
              itemBuilder: (context, index) {
                final tab = browserProvider.tabs[index];
                return GestureDetector(
                  onTap: () => browserProvider.selectTab(index),
                  child: Container(
                    width: 150,
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: browserProvider.currentTabIndex == index
                          ? Colors.white
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            tab.title ?? 'New Tab',
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 16),
                          onPressed: () => browserProvider.closeTab(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // New Tab Button
          Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.add, size: 20),
              onPressed: () => browserProvider.addTab(),
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
          ),
        ],
      ),
    );
  }
}