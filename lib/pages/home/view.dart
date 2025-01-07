import 'dart:async';

import 'package:PiliPlus/pages/mine/controller.dart';
import 'package:PiliPlus/utils/extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:PiliPlus/common/widgets/network_img_layer.dart';
import 'package:PiliPlus/utils/feed_back.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import './controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  final HomeController _homeController = Get.put(HomeController());
  late Stream<bool> stream;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    stream = _homeController.searchBarStream.stream;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: Column(
        children: [
          if (!_homeController.useSideBar)
            CustomAppBar(
              stream: _homeController.hideSearchBar
                  ? stream
                  : StreamController<bool>.broadcast().stream,
              homeController: _homeController,
            ),
          if (_homeController.tabs.length > 1) ...[
            ...[
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: Align(
                  alignment: Alignment.center,
                  child: TabBar(
                    controller: _homeController.tabController,
                    tabs: [
                      for (var i in _homeController.tabs) Tab(text: i['label'])
                    ],
                    isScrollable: true,
                    dividerColor: Colors.transparent,
                    enableFeedback: true,
                    splashBorderRadius: BorderRadius.circular(10),
                    tabAlignment: TabAlignment.center,
                    onTap: (value) {
                      feedBack();
                      if (_homeController.tabController.indexIsChanging.not) {
                        _homeController.tabsCtrList[value]().animateToTop();
                      }
                    },
                  ),
                ),
              ),
            ],
          ] else ...[
            const SizedBox(height: 6),
          ],
          Expanded(
            child: TabBarView(
              controller: _homeController.tabController,
              children: _homeController.tabsPageList,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final Stream<bool>? stream;
  final HomeController homeController;

  const CustomAppBar({
    super.key,
    this.height = kToolbarHeight,
    this.stream,
    required this.homeController,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stream,
      initialData: true,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return AnimatedOpacity(
          opacity: snapshot.data ? 1 : 0,
          duration: const Duration(milliseconds: 300),
          child: AnimatedContainer(
            curve: Curves.easeInOutCubicEmphasized,
            duration: const Duration(milliseconds: 500),
            height: snapshot.data ? 52 : 0,
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
            child: SearchBarAndUser(
              homeController: homeController,
            ),
          ),
        );
      },
    );
  }
}

class SearchBarAndUser extends StatelessWidget {
  const SearchBarAndUser({
    super.key,
    required this.homeController,
  });

  final HomeController homeController;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SearchBar(homeController: homeController),
        const SizedBox(width: 4),
        Obx(() => homeController.userLogin.value
            ? ClipRect(
                child: IconButton(
                  tooltip: '消息',
                  onPressed: () => Get.toNamed('/whisper'),
                  icon: const Icon(
                    Icons.notifications_none,
                  ),
                ),
              )
            : const SizedBox.shrink()),
        const SizedBox(width: 8),
        Semantics(
          label: "我的",
          child: Obx(
            () => homeController.userLogin.value
                ? Stack(
                    clipBehavior: Clip.none,
                    children: [
                      NetworkImgLayer(
                        type: 'avatar',
                        width: 34,
                        height: 34,
                        src: homeController.userFace.value,
                      ),
                      Positioned.fill(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () =>
                                homeController.showUserInfoDialog(context),
                            splashColor: Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withOpacity(0.3),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(50),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: -6,
                        bottom: -6,
                        child: Obx(() => MineController.anonymity.value
                            ? IgnorePointer(
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    size: 16,
                                    MdiIcons.incognito,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondaryContainer,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink()),
                      ),
                    ],
                  )
                : DefaultUser(
                    onPressed: () => homeController.showUserInfoDialog(context),
                  ),
          ),
        ),
      ],
    );
  }
}

class UserAndSearchVertical extends StatelessWidget {
  const UserAndSearchVertical({
    super.key,
    required this.ctr,
  });

  final HomeController ctr;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Semantics(
          label: "我的",
          child: Obx(
            () => ctr.userLogin.value
                ? Stack(
                    clipBehavior: Clip.none,
                    children: [
                      NetworkImgLayer(
                        type: 'avatar',
                        width: 34,
                        height: 34,
                        src: ctr.userFace.value,
                      ),
                      Positioned.fill(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => ctr.showUserInfoDialog(context),
                            splashColor: Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withOpacity(0.3),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(50),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: -6,
                        bottom: -6,
                        child: Obx(() => MineController.anonymity.value
                            ? IgnorePointer(
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    size: 16,
                                    MdiIcons.incognito,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondaryContainer,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink()),
                      ),
                    ],
                  )
                : DefaultUser(onPressed: () => ctr.showUserInfoDialog(context)),
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => ctr.userLogin.value
            ? IconButton(
                tooltip: '消息',
                onPressed: () => Get.toNamed('/whisper'),
                icon: const Icon(Icons.notifications_none),
              )
            : const SizedBox.shrink()),
        IconButton(
          icon: const Icon(
            Icons.search_outlined,
            semanticLabel: '搜索',
          ),
          onPressed: () => Get.toNamed('/search'),
        ),
      ],
    );
  }
}

class DefaultUser extends StatelessWidget {
  const DefaultUser({super.key, required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38,
      height: 38,
      child: IconButton(
        tooltip: '默认用户头像',
        style: ButtonStyle(
          padding: WidgetStateProperty.all(EdgeInsets.zero),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            return Theme.of(context).colorScheme.onInverseSurface;
          }),
        ),
        onPressed: onPressed,
        icon: Icon(
          Icons.person_rounded,
          size: 22,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

// class CustomTabs extends StatefulWidget {
//   const CustomTabs({super.key});

//   @override
//   State<CustomTabs> createState() => _CustomTabsState();
// }

// class _CustomTabsState extends State<CustomTabs> {
//   final HomeController _homeController = Get.put(HomeController());

//   void onTap(int index) {
//     feedBack();
//     if (_homeController.initialIndex.value == index) {
//       _homeController.tabsCtrList[index]().animateToTop();
//     }
//     _homeController.initialIndex.value = index;
//     _homeController.tabController.index = index;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 44,
//       margin: const EdgeInsets.only(top: 4),
//       child: Obx(
//         () => ListView.separated(
//           padding: const EdgeInsets.symmetric(horizontal: 14.0),
//           scrollDirection: Axis.horizontal,
//           itemCount: _homeController.tabs.length,
//           separatorBuilder: (BuildContext context, int index) {
//             return const SizedBox(width: 10);
//           },
//           itemBuilder: (BuildContext context, int index) {
//             String label = _homeController.tabs[index]['label'];
//             return Obx(
//               () => CustomChip(
//                 onTap: () => onTap(index),
//                 label: label,
//                 selected: index == _homeController.initialIndex.value,
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

class CustomChip extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  final bool selected;
  const CustomChip({
    super.key,
    required this.onTap,
    required this.label,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorTheme = Theme.of(context).colorScheme;
    final TextStyle chipTextStyle = selected
        ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)
        : const TextStyle(fontSize: 13);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    const VisualDensity visualDensity =
        VisualDensity(horizontal: -4.0, vertical: -2.0);
    return InputChip(
      side: selected
          ? BorderSide(
              color: colorScheme.secondary.withOpacity(0.2),
              width: 2,
            )
          : BorderSide.none,
      // backgroundColor: colorTheme.primaryContainer.withOpacity(0.1),
      // selectedColor: colorTheme.secondaryContainer.withOpacity(0.8),
      color: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
        return colorTheme.secondaryContainer.withOpacity(0.6);
      }),
      padding: const EdgeInsets.fromLTRB(6, 1, 6, 1),
      label: Text(label, style: chipTextStyle),
      onPressed: onTap,
      selected: selected,
      showCheckmark: false,
      visualDensity: visualDensity,
    );
  }
}

class SearchBar extends StatelessWidget {
  const SearchBar({
    super.key,
    required this.homeController,
  });

  final HomeController homeController;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        width: 250,
        height: 44,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
        ),
        child: Material(
          color: colorScheme.onSecondaryContainer.withOpacity(0.05),
          child: InkWell(
            splashColor: colorScheme.primaryContainer.withOpacity(0.3),
            onTap: () => Get.toNamed(
              '/search',
              parameters: {
                if (homeController.enableSearchWord)
                  'hintText': homeController.defaultSearch.value,
              },
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                Icon(
                  Icons.search_outlined,
                  color: colorScheme.onSecondaryContainer,
                  semanticLabel: '搜索',
                ),
                const SizedBox(width: 10),
                if (homeController.enableSearchWord) ...[
                  Expanded(
                    child: Obx(
                      () => Text(
                        homeController.defaultSearch.value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: colorScheme.outline),
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
