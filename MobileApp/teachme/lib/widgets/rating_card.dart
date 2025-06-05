import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teachme/models/rating_model.dart';
import 'package:teachme/providers/language_provider.dart';
import 'package:teachme/utils/translate.dart';
import 'package:teachme/widgets/full_screen_image.dart';
import 'package:timeago/timeago.dart' as timeago;

class RatingCard extends StatelessWidget {
  final RatingModel rating;

  const RatingCard({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(backgroundImage: NetworkImage(rating.userPhotoUrl)),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _authorName(rating),
                Text(
                  _timeAgoComment(context, rating),
                  style: TextStyle(color: Colors.white60),
                ),
                SizedBox(height: 4),
                Text(rating.comment, style: TextStyle(color: Colors.white)),
                if (rating.photos.isNotEmpty) _showPhotos(rating),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgoComment(BuildContext context, RatingModel rating) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );

    return timeago.format(
      rating.date,
      locale:
          supportedLanguages.contains(languageProvider.locale.toString())
              ? languageProvider.locale.toString()
              : 'en',
    );
  }

  Row _authorName(RatingModel rating) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          // <-- En vez de Spacer, para evitar conflicto de layout
          child: Text(
            rating.userName,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        Icon(Icons.star, color: Colors.amber, size: 17),
        SizedBox(width: 4),
        Text(
          rating.score.toStringAsFixed(0),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _showPhotos(RatingModel rating) {
    if (rating.photos.isEmpty) return SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: SizedBox(
        height: 80,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: rating.photos.length,
          separatorBuilder: (_, __) => SizedBox(width: 8),
          itemBuilder: (context, index) {
            final photoUrl = rating.photos[index];
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => FullscreenImagePage(
                            imageUrl: photoUrl,
                            tag: 'photo_${index}_${rating.id}',
                          ),
                    ),
                  );
                },
                child: Hero(
                  tag: 'photo_${index}_${rating.id}',
                  child: Image.network(
                    photoUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
