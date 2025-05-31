import 'package:get/get.dart';

class CounterController extends GetxController{
  RxInt counter = 0.obs;

  void increment(int value){
    counter.value = counter.value + value;
  }
  void decrement(int value){
    if (counter.value > 0) {
      counter.value = counter.value - value;
    }
  }

}

