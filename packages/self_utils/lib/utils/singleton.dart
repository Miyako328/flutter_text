//单例

//单例的使用场景
//频繁实例化然后销毁的对象
//耗时过多或者耗资源过多且常用的对象
//有状态的工具类
//频繁访问数据库或文件的对象

//风险
//没有抽象类，拓展难度大，
//

class SingleTon {
  static SingleTon? _init;

  static late String _key;

  SingleTon._internal(String val) {
    _init = this;
    _key = val;
  }

  void test() {
    print('$_key 测试');
  }

  factory SingleTon(String val) => _init ?? SingleTon._internal(val);
}