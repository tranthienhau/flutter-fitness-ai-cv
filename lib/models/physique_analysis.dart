class PhysiqueAnalysis {
  final String id;
  final String userId;
  final DateTime analyzedAt;
  final double estimatedBodyFatPercentage;
  final BodyFatCategory bodyFatCategory;
  final MuscleDevScores muscleDevelopment;
  final FatDistribution fatDistribution;
  final BodyProportions proportions;
  final List<PoseLandmark> detectedLandmarks;
  final String frontPhotoPath;
  final String sidePhotoPath;
  final String backPhotoPath;
  final String aiSummary;
  final List<String> strengths;
  final List<String> areasForImprovement;
  final Map<String, double> measurementEstimates;

  const PhysiqueAnalysis({
    required this.id,
    required this.userId,
    required this.analyzedAt,
    required this.estimatedBodyFatPercentage,
    required this.bodyFatCategory,
    required this.muscleDevelopment,
    required this.fatDistribution,
    required this.proportions,
    required this.detectedLandmarks,
    required this.frontPhotoPath,
    required this.sidePhotoPath,
    required this.backPhotoPath,
    required this.aiSummary,
    this.strengths = const [],
    this.areasForImprovement = const [],
    this.measurementEstimates = const {},
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'analyzedAt': analyzedAt.toIso8601String(),
        'estimatedBodyFatPercentage': estimatedBodyFatPercentage,
        'bodyFatCategory': bodyFatCategory.name,
        'muscleDevelopment': muscleDevelopment.toJson(),
        'fatDistribution': fatDistribution.toJson(),
        'proportions': proportions.toJson(),
        'detectedLandmarks': detectedLandmarks.map((l) => l.toJson()).toList(),
        'frontPhotoPath': frontPhotoPath,
        'sidePhotoPath': sidePhotoPath,
        'backPhotoPath': backPhotoPath,
        'aiSummary': aiSummary,
        'strengths': strengths,
        'areasForImprovement': areasForImprovement,
        'measurementEstimates': measurementEstimates,
      };

  factory PhysiqueAnalysis.fromJson(Map<String, dynamic> json) {
    return PhysiqueAnalysis(
      id: json['id'] as String,
      userId: json['userId'] as String,
      analyzedAt: DateTime.parse(json['analyzedAt'] as String),
      estimatedBodyFatPercentage:
          (json['estimatedBodyFatPercentage'] as num).toDouble(),
      bodyFatCategory:
          BodyFatCategory.values.byName(json['bodyFatCategory'] as String),
      muscleDevelopment:
          MuscleDevScores.fromJson(json['muscleDevelopment']),
      fatDistribution: FatDistribution.fromJson(json['fatDistribution']),
      proportions: BodyProportions.fromJson(json['proportions']),
      detectedLandmarks: (json['detectedLandmarks'] as List)
          .map((l) => PoseLandmark.fromJson(l))
          .toList(),
      frontPhotoPath: json['frontPhotoPath'] as String,
      sidePhotoPath: json['sidePhotoPath'] as String,
      backPhotoPath: json['backPhotoPath'] as String,
      aiSummary: json['aiSummary'] as String,
      strengths: List<String>.from(json['strengths'] ?? []),
      areasForImprovement:
          List<String>.from(json['areasForImprovement'] ?? []),
      measurementEstimates:
          Map<String, double>.from(json['measurementEstimates'] ?? {}),
    );
  }
}

class MuscleDevScores {
  final double shoulders;
  final double chest;
  final double arms;
  final double core;
  final double back;
  final double glutes;
  final double quads;
  final double hamstrings;
  final double calves;
  final double overallSymmetry;

  const MuscleDevScores({
    required this.shoulders,
    required this.chest,
    required this.arms,
    required this.core,
    required this.back,
    required this.glutes,
    required this.quads,
    required this.hamstrings,
    required this.calves,
    required this.overallSymmetry,
  });

  double get averageScore =>
      (shoulders + chest + arms + core + back + glutes + quads + hamstrings + calves) /
      9.0;

  Map<String, dynamic> toJson() => {
        'shoulders': shoulders,
        'chest': chest,
        'arms': arms,
        'core': core,
        'back': back,
        'glutes': glutes,
        'quads': quads,
        'hamstrings': hamstrings,
        'calves': calves,
        'overallSymmetry': overallSymmetry,
      };

  factory MuscleDevScores.fromJson(Map<String, dynamic> json) {
    return MuscleDevScores(
      shoulders: (json['shoulders'] as num).toDouble(),
      chest: (json['chest'] as num).toDouble(),
      arms: (json['arms'] as num).toDouble(),
      core: (json['core'] as num).toDouble(),
      back: (json['back'] as num).toDouble(),
      glutes: (json['glutes'] as num).toDouble(),
      quads: (json['quads'] as num).toDouble(),
      hamstrings: (json['hamstrings'] as num).toDouble(),
      calves: (json['calves'] as num).toDouble(),
      overallSymmetry: (json['overallSymmetry'] as num).toDouble(),
    );
  }
}

class FatDistribution {
  final double abdominal;
  final double lowerBack;
  final double chest;
  final double arms;
  final double thighs;
  final double hips;
  final FatDistributionPattern pattern;

  const FatDistribution({
    required this.abdominal,
    required this.lowerBack,
    required this.chest,
    required this.arms,
    required this.thighs,
    required this.hips,
    required this.pattern,
  });

  Map<String, dynamic> toJson() => {
        'abdominal': abdominal,
        'lowerBack': lowerBack,
        'chest': chest,
        'arms': arms,
        'thighs': thighs,
        'hips': hips,
        'pattern': pattern.name,
      };

  factory FatDistribution.fromJson(Map<String, dynamic> json) {
    return FatDistribution(
      abdominal: (json['abdominal'] as num).toDouble(),
      lowerBack: (json['lowerBack'] as num).toDouble(),
      chest: (json['chest'] as num).toDouble(),
      arms: (json['arms'] as num).toDouble(),
      thighs: (json['thighs'] as num).toDouble(),
      hips: (json['hips'] as num).toDouble(),
      pattern:
          FatDistributionPattern.values.byName(json['pattern'] as String),
    );
  }
}

class BodyProportions {
  final double shoulderToWaistRatio;
  final double waistToHipRatio;
  final double torsoToLegRatio;
  final double armSpanToHeightRatio;

  const BodyProportions({
    required this.shoulderToWaistRatio,
    required this.waistToHipRatio,
    required this.torsoToLegRatio,
    required this.armSpanToHeightRatio,
  });

  Map<String, dynamic> toJson() => {
        'shoulderToWaistRatio': shoulderToWaistRatio,
        'waistToHipRatio': waistToHipRatio,
        'torsoToLegRatio': torsoToLegRatio,
        'armSpanToHeightRatio': armSpanToHeightRatio,
      };

  factory BodyProportions.fromJson(Map<String, dynamic> json) {
    return BodyProportions(
      shoulderToWaistRatio: (json['shoulderToWaistRatio'] as num).toDouble(),
      waistToHipRatio: (json['waistToHipRatio'] as num).toDouble(),
      torsoToLegRatio: (json['torsoToLegRatio'] as num).toDouble(),
      armSpanToHeightRatio: (json['armSpanToHeightRatio'] as num).toDouble(),
    );
  }
}

class PoseLandmark {
  final String name;
  final double x;
  final double y;
  final double z;
  final double confidence;

  const PoseLandmark({
    required this.name,
    required this.x,
    required this.y,
    required this.z,
    required this.confidence,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'x': x,
        'y': y,
        'z': z,
        'confidence': confidence,
      };

  factory PoseLandmark.fromJson(Map<String, dynamic> json) {
    return PoseLandmark(
      name: json['name'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      z: (json['z'] as num).toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
    );
  }
}

enum BodyFatCategory {
  essential,
  athletic,
  fitness,
  average,
  aboveAverage,
  obese,
}

enum FatDistributionPattern {
  android,
  gynoid,
  mixed,
}
