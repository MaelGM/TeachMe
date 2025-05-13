import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:teachme/models/adverstiment_model.dart';
import 'package:teachme/service/course_service.dart';
import 'package:teachme/widgets/hamburguer_menu.dart';

class CourseDetailsPage extends StatefulWidget{
  static final routeName = 'courseDetails';

  const CourseDetailsPage({super.key});

  @override
  State<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Icon(Icons.favorite_outline, color: Colors.white,),
          HamburguerMenu(),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            
            _topImage(screenHeight),
          ],
        ),
      ),
    );
  }

  SizedBox _topImage(double screenHeight) {
    return SizedBox(

            height: screenHeight * 0.33,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: CourseService.course.photos.length,
                  itemBuilder: (context, index) {
                    return Image.network(
                      CourseService.course.photos[index],
                      width: double.infinity,
                      fit: BoxFit.cover,
                    );
                  },
                ),
                Positioned(
                  bottom: 15,
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: CourseService.course.photos.length,
                    effect: WormEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      activeDotColor: Colors.white,
                      dotColor: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}