import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:teachme/service/teacher_service.dart';
import 'package:teachme/utils/config.dart';
import 'package:teachme/utils/translate.dart';
import 'package:teachme/widgets/info_list_tile.dart';
import 'package:teachme/widgets/interests_chips.dart';
import 'package:teachme/widgets/skill_chips.dart';

class AboutMeSection extends StatelessWidget {
  const AboutMeSection({    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              translate(context, "userInfo"),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 7),
            ExpandableText(
              TeacherService.teacher.aboutMe,
              maxLines: 5,
              style: TextStyle(color: Colors.white, fontSize: 15),
              expandText: translate(context, "seeMore"),
              collapseText: translate(context, "seeLess"),
              linkColor: Color(0xFF3B82F6),
            ),
            InfoListTile(
              subtitle: TeacherService.teacher.country,
              icon: Icons.location_on,
              title: translate(context, "fromCountry"),
            ),
            InfoListTile(
              subtitle: TeacherService.teacher.memberSince,
              icon: Icons.person_outline,
              title: translate(context, "memberSince"),
            ),
            SizedBox(height: 7),
            Text(
              translate(context, "userSkills"),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 7),
            SkillChips(editable: false, teacher: TeacherService.teacher,),
            if(currentUser.isStudent &&  currentUser.id == TeacherService.teacher.userId)
              InterestsChips()
          ],
        ),
      ),
    );
  }
}
