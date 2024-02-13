import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_material_symbols/flutter_material_symbols.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';

import '../../../../runtime_models/bill/item/i_item_group.dart';
import '../../../../runtime_models/bill/bill_data.dart';
import '../../../../runtime_models/bill/split_rule.dart';
import '../../../../runtime_models/user/public_profile.dart';
import '../../../../utilities/person_icon.dart';
import 'edit_friend_split_dialog.dart';
import 'friend_involvement_checklist.dart';
import 'friend_involvement_checklist_form.dart';

class PeopleSubsection extends StatefulWidget {
  final IItemGroup itemGroup;

  const PeopleSubsection({super.key, required this.itemGroup});

  @override
  State<PeopleSubsection> createState() => _PeopleSubsectionState();
}

class _PeopleSubsectionState extends State<PeopleSubsection> {
  bool expandPeople = false;
  final int maxPersonIconCount = 6;

  @override
  Widget build(BuildContext context) {
    final splitBalances = widget.itemGroup.getSplitBalances;

    final sourcePrimarySplits = context
        .select<BillData, List<PublicProfile>>((value) => [value.payer!] + value.primarySplits);

    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text("People", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
          TextButton(
            onPressed: () async {
              final friendInvolvementChecklistForm = FriendInvolvementChecklistForm(
                friendInvolvements: {
                  for (var profile in sourcePrimarySplits)
                    profile: widget.itemGroup.primarySplits.contains(profile)
                },
              );

              await showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                builder: (context) => FriendInvolvementChecklist(
                  friendInvolvementChecklistForm: friendInvolvementChecklistForm,
                ),
              );

              widget.itemGroup.primarySplits = friendInvolvementChecklistForm
                  .friendInvolvements.entries
                  .where((entry) => entry.value)
                  .map((entry) => entry.key)
                  .toList();

              setState(() {});
            },
            child: const Text('Edit'),
          ),
        ]),
        const SizedBox(height: 8),
        ExpansionTileCard(
          //TODO: Design advice required here
          //onExpansionChanged: (isExpanded) => setState(() => expandPeople = isExpanded),
          borderRadius: const BorderRadius.all(Radius.circular(12.0)),
          baseColor: Theme.of(context).colorScheme.secondaryContainer,
          expandedColor: Theme.of(context).colorScheme.surfaceVariant,
          elevation: 0,
          title: expandPeople
              ? const SizedBox.shrink()
              : Row(children: [
                  RowSuper(
                    innerDistance: -10,
                    children: widget.itemGroup.primarySplits
                        .sublist(0, min(widget.itemGroup.primarySplits.length, maxPersonIconCount))
                        .map((profile) => PersonIcon(profile: profile))
                        .toList(),
                  ),
                  widget.itemGroup.primarySplits.length > maxPersonIconCount
                      ? const Padding(
                          padding: EdgeInsets.only(left: 5),
                          child: Icon(Icons.keyboard_control),
                        )
                      : const SizedBox.shrink(),
                ]),
          children: [
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              //padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              scrollDirection: Axis.vertical,
              itemCount: widget.itemGroup.primarySplits.length,
              itemBuilder: (context, index) {
                final currentProfile = widget.itemGroup.primarySplits[index];

                // ? Are we making this list slidable? If not, remove.
                return Slidable(
                  closeOnScroll: false,
                  startActionPane: ActionPane(
                    motion: const BehindMotion(),
                    extentRatio: 0.2,
                    children: [
                      SlidableAction(
                        onPressed: ((context) {}),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        borderRadius: BorderRadius.only(
                          //topLeft: Radius.circular(index == 0 ? 25 : 0),
                          bottomLeft: Radius.circular(
                              index == widget.itemGroup.primarySplits.length - 1 ? 12 : 0),
                        ),
                        icon: MaterialSymbols.check,
                      ),
                    ],
                  ),
                  child: ListTile(
                    onTap: () async {
                      if (widget.itemGroup.splitRule != SplitRule.even) {
                        await showDialog(
                          context: context,
                          builder: (context) => EditFriendSplitDialog(
                              profile: currentProfile, itemGroup: widget.itemGroup),
                        );
                        setState(() {});
                      }
                    },
                    leading: PersonIcon(profile: currentProfile),
                    title: Column(children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Expanded(
                            child: Text(
                          currentProfile.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )),
                        //const Spacer(),
                        const SizedBox(width: 16),
                        SizedBox(
                            width: 80,
                            child: Text(
                              switch (widget.itemGroup.splitRule) {
                                SplitRule.even => 'Even',
                                SplitRule.byPercentage =>
                                  '${(widget.itemGroup.splitPercentages[currentProfile.uid]! * 100).toStringAsPrecision(4)}%',
                                SplitRule.byShares =>
                                  '${widget.itemGroup.splitShares[currentProfile.uid]}x',
                                _ => '',
                              },
                              textAlign: TextAlign.right,
                            )),
                      ]),
                      //const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '\$${splitBalances[currentProfile.uid]?.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ]),
                    trailing: const Icon(MaterialSymbols.arrow_right),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(height: 2, indent: 16, endIndent: 16),
            ),
          ],
        ),

        // Original container for expansion tile card content
        // Container(
        //   clipBehavior: Clip.hardEdge,
        //   decoration: BoxDecoration(
        //       borderRadius: const BorderRadius.all(Radius.circular(25.0)),
        //       color: Theme.of(context).colorScheme.surfaceVariant),
        // ),
      ],
    );
  }
}
