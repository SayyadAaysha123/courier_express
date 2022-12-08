import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../helper/styles.dart';
import '../../models/category.dart';

class CategoriesListWidget extends StatelessWidget {
  final List<Category> categories;
  const CategoriesListWidget(this.categories, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 15),
        Text(
          AppLocalizations.of(context)!.seeWhatWeCanDoForYouToday,
          style: kSubtitleStyle.copyWith(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        Container(
          height: 115,
          padding: EdgeInsets.symmetric(vertical: 10),
          child: ListView.builder(
            itemCount: categories.length,
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              Category cat = categories.elementAt(index);
              return Container(
                width: (MediaQuery.of(context).size.width - 20) / 3.5,
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 60,
                      height: 60,
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: cat.picture != null
                            ? CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl: cat.picture!.url,
                                placeholder: (context, url) => Image.asset(
                                  'assets/img/loading.gif',
                                  fit: BoxFit.cover,
                                ),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              )
                            : Container(
                                padding: const EdgeInsets.all(5),
                              ),
                      ),
                    ),
                    Container(
                      child: Text(
                        cat.name,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: kSubtitleStyle.copyWith(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
