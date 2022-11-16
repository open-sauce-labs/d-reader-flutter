import 'package:d_reader_flutter/ui/widgets/common/layout/custom_sliver_tab_persisent_header.dart';
import 'package:d_reader_flutter/ui/widgets/common/search_bar_sliver.dart';
import 'package:flutter/material.dart';

class DiscoverView extends StatelessWidget {
  const DiscoverView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            const SearchBarSliver(),
            const CustomSliverTabPersistentHeader(
              tabs: [
                Tab(
                  child: Text(
                    'Comics',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    'Issues',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    'Creators',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ];
        },
        body: const TabBarView(
          children: [
            Center(
              child: Text('Comics'),
            ),
            Center(
              child: Text('Issues'),
            ),
            Center(
              child: Text('Creators'),
            ),
          ],
        ),
      ),
    );
  }
}
