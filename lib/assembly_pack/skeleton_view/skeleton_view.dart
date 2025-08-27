import 'package:flutter/material.dart';
import 'package:flutter_text/assembly_pack/db_test/user_db_provider.dart';
import 'package:flutter_text/init.dart';
import 'package:flutter_text/model/sql_user.dart';
import 'package:self_utils/widget/api_call_back.dart';
import 'package:self_utils/widget/skeleton.dart';

class SkeletonView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('骨架屏 test'),
      ),
      body: SkeletonPage(),
    );
  }
}

class SkeletonPage extends StatefulWidget {
  @override
  SkeletonPageState createState() => SkeletonPageState();
}

class SkeletonPageState extends State<SkeletonPage> {
  UserDbProvider provider = UserDbProvider();
  List<SqlUser> user = <SqlUser>[];
  late SkeletonManager<SqlUser> skeletonManager;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final SkeletonManager<SqlUser> r =
          SkeletonManager<SqlUser>((List<SqlUser> items) async {
        await  Future<void>.delayed(const Duration(seconds: 2));
        final List<SqlUser> list = await provider.getAllUser();
        setState(() {
          user = list;
        });
      });
      final int count = await provider.getTableCountsV2();
      setState(() {
        skeletonManager = r;
        for (int i = 0; i < count; i++) {
          user.add(SqlUser());
        }
      });
    } catch (error, stack) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: user.map((SqlUser e) {
            return SkeletonItem<SqlUser>(
              source: e,
              skeletonManager: skeletonManager,
              status: e.id != null
                  ? SkeletonStatus.loadDone
                  : SkeletonStatus.waitLoad,
              skeleton: (BuildContext context) => Container(
                child: Container(
                  padding: EdgeInsets.only(
                    top: screenUtil.adaptive(20),
                    left: screenUtil.adaptive(35),
                    bottom: screenUtil.adaptive(20),
                  ),
                  child: Container(
                    width: screenUtil.adaptive(100),
                    height: screenUtil.adaptive(30),
                    color: Colors.grey.withOpacity(0.3),
                  ),
                ),
              ),
              child: (BuildContext context) => Container(
                padding: EdgeInsets.only(
                  top: screenUtil.adaptive(20),
                  left: screenUtil.adaptive(35),
                  bottom: screenUtil.adaptive(20),
                ),
                child: Text(e.name??''),
              ),
            );
          }).toList(),
    );
  }
}
