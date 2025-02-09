class MyClass {
  
  // 定义一个静态方法 
  static void sayHello() {
    print('Hello, world!');
  }
 
  // 定义一个非静态方法 
  void sayGoodbye() {
    print('Goodbye, world!');
  }
}
 
void main() {
  // 通过类名调用静态方法 
  MyClass.sayHello();  // 输出: Hello, world!
 
  // 创建类的实例 
  MyClass instance = MyClass();
 
  // 通过实例调用非静态方法 
  instance.sayGoodbye();  // 输出: Goodbye, world!
}