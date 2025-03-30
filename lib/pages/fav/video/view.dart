import 'package:PiliPlus/common/skeleton/video_card_h.dart';
import 'package:PiliPlus/common/widgets/refresh_indicator.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:PiliPlus/common/widgets/http_error.dart';
import 'package:PiliPlus/pages/fav/video/index.dart';
import 'package:PiliPlus/pages/fav/video/widgets/item.dart';

import '../../../common/constants.dart';
import '../../../utils/grid.dart';

class FavVideoPage extends StatefulWidget {
  const FavVideoPage({super.key});

  @override
  State<FavVideoPage> createState() => _FavVideoPageState();
}

class _FavVideoPageState extends State<FavVideoPage>
    with AutomaticKeepAliveClientMixin {
  final FavController _favController = Get.find<FavController>();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return refreshIndicator(
      onRefresh: () async {
        await _favController.onRefresh();
      },
      child: CustomScrollView(
        controller: _favController.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          Obx(
            () => _buildBody(_favController.loadingState.value),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(LoadingState loadingState) {
    return switch (loadingState) {
      Loading() => SliverGrid(
          gridDelegate: SliverGridDelegateWithExtentAndRatio(
            mainAxisSpacing: 2,
            maxCrossAxisExtent: Grid.mediumCardWidth * 2,
            childAspectRatio: StyleString.aspectRatio * 2.2,
          ),
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return const VideoCardHSkeleton();
            },
            childCount: 10,
          ),
        ),
      Success() => (loadingState.response as List?)?.isNotEmpty == true
          ? SliverPadding(
              padding: EdgeInsets.only(
                top: StyleString.safeSpace - 5,
                bottom: 80 + MediaQuery.paddingOf(context).bottom,
              ),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithExtentAndRatio(
                  mainAxisSpacing: 2,
                  maxCrossAxisExtent: Grid.mediumCardWidth * 2,
                  childAspectRatio: StyleString.aspectRatio * 2.2,
                ),
                delegate: SliverChildBuilderDelegate(
                  childCount: loadingState.response.length,
                  (BuildContext context, int index) {
                    if (index == loadingState.response.length - 1) {
                      _favController.onLoadMore();
                    }
                    String heroTag =
                        Utils.makeHeroTag(loadingState.response[index].fid);
                    return FavItem(
                      heroTag: heroTag,
                      favFolderItem: loadingState.response[index],
                      onTap: () async {
                        dynamic res = await Get.toNamed(
                          '/favDetail',
                          arguments: loadingState.response[index],
                          parameters: {
                            'heroTag': heroTag,
                            'mediaId':
                                loadingState.response[index].id.toString(),
                          },
                        );
                        if (res == true) {
                          List list =
                              (_favController.loadingState.value as Success)
                                  .response;
                          list.removeAt(index);
                          _favController.loadingState.value =
                              LoadingState.success(list);
                        } else {
                          Future.delayed(const Duration(milliseconds: 255), () {
                            _favController.onRefresh();
                          });
                        }
                      },
                    );
                  },
                ),
              ),
            )
          : HttpError(
              callback: _favController.onReload,
            ),
      Error() => HttpError(
          errMsg: loadingState.errMsg,
          callback: _favController.onReload,
        ),
      LoadingState() => throw UnimplementedError(),
    };
  }
}
