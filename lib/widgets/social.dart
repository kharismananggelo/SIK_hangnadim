import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SocialLogin extends StatelessWidget {
  const SocialLogin ({Key? key})  : super(key : key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          child: Text(
            "-atau login menggunakan-",
            style: TextStyle(
              color : Colors.blue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 15),
        Container(
        width: MediaQuery.of(context).size.width * 0.8,
          child: Row(
            children: [
              //google 
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: SvgPicture.asset(
                    "assets/icons/google_icon.svg",
                    height: 30,
                    width: 50,
                  ),
                ),
              ),
          
              const SizedBox(width: 15),
          
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: SvgPicture.asset(
                    "assets/icons/facebook_icon.svg",
                    height: 30,
                    width: 50,
                  ),
                ),
              ),
          
              const SizedBox(width: 20),
          
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: SvgPicture.asset(
                    "assets/icons/twitter_icon.svg",
                    height: 30,
                    width: 50,
                  ),
                ),
              )
            ],
          ),
        ),
      ]
    );
  }
}