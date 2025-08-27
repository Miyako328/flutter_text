import 'package:flutter/material.dart';
import 'package:self_utils/utils/screen.dart';
import 'package:self_utils/widget/search_field.dart';

/// 搜索 demo

class SearchDemoPage extends StatefulWidget {

  @override
  _SearchDemoPageState createState() => _SearchDemoPageState();
}

class _SearchDemoPageState extends State<SearchDemoPage> {
  final List<String> _suggestions = [
    'United States',
    'Germany',
    'Washington',
    'Paris',
    'Jakarta',
    'Australia',
    'India',
    'Czech Republic',
    'Lorem Ipsum',
  ];
  final List<String> _statesOfIndia = [
    'Andhra Pradesh',
    'Assam',
    'Arunachal Pradesh',
    'Bihar',
    'Goa',
    'Gujarat',
    'Jammu and Kashmir',
    'Jharkhand',
    'West Bengal',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Orissa',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Tripura',
    'Uttaranchal',
    'Uttar Pradesh',
    'Haryana',
    'Himachal Pradesh',
    'Chhattisgarh'
  ];
  final _formKey = GlobalKey<FormState>();

  final _searchController = TextEditingController();

  @override
  void dispose() {
    if (mounted) {
      setState(() {});
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("请搜索"), actions: <Widget>[
        IconButton(icon: Icon(Icons.search), onPressed: () {
          showSearch(context: context, delegate: SearchBarDelegate());
        },)
      ],),
      body: ListView(
        children: <Widget>[
          SizedBox(
            height: 20,
          ),

          Container(
            width: 200,
            child: SearchField(
              suggestions: _suggestions,
              controller: _searchController,
              width: screenUtil.adaptive(200),
              hint: 'SearchField Sample 1',
              searchInputDecoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black.withOpacity(0.8),
                  ),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
              ),
              initialValue: _suggestions[2],
              maxSuggestionsInViewPort: 4,
              itemHeight: 45,
              onTap: (x) {
                print('selected =$x ${_searchController.text}');
              },
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey,
              child: Container(
                width: screenUtil.adaptive(200),
                child: SearchField(
                  suggestions: _statesOfIndia,
                  hint: 'SearchField Sample 2',
                  searchStyle: TextStyle(
                    fontSize: 16,
                    color: Colors.black.withOpacity(0.8),
                  ),
                  validator: (String? x) {
                    if (!_statesOfIndia.contains(x) || x?.isEmpty == true) {
                      return 'Please Enter a valid State';
                    }
                    return '';
                  },
                  searchInputDecoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black.withOpacity(0.8),
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                  ),
                  maxSuggestionsInViewPort: 6,
                  itemHeight: 50,
                  onTap: (x) {
                    print(x);
                  },
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SearchField(
              maxSuggestionsInViewPort: 5,
              itemHeight: 40,
              hint: 'SearchField Sample 3',
              suggestionsDecoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8.0),
                  bottomRight: Radius.circular(8),
                ),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.5),
                ),
              ),
              suggestionItemDecoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xff9D50BB).withOpacity(0.5),
                    Color(0xff6E48AA).withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              searchInputDecoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.withOpacity(0.2),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.white,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                border: OutlineInputBorder(),
              ),
              marginColor: Colors.white,
              suggestions: _suggestions,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SearchField(
              suggestionStyle: TextStyle(color: Colors.green),
              suggestionItemDecoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                gradient: LinearGradient(colors: [
                  Color(0xff70e1f5),
                  Color(0xffffd194),
                ], begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
              suggestions: _suggestions,
              searchInputDecoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                labelText: 'SearchField',
                border: OutlineInputBorder(),
              ),
              // hasOverlay: false,
              hint: 'SearchField Sample 4',
              maxSuggestionsInViewPort: 4,
              itemHeight: 45,
              onTap: (x) {
                print(x);
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Color(0xffffffff),
              border: Border.all(
                color: Color(0xE6797979),
                width: 1.0,
              ),
            ),
            child: SearchField(
              suggestions: _suggestions,
              controller: _searchController,
              width: screenUtil.adaptive(200),
              textHeight: screenUtil.adaptive(30),
              hint: 'SearchField Sample 1',
              initialValue: _suggestions[2],
              maxSuggestionsInViewPort: 4,
              itemHeight: screenUtil.adaptive(30),
              onTap: (x) {
                print('selected =$x ${_searchController.text}');
              },
            ),
          ),

          Container(
            child: Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.only(
                      top: screenUtil.adaptive(15),
                      bottom: screenUtil.adaptive(10)),
                  child: Text(
                    '价格',
                    style: TextStyle(
                        color: Color(0xBFffffff),
                        fontSize: screenUtil.adaptive(18)),
                  ),
                ),
                Container(decoration: BoxDecoration(
                  color: Color(0xffffffff),
                  border: Border.all(
                    color: Color(0xE6797979),
                    width: 1.0,
                  ),
                ),
                  child: SearchField(
                    suggestions: _suggestions,
                    controller: _searchController,
                    width: screenUtil.adaptive(122),
                    initialValue: _suggestions[2],
                    maxSuggestionsInViewPort: 3,
                    textHeight: screenUtil.adaptive(30),
                    itemHeight: screenUtil.adaptive(30),
                    onTap: (x) {
                      print('selected =$x ${_searchController.text}');
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.3,
                vertical: 10),
            child: ElevatedButton(
                onPressed: () {
                  _formKey.currentState?.validate();
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Validate Field 2'),
                )),
          )
        ],
      ),
    );
  }
}

class SearchBarDelegate extends SearchDelegate<String> {
  // 搜索条右侧的按钮执行方法，我们在这里方法里放入一个clear图标。 当点击图片时，清空搜索的内容。
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(icon: Icon(Icons.clear), onPressed: () {
        // 清空搜索内容
        query = "";
      },)
    ];
  }

  // 搜索栏左侧的图标和功能，点击时关闭整个搜索页面
  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
      onPressed: () {
        close(context, "");
      },
    );
  }

  // 搜索到内容了
  @override
  Widget buildResults(BuildContext context) {
    return Container(
      child: Center(
        child: Text("搜索的结果：$query"),
      ),
    );
  }

  // 输入时的推荐及搜索结果
  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty ? recentList : searchList.where((
        input) => input.startsWith(query)).toList();
    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        // 创建一个富文本，匹配的内容特别显示
        return ListTile(title: RichText(text: TextSpan(
          text: suggestionList[index].substring(0, query.length),
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold),
          children: [
            TextSpan(
                text: suggestionList[index].substring(query.length),
                style: TextStyle(color: Colors.grey)
            )
          ],)),
          onTap: (){
            query = suggestionList[index];
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(query)));
          },
        );
      },
    );
  }
}

///================= 模拟后台数据 ========================
const searchList = [
  "搜索结果数据1-aa",
  "搜索结果数据2-bb",
  "搜索结果数据3-cc",
  "搜索结果数据4-dd",
  "搜索结果数据5-ee",
  "搜索结果数据6-ff",
  "搜索结果数据7-gg",
  "搜索结果数据8-hh"
];

const recentList = [
  "推荐结果1-ii",
  "推荐结果2-jj",
  "推荐结果3-kk",
  "推荐结果4-ll",
  "推荐结果5-mm",
  "推荐结果6-nn",
  "推荐结果7-oo",
  "推荐结果8-pp",
];