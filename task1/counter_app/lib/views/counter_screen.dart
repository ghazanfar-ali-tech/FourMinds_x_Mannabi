

import 'package:counter_app/controller/counter_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  CounterController counterController = CounterController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter Screen'),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Push to increment or decrement the counter',
              style: TextStyle(fontSize: 20,color: Colors.black54,
              fontStyle: FontStyle.italic,),
              textAlign: TextAlign.center,
            ),
            Obx(() => Text(
            counterController.counter.value.toString(),
               style: TextStyle(fontSize: 48, 
              fontWeight: FontWeight.bold,
              color: Colors.deepOrangeAccent,
              shadows: [
                Shadow(
                  color: Color.fromARGB(102, 103, 58, 183),
                  offset: Offset(2, 2),
                  blurRadius: 10,
                ),
              ],
              ),
           
            )),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                 width: Get.width * 0.3,   
                 height: Get.height * 0.07,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      counterController.increment(1);                    
                    },
                    icon: const Icon(Icons.add,color: Colors.white,),
                    label: const Text('Increment',style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent.shade400,
                       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),  
                      elevation: 5,
                      shadowColor: Colors.greenAccent,
                    ),
                   
                  ),
                ),

                const SizedBox(width: 20),
                SizedBox(
                  height: Get.height*0.07,
                  width: Get.width * 0.3,
                  child: ElevatedButton.icon(
                    onPressed: () {
                        counterController.decrement(1);                      
                    },
                    
                    icon: const Icon(Icons.remove,color: Colors.white,),
                    label: const Text('Decrement', style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.shade400,
                       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),  
                      elevation: 5,
                      shadowColor: Colors.redAccent,
                    ),
                  
                    
                  ),
                ),
              ],
            ),

          ],
        ),
      ),
     
    );
  }
}





