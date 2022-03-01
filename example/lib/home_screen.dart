import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  bool? isOpenedWithLink;
  HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Center(
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
              Image.asset(
                'assets/millicastImage.png',
                fit: BoxFit.contain,
                height: 40,
              ),
              Container(
                width: 5,
              ),
              const Text('Millicast SDK Demo',
                  style: TextStyle(color: Colors.black, fontSize: 15))
            ])),
      ),
      body: Center(
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
            SizedBox(
                height: MediaQuery.of(context).size.height * 0.3,
                width: MediaQuery.of(context).size.width * 0.4,
                child: ElevatedButton(
                    // Within the `FirstScreen` widget
                    onPressed: () {
                      // Navigate to the second screen using a named route.
                      Navigator.pushReplacementNamed(context, '/publisher');
                    },
                    child: const Text(
                      'Publisher App',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    ))),
            SizedBox(
                height: MediaQuery.of(context).size.height * 0.3,
                width: MediaQuery.of(context).size.width * 0.4,
                child: ElevatedButton(
                  // Within the `FirstScreen` widget
                  onPressed: () {
                    // Navigate to the second screen using a named route.
                    Navigator.pushReplacementNamed(context, '/subscriber');
                  },
                  child: const Text(
                    'Subscriber App',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  ),
                )),
          ])),
    );
  }
}
