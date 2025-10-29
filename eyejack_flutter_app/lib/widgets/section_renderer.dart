import 'package:flutter/material.dart';
import '../models/section_model.dart';
import 'hero_banner_widget.dart';
import 'hero_slider_widget.dart';
import 'product_grid_widget.dart';
import 'collection_list_widget.dart';
import 'announcement_widget.dart';
import 'announcement_bars_widget.dart';
import 'app_header_widget.dart';
import 'moving_usp_strip_widget.dart';
import 'category_grid_widget.dart';
import 'gender_categories_widget.dart';
import 'special_collection_widget.dart';
import 'eyewear_collection_cards_widget.dart';
import 'offers_grid_widget.dart';
import 'trust_badges_widget.dart';

class SectionRenderer extends StatelessWidget {
  final Section section;

  const SectionRenderer({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    switch (section.type) {
      // Original sections
      case 'hero':
        return HeroBannerWidget(settings: section.settings);
      
      case 'product_grid':
        return ProductGridWidget(settings: section.settings);
      
      case 'collection_list':
        return CollectionListWidget(settings: section.settings);
      
      case 'announcement':
        return AnnouncementWidget(settings: section.settings);
      
      // New sections matching eyejack.in (New BOGO Theme)
      case 'app_header':
        return AppHeaderWidget(settings: section.settings);
      
      case 'announcement_bars':
        return AnnouncementBarsWidget(settings: section.settings);
      
      case 'moving_usp_strip':
        return MovingUspStripWidget(settings: section.settings);
      
      case 'hero_slider':
        return HeroSliderWidget(settings: section.settings);
      
      case 'category_grid':
        return CategoryGridWidget(settings: section.settings);
      
      case 'gender_categories':
        return GenderCategoriesWidget(settings: section.settings);
      
      case 'special_collection':
        return SpecialCollectionWidget(settings: section.settings);
      
      case 'eyewear_collection_cards':
        return EyewearCollectionCardsWidget(settings: section.settings);
      
      case 'offers_grid':
        return OffersGridWidget(settings: section.settings);
      
      case 'trust_badges':
        return TrustBadgesWidget(settings: section.settings);
      
      default:
        // Fallback for unknown section types
        return Container(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Unknown section type: ${section.type}',
            style: const TextStyle(color: Colors.grey),
          ),
        );
    }
  }
}

