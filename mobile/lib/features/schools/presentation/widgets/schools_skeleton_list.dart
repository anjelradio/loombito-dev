import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:mobile/features/schools/domain/domain.dart';
import 'package:mobile/features/schools/presentation/widgets/school_card.dart';

class SchoolsSkeletonList extends StatelessWidget {
  const SchoolsSkeletonList({super.key});

  @override
  Widget build(BuildContext context) {
    final placeholderSchools = [
      School(
        id: 'placeholder-1',
        name: 'Institucion Educativa Modelo',
        logoImage: null,
        type: 'private',
        phone: '',
        role: '',
      ),
      School(
        id: 'placeholder-2',
        name: 'Colegio San Jose',
        logoImage: null,
        type: 'public',
        phone: '',
        role: '',
      ),
    ];

    return Skeletonizer(
      enabled: true,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        itemCount: placeholderSchools.length,
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          return IgnorePointer(
            child: SchoolCard(
              school: placeholderSchools[index],
              enabled: false,
            ),
          );
        },
      ),
    );
  }
}
