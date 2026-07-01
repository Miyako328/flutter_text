// Mixins 使我们可以在无需继承父类的情况下为此类添加父类的“功能”，可以在同一个类中具有一个父级和多个 mixin 组件。
// Mixins 不可以声明任何构造函数。
// 给 Mixins 添加限定条件使用 on 关键字。
// 混合使用 with 关键字，with 后面可以是 class、abstract class 和 mixin 的类型。
// Mixins 不是多重继承，相反，它只是在多个层次结构中重用类中的代码而无需扩展它们的一种方式。

import 'package:self_utils/init.dart';

///Mixin解决了无法多重继承的问题。代码复用

class Person {
  void walk() {
    print('walk');
  }
}

class Bird {
  void fly() {
    print('fly');
  }
}

mixin Dance on Person {
  void dance() {
    print('dance');
  }
}

mixin Eat{
  void eat() {
    print('eat');
  }
}

///添加限定条件，使用关键字 on
///使用关键字 on 限定Code 只能被 Person 或者其子类 mixin。
///添加限定后，可以重写其方法，code重写Person方法
///super 表示调用父类（Person）的方法。
mixin Code on Person {
  @override
  void walk() {
    super.walk();
    print('Code walk');
  }

  void code() {
    print('code');
  }
}

///注意：混合使用 with 关键字
class A extends Person with Eat {

}

class D extends Bird with Eat {

}

class B extends Person with Code, Eat {

}

// 'Code' can't be mixed onto 'Bird' because 'Bird' doesn't implement 'Person'. (Documentation)
// class C extends Bird with Code {
//
// }