import 'package:d_reader_flutter/core/models/creator.dart';
import 'package:d_reader_flutter/ui/shared/app_colors.dart';
import 'package:d_reader_flutter/ui/widgets/common/container_banner_background.dart';
import 'package:d_reader_flutter/ui/widgets/common/description_text.dart';
import 'package:d_reader_flutter/ui/widgets/creators/avatar.dart';
import 'package:d_reader_flutter/ui/widgets/creators/social_row.dart';
import 'package:d_reader_flutter/ui/widgets/creators/stats_box_row.dart';
import 'package:flutter/material.dart';

class HeaderSliverList extends StatelessWidget {
  final CreatorModel creator;
  const HeaderSliverList({
    super.key,
    required this.creator,
  });

  @override
  Widget build(BuildContext context) {
    print(creator.toString());
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Stack(
            children: [
              ContainerBannerBackground(banner: creator.banner),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: CreatorAvatar(avatar: creator.avatar),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                creator.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              const Icon(
                Icons.verified,
                color: dReaderYellow,
                size: 16,
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    width: 1,
                    color: dReaderSome,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.star_outline,
                      size: 20,
                      color: dReaderLightGrey,
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    Text(
                      'Follow',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: dReaderLightGrey,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 9),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          9,
                        ),
                        color: dReaderSome,
                      ),
                      child: Text(
                        '124',
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: dReaderLightGrey,
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                    )
                  ],
                ),
              ),
              const SocialRow(),
            ],
          ),
          const SizedBox(
            height: 32,
          ),
          const StatsBoxRow(
            totalVolume: 12,
            issuesCount: 5,
          ),
          const SizedBox(
            height: 24,
          ),
          DescriptionText(text: creator.description),
          const SizedBox(
            height: 24,
          ),
        ],
      ),
    );
  }
}
