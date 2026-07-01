import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:self_utils/init.dart';

class Solution {
  /// 暴力破解
  static List<int> sortedSquares(List<int> nums) {
    List<int> result = <int>[];
    result = nums.map((e) => e * e).toList();
    result.sort((a, b) => a - b);

    return result;
  }

  /// 双指针解法
  static List<int> sortedSquaresSec(List<int> nums) {
    List<int> result = List.filled(nums.length, 0);
    int i = 0;
    int j = nums.length - 1;
    int k = nums.length - 1;
    for (; i <= j;) {
      if (nums[i] * nums[i] > nums[j] * nums[j]) {
        result[k] = nums[i] * nums[i];
        k--;
        i++;
      } else {
        result[k] = nums[j] * nums[j];
        k--;
        j--;
      }
    }

    return result;
  }

  /// 暴力解法不可取，超出长度了
  static List<int> addToArrayForm(List<int> num, int k) {
    List<int> result = <int>[];
    String f = '';
    for (var e in num) {
      f = f + e.toString();
    }
    final r = int.parse(f) + k;
    result = r.toString().split('').map((e) => int.parse(e)).toList();

    return result;
  }

  /// 逐位相加
  static List<int> addToArrayFormSec(List<int> num, int k) {
    List<int> result = <int>[];
    final int n = num.length;
    for (int i = n - 1; i >= 0 || k > 0; --i, k = k ~/ 10) {
      if (i >= 0) {
        k += num[i];
      }
      result.add(k % 10);
    }
    result = result.reversed.toList();
    return result;
  }

  /// todo map方法和ascii使用
  /// String.fromCharCode(i) ascii码的转译
  ///
  static List<String> commonChars(List<String> words) {
    List<String> result = [];
    Map<String, dynamic> hashWords = {};

    for (int i = 97; i < 123; i++) {
      hashWords[String.fromCharCode(i)] = 0;
    }

    final String first = words.first;
    first.split('').forEach((element) {
      if (hashWords.keys.contains(element) == true) {
        hashWords[element] += 1;
      }
    });

    for (int j = 1; j < words.length; j++) {
      final Map<String, dynamic> test = {};
      for (int i = 97; i < 123; i++) {
        test[String.fromCharCode(i)] = 0;
      }

      words[j].split('').forEach((element) {
        if (test.keys.contains(element) == true) {
          test[element] += 1;
        }
      });

      hashWords.forEach((key, value) {
        hashWords[key] = min(value as int, test[key] as int);
      });
    }

    hashWords.forEach((key, value) {
      for (int v = 0; v < value; v++) {
        result.add(key);
      }
    });

    return result;
  }

  static int largestSumAfterKNegations(List<int> nums, int k) {
    int result = 0;

    for (int i = 0; i < k; i++) {
      nums.sort((a, b) => a - b);
      nums[0] = -nums[0];
    }

    nums.map((e) => result += e).toList();
    return result;
  }

  /// toRadixString 进制转换
  /// int.parse radix 定义进制
  static int bitwiseComplement(int n) {
    late int result;
    String twoWise = n.toRadixString(2);
    List<String> wiseList = twoWise.split('');
    for (int i = 0; i < wiseList.length; i++) {
      if (wiseList[i] == '1') {
        wiseList[i] = '0';
      } else {
        wiseList[i] = '1';
      }
    }
    String tenWise = int.parse(wiseList.join(''), radix: 2).toRadixString(10);
    result = int.parse(tenWise);
    return result;
  }

  /// 本地没遇到问题，但跑不过leetcode测试
  static bool canThreePartsEqualSum(List<int> arr) {
    int sum = 0;
    for (int val in arr) {
      sum += val;
    }

    if (sum % 3 == 0) {
      int times = 0;
      while (times < 3) {
        int i = 0;
        int partSum = 0;
        for (int j = i; j < arr.length; j++) {
          partSum += arr[j];
          if (times < 2) {
            if (partSum == sum / 3) {
              i = j;
              times++;
              partSum = 0;
              continue;
            }
          } else if (j == arr.length - 1) {
            if (partSum == sum / 3) {
              i = j;
              times++;
              partSum = 0;
              break;
            } else {
              return false;
            }
          }
        }
      }
      return true;
    } else {
      return false;
    }
  }

  /// 超出整数范围
  static List<bool> prefixesDivBy5(List<int> nums) {
    List<bool> result = [];
    String numString = '';
    for (var element in nums) {
      numString += '$element';
      int val = int.parse(int.parse(numString, radix: 2).toRadixString(10));
      if (val % 5 == 0) {
        result.add(true);
      } else {
        result.add(false);
      }
    }

    return result;
  }

  /// 移位运算符
  /// 直接计算会溢出，每次只保存余数
  static List<bool> prefixesDivBy5Sec(List<int> nums) {
    List<bool> result = [];
    int val = 0;
    for (var element in nums) {
      print(((val << 1) + element));
      val = ((val << 1) + element) % 5;
      if (val == 0) {
        result.add(true);
      } else {
        result.add(false);
      }
    }

    return result;
  }

  /// 堆栈
  static String removeOuterParentheses(String s) {
    String result = '';
    List<String> list = [];
    s.split('').forEach((element) {
      if (element == ')') {
        list.removeLast();
      }
      if (list.isNotEmpty) {
        result += element;
      }
      if (element == '(') {
        list.add(element);
      }
    });
    return result;
  }

  /// 数学方法 -- 直线方程
  static bool isBoomerang(List<List<int>> points) {
    late bool result;
    if ((points[1][1] - points[0][1]) * (points[2][0] - points[0][0]) ==
        (points[1][0] - points[0][0]) * (points[2][1] - points[0][1])) {
      result = false;
    } else {
      result = true;
    }

    return result;
  }

  /// 排序 计算 删减 循环以上操作
  static int lastStoneWeight(List<int> stones) {
    int result = 0;
    while (stones.length > 1) {
      stones.sort((a, b) => b - a);
      int val = stones[0] - stones[1];
      if (val != 0) {
        stones.add(val);
      }
      stones.removeRange(0, 2);
    }
    result = stones.isNotEmpty ? stones[0] : 0;
    return result;
  }

  /// 堆栈
  static String removeDuplicates(String s) {
    String result = '';
    List<String> stack = [];
    s.split('').forEach((element) {
      /// 如果栈stack不为空，且栈stack最后一个跟element值相同，就remove掉，否则添加进堆栈上
      if (stack.isNotEmpty == true && stack[stack.length - 1] == element) {
        stack.removeAt(stack.length - 1);
      } else {
        stack.add(element);
      }
    });
    result = stack.join('');
    return result;
  }

  /// 数组对比（深浅拷贝）
  /// 浅拷贝直接赋值，深拷贝使用List.from
  /// 同样Map类型的深拷贝使用Map.from，然后copyWithList
  static int heightChecker(List<int> heights) {
    int result = 0;
    List<int> newList = List.from(heights);
    newList.sort((a, b) => a - b);
    for (int i = 0; i < heights.length; i++) {
      if (newList[i] != heights[i]) {
        result++;
      }
    }
    return result;
  }

  static List<String> findOcurrences(String text, String first, String second) {
    List<String> result = [];
    List<String> textList = text.split(' ');
    int i = 0;
    while (i < textList.length - 2) {
      if (textList[i] == first && textList[i + 1] == second) {
        result.add(textList[i + 2]);
      }
      i++;
    }

    return result;
  }

  static List<int> distributeCandies(int candies, int num_people) {
    List<int> result = List.filled(num_people, 0);
    int fin = candies;
    int i = 1;
    while (fin > 0) {
      for (int j = 0; j < result.length; j++) {
        result[j] += i;
        fin -= i;
        i++;
        if (fin < i) {
          i = fin;
        }
      }
    }
    return result;
  }

  /// 每次只存数组前三的值
  static int tribonacci(int n) {
    int result = 0;
    List<int> sumRes = [0, 1, 1, 0];
    for (int i = 0; i < n - 2; i++) {
      int sum = 0;
      sumRes.map((e) => sum += e).toList();
      sumRes[3] = sum;
      sumRes.removeRange(0, 1);
      sumRes.add(0);
    }
    result = n > 2 ? sumRes[2] : sumRes[n];
    return result;
  }

  /// 超出时间限制
  static int dayOfYear(String date) {
    int result = 0;
    List<int> dateList = date.split('-').map((e) => int.parse(e)).toList();
    List<int> mouth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    if (dateList[0] % 4 == 0) {
      mouth[1] = 29;
    }

    for (int i = 0; i < dateList[1] - 1; i++) {
      result += mouth[i];
    }

    result += dateList[2];

    return result;
  }

  static int distanceBetweenBusStops(
      List<int> distance, int start, int destination) {
    int result = 0;
    int sum = 0;
    distance.map((e) => sum += e).toList();
    if (start > destination) {
      distance.getRange(destination, start).map((e) => result += e).toList();
    } else {
      distance.getRange(start, destination).map((e) => result += e).toList();
    }

    return min(result, sum - result);
  }

  static String dayOfTheWeek(int day, int month, int year) {
    String result = '';
    DateTime dateTime = DateTime(year, month, day);
    switch (dateTime.weekday) {
      case 1:
        result = 'Monday';
        break;
      case 2:
        result = 'Tuesday';
        break;
      case 3:
        result = 'Wednesday';
        break;
      case 4:
        result = 'Thursday';
        break;
      case 5:
        result = 'Friday';
        break;
      case 6:
        result = 'Saturday';
        break;
      case 7:
        result = 'Sunday';
        break;
    }
    return result;
  }

  static List<List<int>> minimumAbsDifference(List<int> arr) {
    List<List<int>> result = [];
    arr.sort((a, b) => a - b);
    int miniAbs = arr[1] - arr[0];
    for (int i = 1; i < arr.length; i++) {
      if (arr[i] - arr[i - 1] < miniAbs) {
        miniAbs = arr[i] - arr[i - 1];
        result.clear();
      }
      if (arr[i] - arr[i - 1] == miniAbs) {
        result.add([arr[i - 1], arr[i]]);
      }
    }

    return result;
  }

  /// 第一个map记录每个数字出现的次数，第二个map记录每个次数出现的次数。然后比较
  static bool uniqueOccurrences(List<int> arr) {
    Map<int, dynamic> map = {};
    for (var element in arr) {
      if (map.containsKey(element) == true) {
        map[element] += 1;
      } else {
        map[element] = 1;
      }
    }

    Map<int, dynamic> set = {};
    map.forEach((key, value) {
      if (set.containsKey(value) == true) {
        set[value]++;
      } else {
        set[value] = 1;
      }
    });

    return set.length == map.length;
  }

  /// 堆栈
  static int balanceStringSplit(String s) {
    int result = 0;
    List<String> arr = [];
    for (var val in s.split('')) {
      arr.add(val);
      if (arr.where((element) => element == 'R').length ==
          arr.where((element) => element == 'L').length) {
        arr.clear();
        result++;
      }
    }

    return result;
  }

  /// 多维数组 rows[x] + cols[y]即为（x, y)的值
  static int oddCells(int m, int n, List<List<int>> indices) {
    int result = 0;
    List<int> rows = List.filled(m, 0);
    List<int> cols = List.filled(n, 0);

    for (var val in indices) {
      rows[val[0]]++;
      cols[val[1]]++;
    }

    for (int i = 0; i < m; i++) {
      for (int j = 0; j < n; j++) {
        if ((rows[i] + cols[j]) & 1 != 0) {
          result++;
        }
      }
    }

    return result;
  }

  /// A B Draw Pending
  /// {1, 2, 3}      {0, 1, 2}     {(0, 0), (0, 1), (0, 2)}
  /// {4, 5, 6}  =>  {3, 4, 5}  => {(1, 0), (1, 1), (1, 2)} => (x, y) => x*3+y = key
  /// {7, 8, 9}      {6, 7, 8}     {(2, 0), (2, 1), (2, 2)}
  /// 对比两个数组
  static String tictactoe(List<List<int>> moves) {
    List<int> a = [];
    List<int> b = [];
    for (int i = 0; i < moves.length; i++) {
      int key = moves[i][0] * 3 + moves[i][1];
      if (i & 1 == 0) {
        a.add(key);
      } else {
        b.add(key);
      }
      a.sort((a, b) => a - b);
      b.sort((a, b) => a - b);
    }

    List<List<int>> wins = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6]
    ];

    for (var element in wins) {
      if (a.length >= 3 && ArrayHelper.containList(a, element)) {
        return 'A';
      } else if (b.length >= 3 && ArrayHelper.containList(element, b)) {
        return 'B';
      }
    }
    return moves.length < 9 ? 'Pending' : 'Draw';
  }

  /// 双指针
  /// [17, 18, 4, 6, 1] => [18, 6, 6, 1, -1]
  static List<int> replaceElements(List<int> arr) {
    List<int> result = [];
    for (int i = 0; i < arr.length; i++) {
      int key = 0;
      if (i == arr.length - 1) {
        result.add(-1);
        break;
      }
      for (int j = i + 1; j < arr.length; j++) {
        key = max(key, arr[j]);
      }
      result.add(key);
    }

    return result;
  }

  /// length为n, 和为0, 且值各不相同的数组
  static List<int> sumZero(int n) {
    List<int> result = [];
    for (int i = 1; i <= n / 2; i++) {
      result.add(i);
      result.add(-i);
    }
    if (n & 1 != 0) {
      result.add(0);
    }
    print(result);
    return result;
  }

  static List<int> decompressRLElist(List<int> nums) {
    List<int> result = [];
    for (int i = 0; i < nums.length; i += 2) {
      for (int j = 0; j < nums[i]; j++) {
        result.add(nums[i + 1]);
      }
    }
    return result;
  }

  /// 生成和为n的两个十进制不含0的数
  static List<int> getNoZeroIntegers(int n) {
    List<int> result = [];
    for (int i = 1; i < n; i++) {
      int sum = n - i;
      if (!i.toRadixString(10).split('').contains('0') &&
          !sum.toRadixString(10).split('').contains('0')) {
        result = [i, (n - i)];
        break;
      }
    }

    return result;
  }

  /// 排序 => 去重 => map
  /// 超出时间限制？
  static List<int> arrayRankTransform(List<int> arr) {
    List<int> result = [];
    List<int> nArr = List.from(arr);
    nArr = ArrayHelper.uniqueInt(nArr);

    /// 去重
    nArr.sort((a, b) => a - b);

    /// 排序
    Map<int, dynamic> arrMap = {};
    for (int key in nArr) {
      if (arrMap.keys.contains(key) != true) {
        arrMap[key] = nArr.indexOf(key);
      }
    }

    for (int val in arr) {
      result.add(arrMap[val] + 1);
    }

    return result;
  }

  ///
  static List<int> sortByBits(List<int> arr) {
    List<int> result = [];

    return result;
  }

  static int lengthOfLongestSubstring(String s) {
    Map<int, int> map = {};
    int start = 0, end = 0;
    int maxLength = 0;
    for (int i = 0; i < s.length; i++) {
      int ch = s.codeUnitAt(i);
      if (map.containsKey(ch) == true) {
        start = max(start, map[ch]! + 1);
      }
      end = i;
      map[ch] = i;
      maxLength = max(maxLength, end - start + 1);
    }
    return maxLength;
  }

  ///
  static bool checkIfExist(List<int> arr) {
    var set = <int>{}; // 哈希表
    for (var num in arr) {
      if (set.contains(num * 2) || (num % 2 == 0 && set.contains(num ~/ 2))) {
        return true;
      }
      set.add(num);
    }
    return false;
  }
}
