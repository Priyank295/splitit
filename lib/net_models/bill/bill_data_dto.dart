import 'package:freezed_annotation/freezed_annotation.dart';

import '../../runtime_models/bill/bill_data.dart';
import '../../runtime_models/bill/modules/bill_module_tax.dart';
import '../../runtime_models/bill/modules/bill_module_tip.dart';
import '../../runtime_models/user/user_data.dart';
import 'everything_else_item_group_dto.dart';

part 'bill_data_dto.freezed.dart';
part 'bill_data_dto.g.dart';

@freezed
class BillDataDTO with _$BillDataDTO {
  // ignore: invalid_annotation_target
  @JsonSerializable(explicitToJson: true)
  factory BillDataDTO({
    required DateTime dateTime,
    required String name,
    required double totalSpent,
    //
    required String payerUid,
    required List<String> primarySplits,
    required Map<String, double> splitBalances,
    required Map<String, double> paymentResolveStatuses,
    //
    required EverythingElseItemGroupDTO everythingElse,
    //
    required DateTime lastUpdatedSession,
  }) = _BillDataDTO;

  factory BillDataDTO.fromJson(Map<String, dynamic> json) => _$BillDataDTOFromJson(json);

  BillDataDTO._();

  BillData toRuntimeObj(String uid, UserData userData) {
    BillData billData = BillData(
      uid: uid,
      dateTime: dateTime,
      name: name,
      totalSpent: totalSpent,
      payer: userData.publicProfile, //TODO: search database correctly
      primarySplits: primarySplits.map((uid) => userData.nonRegisteredFriends[uid]!).toList(),
      splitBalances: splitBalances
          .map((uid, balance) => MapEntry(userData.nonRegisteredFriends[uid]!, balance)),
      paymentResolveStatuses: paymentResolveStatuses.map(
          (uid, resolveStatus) => MapEntry(userData.nonRegisteredFriends[uid]!, resolveStatus)),
      everythingElse: everythingElse.toRuntimeObj(userData),
      itemGroups: List.empty(growable: true),
      taxModule: BillModule_Tax(),
      tipModule: BillModule_Tip(),
      lastUpdatedSession: lastUpdatedSession,
    );

    billData.everythingElse.billData = billData;

    return billData;
  }
}
