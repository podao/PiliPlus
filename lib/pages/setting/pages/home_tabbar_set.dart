import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:PiliPlus/models/common/tab_type.dart';
import 'package:PiliPlus/utils/storage.dart';

class TabbarSetPage extends StatefulWidget {
  const TabbarSetPage({super.key});

  @override
  State<TabbarSetPage> createState() => _TabbarSetPageState();
}

class _TabbarSetPageState extends State<TabbarSetPage> {
  late List defaultTabs;
  late List<String> tabbarSort;

  @override
  void initState() {
    super.initState();
    defaultTabs = tabsConfig;
    tabbarSort = GStorage.tabbarSort;
    // 对 tabData 进行排序
    defaultTabs.sort((a, b) {
      int indexA = tabbarSort.indexOf((a['type'] as TabType).name);
      int indexB = tabbarSort.indexOf((b['type'] as TabType).name);

      // 如果类型在 sortOrder 中不存在，则放在末尾
      if (indexA == -1) indexA = tabbarSort.length;
      if (indexB == -1) indexB = tabbarSort.length;

      return indexA.compareTo(indexB);
    });
  }

  void saveEdit() {
    List<String> sortedTabbar = defaultTabs
        .where((i) => tabbarSort.contains((i['type'] as TabType).name))
        .map<String>((i) => (i['type'] as TabType).name)
        .toList();
    GStorage.setting.put(SettingBoxKey.tabbarSort, sortedTabbar);
    SmartDialog.showToast('保存成功，下次启动时生效');
  }

  void onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final tabsItem = defaultTabs.removeAt(oldIndex);
      defaultTabs.insert(newIndex, tabsItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    final listTiles = [
      for (int i = 0; i < defaultTabs.length; i++) ...[
        CheckboxListTile(
          key: Key(defaultTabs[i]['label']),
          value: tabbarSort.contains((defaultTabs[i]['type'] as TabType).name),
          onChanged: (bool? newValue) {
            String tabTypeId = (defaultTabs[i]['type'] as TabType).name;
            if (!newValue!) {
              tabbarSort.remove(tabTypeId);
            } else {
              tabbarSort.add(tabTypeId);
            }
            setState(() {});
          },
          title: Text(defaultTabs[i]['label']),
          secondary: const Icon(Icons.drag_indicator_rounded),
        )
      ]
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabbar编辑'),
        actions: [
          TextButton(onPressed: () => saveEdit(), child: const Text('保存')),
          const SizedBox(width: 12)
        ],
      ),
      body: ReorderableListView(
        onReorder: onReorder,
        footer: SizedBox(
          height: MediaQuery.of(context).padding.bottom + 30,
          child: const Align(
              alignment: Alignment.centerRight, child: Text('*长按拖动排序        ')),
        ),
        children: listTiles,
      ),
    );
  }
}
