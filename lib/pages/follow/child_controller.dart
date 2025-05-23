import 'package:PiliPlus/http/follow.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/member.dart';
import 'package:PiliPlus/models/follow/result.dart';
import 'package:PiliPlus/pages/common/common_list_controller.dart';
import 'package:PiliPlus/pages/follow/controller.dart';
import 'package:get/get.dart';

enum OrderType { def, attention }

extension OrderTypeExt on OrderType {
  String get type => const ['', 'attention'][index];
  String get title => const ['最近关注', '最常访问'][index];
}

class FollowChildController
    extends CommonListController<FollowDataModel, FollowItemModel> {
  FollowChildController(this.controller, this.mid, this.tagid);
  final FollowController? controller;
  final int? tagid;
  final int mid;

  late final Rx<OrderType> orderType = OrderType.def.obs;

  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  @override
  List<FollowItemModel>? getDataList(FollowDataModel response) {
    return response.list;
  }

  @override
  bool customHandleResponse(bool isRefresh, Success<FollowDataModel> response) {
    if (controller != null) {
      try {
        if (controller!.isOwner &&
            tagid == null &&
            isRefresh &&
            controller!.followState.value is Success) {
          controller!.tabs[0].count = response.response.total;
          controller!.tabs.refresh();
        }
      } catch (_) {}
    }
    return false;
  }

  @override
  Future<LoadingState<FollowDataModel>> customGetData() {
    if (tagid != null) {
      return MemberHttp.followUpGroup(mid, tagid, currentPage, 20);
    }

    return FollowHttp.followingsNew(
      vmid: mid,
      pn: currentPage,
      ps: 20,
      orderType: orderType.value.type,
    );
  }
}
