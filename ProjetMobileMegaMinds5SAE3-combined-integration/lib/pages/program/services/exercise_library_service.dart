// lib/services/exercise_library_service.dart
import '../models/exercise_library.dart';

class ExerciseLibraryService {
  // Seed data - Popular exercises with detailed information
  static List<ExerciseLibrary> getSeedExercises() {
    return [
      // CHEST EXERCISES
      ExerciseLibrary(
        name: 'Barbell Bench Press',
        description: 'The king of chest exercises. Builds mass and strength in the chest, shoulders, and triceps.',
        category: 'chest',
        difficulty: 'intermediate',
        muscleGroups: ['pectorals', 'anterior_deltoids', 'triceps'],
        equipment: ['barbell', 'bench'],
        videoUrl: 'https://www.youtube.com/watch?v=rT7DgCr-3pg',
        thumbnailUrl: 'https://i.ytimg.com/vi/rT7DgCr-3pg/maxresdefault.jpg',
        instructions: [
          'Lie flat on bench with feet firmly on ground',
          'Grip bar slightly wider than shoulder width',
          'Unrack bar and lower to mid-chest with control',
          'Press bar up explosively until arms are extended',
          'Keep shoulder blades retracted throughout',
        ],
        tips: [
          'Keep your back slightly arched',
          'Drive through your heels',
          'Touch chest lightly, don\'t bounce',
        ],
        commonMistakes: [
          'Flaring elbows too wide (45° angle is better)',
          'Bouncing bar off chest',
          'Not using full range of motion',
        ],
      ),
      
      ExerciseLibrary(
        name: 'Push-Ups',
        description: 'Classic bodyweight exercise that builds chest, shoulders, and triceps anywhere.',
        category: 'chest',
        difficulty: 'beginner',
        muscleGroups: ['pectorals', 'anterior_deltoids', 'triceps', 'core'],
        equipment: ['bodyweight'],
        videoUrl: 'https://www.youtube.com/watch?v=IODxDxX7oi4',
        thumbnailUrl: 'https://i.ytimg.com/vi/IODxDxX7oi4/maxresdefault.jpg',
        instructions: [
          'Start in plank position with hands shoulder-width apart',
          'Keep body in straight line from head to heels',
          'Lower chest to ground while keeping elbows at 45° angle',
          'Push back up to starting position',
          'Maintain core engagement throughout',
        ],
        tips: [
          'Don\'t let hips sag',
          'Breathe in going down, out going up',
          'Start with knee push-ups if needed',
        ],
        commonMistakes: [
          'Sagging hips or piking up',
          'Flaring elbows out too wide',
          'Not going deep enough',
        ],
      ),

      // BACK EXERCISES
      ExerciseLibrary(
        name: 'Deadlift',
        description: 'The ultimate full-body strength builder. Targets entire posterior chain.',
        category: 'back',
        difficulty: 'advanced',
        muscleGroups: ['lower_back', 'glutes', 'hamstrings', 'lats', 'traps'],
        equipment: ['barbell'],
        videoUrl: 'https://www.youtube.com/watch?v=ytGaGIn3SjE',
        thumbnailUrl: 'https://i.ytimg.com/vi/ytGaGIn3SjE/maxresdefault.jpg',
        instructions: [
          'Stand with feet hip-width apart, bar over mid-foot',
          'Grip bar just outside legs with mixed or double overhand grip',
          'Lower hips, chest up, back flat',
          'Drive through heels and pull bar up legs',
          'Stand fully upright at top, then lower with control',
        ],
        tips: [
          'Keep bar close to body throughout',
          'Brace core hard before each rep',
          'Think "push the floor away"',
        ],
        commonMistakes: [
          'Rounding lower back',
          'Starting with hips too high or low',
          'Bar drifting away from body',
        ],
      ),

      ExerciseLibrary(
        name: 'Pull-Ups',
        description: 'Elite bodyweight back builder. Develops width and strength in lats.',
        category: 'back',
        difficulty: 'intermediate',
        muscleGroups: ['lats', 'biceps', 'rear_deltoids', 'traps'],
        equipment: ['pull_up_bar'],
        videoUrl: 'https://www.youtube.com/watch?v=eGo4IYlbE5g',
        thumbnailUrl: 'https://i.ytimg.com/vi/eGo4IYlbE5g/maxresdefault.jpg',
        instructions: [
          'Hang from bar with overhand grip, hands slightly wider than shoulders',
          'Engage lats and pull elbows down to sides',
          'Continue until chin clears bar',
          'Lower with control to full extension',
          'Avoid swinging or kipping',
        ],
        tips: [
          'Think about pulling elbows to hips',
          'Initiate with lats, not arms',
          'Full range of motion is key',
        ],
        commonMistakes: [
          'Using momentum to swing up',
          'Not going to full extension',
          'Shrugging shoulders at bottom',
        ],
      ),

      // LEG EXERCISES
      ExerciseLibrary(
        name: 'Barbell Back Squat',
        description: 'The king of leg exercises. Builds powerful quads, glutes, and core.',
        category: 'legs',
        difficulty: 'intermediate',
        muscleGroups: ['quadriceps', 'glutes', 'hamstrings', 'core'],
        equipment: ['barbell', 'squat_rack'],
        videoUrl: 'https://www.youtube.com/watch?v=ultWZbUMPL8',
        thumbnailUrl: 'https://i.ytimg.com/vi/ultWZbUMPL8/maxresdefault.jpg',
        instructions: [
          'Position bar on upper back/traps, feet shoulder-width apart',
          'Unrack bar and step back',
          'Break at knees and hips simultaneously',
          'Descend until thighs are parallel or below',
          'Drive through heels to stand back up',
        ],
        tips: [
          'Keep chest up and core braced',
          'Knees should track over toes',
          'Breathe and brace before each rep',
        ],
        commonMistakes: [
          'Knees caving inward',
          'Coming onto toes',
          'Excessive forward lean',
        ],
      ),

      ExerciseLibrary(
        name: 'Walking Lunges',
        description: 'Unilateral leg exercise that builds balance, stability, and leg strength.',
        category: 'legs',
        difficulty: 'beginner',
        muscleGroups: ['quadriceps', 'glutes', 'hamstrings', 'calves'],
        equipment: ['bodyweight', 'dumbbells'],
        videoUrl: 'https://www.youtube.com/watch?v=D7KaRcUTQeE',
        thumbnailUrl: 'https://i.ytimg.com/vi/D7KaRcUTQeE/maxresdefault.jpg',
        instructions: [
          'Stand upright holding dumbbells at sides (or bodyweight)',
          'Step forward with right leg into deep lunge',
          'Lower back knee toward ground',
          'Push through front heel to stand',
          'Step forward with left leg and repeat',
        ],
        tips: [
          'Keep torso upright',
          'Front knee should stay over ankle',
          'Take controlled, consistent steps',
        ],
        commonMistakes: [
          'Leaning forward excessively',
          'Short steps (not enough depth)',
          'Front knee going past toes',
        ],
      ),

      // SHOULDER EXERCISES
      ExerciseLibrary(
        name: 'Overhead Press',
        description: 'Fundamental shoulder builder. Develops strength in shoulders and upper chest.',
        category: 'shoulders',
        difficulty: 'intermediate',
        muscleGroups: ['anterior_deltoids', 'lateral_deltoids', 'triceps', 'upper_chest'],
        equipment: ['barbell'],
        videoUrl: 'https://www.youtube.com/watch?v=2yjwXTZQDDI',
        thumbnailUrl: 'https://i.ytimg.com/vi/2yjwXTZQDDI/maxresdefault.jpg',
        instructions: [
          'Stand with bar resting on front shoulders',
          'Grip slightly wider than shoulder width',
          'Press bar straight overhead until arms locked',
          'Lower bar back to shoulders with control',
          'Keep core tight and glutes engaged',
        ],
        tips: [
          'Push your head through after bar clears',
          'Keep forearms vertical',
          'Don\'t lean back excessively',
        ],
        commonMistakes: [
          'Pressing forward instead of up',
          'Excessive back arch',
          'Not locking out at top',
        ],
      ),

      ExerciseLibrary(
        name: 'Lateral Raises',
        description: 'Isolation exercise for shoulder width. Targets lateral deltoids.',
        category: 'shoulders',
        difficulty: 'beginner',
        muscleGroups: ['lateral_deltoids'],
        equipment: ['dumbbells'],
        videoUrl: 'https://www.youtube.com/watch?v=3VcKaXpzqRo',
        thumbnailUrl: 'https://i.ytimg.com/vi/3VcKaXpzqRo/maxresdefault.jpg',
        instructions: [
          'Stand with dumbbells at sides, slight bend in elbows',
          'Raise arms out to sides until parallel with ground',
          'Lead with elbows, not hands',
          'Pause at top, then lower with control',
          'Keep core tight and avoid swinging',
        ],
        tips: [
          'Use lighter weight for strict form',
          'Imagine pouring water from pitchers',
          'Focus on the muscle contraction',
        ],
        commonMistakes: [
          'Using momentum to swing weights',
          'Going too heavy',
          'Raising arms above shoulder level',
        ],
      ),

      // ARM EXERCISES
      ExerciseLibrary(
        name: 'Barbell Curl',
        description: 'Classic bicep builder. Develops size and strength in biceps.',
        category: 'arms',
        difficulty: 'beginner',
        muscleGroups: ['biceps', 'forearms'],
        equipment: ['barbell'],
        videoUrl: 'https://www.youtube.com/watch?v=kwG2ipFRgfo',
        thumbnailUrl: 'https://i.ytimg.com/vi/kwG2ipFRgfo/maxresdefault.jpg',
        instructions: [
          'Stand holding bar with underhand grip at hip level',
          'Keep elbows tucked at sides',
          'Curl bar up toward shoulders',
          'Squeeze biceps at top',
          'Lower with control to starting position',
        ],
        tips: [
          'Don\'t let elbows drift forward',
          'Keep back against wall to prevent cheating',
          'Control the negative',
        ],
        commonMistakes: [
          'Swinging body to lift weight',
          'Moving elbows forward',
          'Not using full range of motion',
        ],
      ),

      ExerciseLibrary(
        name: 'Tricep Dips',
        description: 'Powerful tricep and chest developer using bodyweight.',
        category: 'arms',
        difficulty: 'intermediate',
        muscleGroups: ['triceps', 'lower_chest', 'anterior_deltoids'],
        equipment: ['dip_bars', 'bench'],
        videoUrl: 'https://www.youtube.com/watch?v=2z8JmcrW-As',
        thumbnailUrl: 'https://i.ytimg.com/vi/2z8JmcrW-As/maxresdefault.jpg',
        instructions: [
          'Grip parallel bars and support body with arms extended',
          'Lower body by bending elbows to 90 degrees',
          'Keep elbows close to body for tricep focus',
          'Press back up to starting position',
          'Lean forward slightly for more chest activation',
        ],
        tips: [
          'Don\'t go too deep to protect shoulders',
          'Keep shoulders down and back',
          'Add weight belt for progression',
        ],
        commonMistakes: [
          'Going too deep',
          'Flaring elbows out',
          'Shrugging shoulders',
        ],
      ),

      // CORE EXERCISES
      ExerciseLibrary(
        name: 'Plank',
        description: 'Fundamental core stability exercise. Builds endurance in abs and lower back.',
        category: 'core',
        difficulty: 'beginner',
        muscleGroups: ['rectus_abdominis', 'transverse_abdominis', 'obliques', 'lower_back'],
        equipment: ['bodyweight'],
        videoUrl: 'https://www.youtube.com/watch?v=ASdvN_XEl_c',
        thumbnailUrl: 'https://i.ytimg.com/vi/ASdvN_XEl_c/maxresdefault.jpg',
        instructions: [
          'Start in push-up position on forearms',
          'Keep body in straight line from head to heels',
          'Engage core and squeeze glutes',
          'Hold position without sagging or piking',
          'Breathe normally throughout',
        ],
        tips: [
          'Focus on quality over duration',
          'Keep neck neutral',
          'Pull belly button to spine',
        ],
        commonMistakes: [
          'Hips sagging toward ground',
          'Hips too high',
          'Holding breath',
        ],
      ),

      ExerciseLibrary(
        name: 'Russian Twists',
        description: 'Rotational core exercise that targets obliques and builds stability.',
        category: 'core',
        difficulty: 'beginner',
        muscleGroups: ['obliques', 'rectus_abdominis', 'hip_flexors'],
        equipment: ['bodyweight', 'medicine_ball', 'dumbbell'],
        videoUrl: 'https://www.youtube.com/watch?v=wkD8rjkodUI',
        thumbnailUrl: 'https://i.ytimg.com/vi/wkD8rjkodUI/maxresdefault.jpg',
        instructions: [
          'Sit on floor with knees bent, lean back slightly',
          'Hold weight at chest or bodyweight with hands together',
          'Lift feet off ground for extra challenge',
          'Rotate torso to right, bringing weight to side',
          'Rotate to left side in controlled manner',
        ],
        tips: [
          'Move from the core, not just arms',
          'Keep chest up and back straight',
          'Control the movement',
        ],
        commonMistakes: [
          'Moving too fast',
          'Rounding back excessively',
          'Only moving arms, not torso',
        ],
      ),

      // CARDIO
      ExerciseLibrary(
        name: 'Burpees',
        description: 'Full-body cardio exercise that builds endurance and burns calories.',
        category: 'cardio',
        difficulty: 'intermediate',
        muscleGroups: ['full_body', 'cardiovascular'],
        equipment: ['bodyweight'],
        videoUrl: 'https://www.youtube.com/watch?v=dZgVxmf6jkA',
        thumbnailUrl: 'https://i.ytimg.com/vi/dZgVxmf6jkA/maxresdefault.jpg',
        instructions: [
          'Start standing, then drop into squat position',
          'Place hands on ground and kick feet back to plank',
          'Perform push-up (optional)',
          'Jump feet back to squat position',
          'Explosively jump up with arms overhead',
        ],
        tips: [
          'Land softly to protect joints',
          'Maintain steady breathing pace',
          'Modify by stepping instead of jumping',
        ],
        commonMistakes: [
          'Sloppy form when fatigued',
          'Not fully extending at top',
          'Holding breath',
        ],
      ),

      ExerciseLibrary(
        name: 'Jumping Jacks',
        description: 'Classic warm-up and cardio exercise. Elevates heart rate quickly.',
        category: 'cardio',
        difficulty: 'beginner',
        muscleGroups: ['full_body', 'cardiovascular'],
        equipment: ['bodyweight'],
        videoUrl: 'https://www.youtube.com/watch?v=c4DAnQ6DtF8',
        thumbnailUrl: 'https://i.ytimg.com/vi/c4DAnQ6DtF8/maxresdefault.jpg',
        instructions: [
          'Start with feet together, arms at sides',
          'Jump while spreading legs shoulder-width',
          'Simultaneously raise arms overhead',
          'Jump back to starting position',
          'Maintain steady rhythm',
        ],
        tips: [
          'Land on balls of feet',
          'Keep core engaged',
          'Breathe rhythmically',
        ],
        commonMistakes: [
          'Landing too heavily',
          'Not fully extending arms',
          'Going too fast without control',
        ],
      ),
    ];
  }

  // Get muscle group display name
  static String getMuscleGroupName(String key) {
    final Map<String, String> names = {
      'pectorals': 'Chest',
      'anterior_deltoids': 'Front Shoulders',
      'lateral_deltoids': 'Side Shoulders',
      'rear_deltoids': 'Rear Shoulders',
      'triceps': 'Triceps',
      'biceps': 'Biceps',
      'forearms': 'Forearms',
      'lats': 'Lats',
      'traps': 'Traps',
      'lower_back': 'Lower Back',
      'quadriceps': 'Quads',
      'hamstrings': 'Hamstrings',
      'glutes': 'Glutes',
      'calves': 'Calves',
      'rectus_abdominis': 'Abs',
      'obliques': 'Obliques',
      'transverse_abdominis': 'Deep Core',
      'hip_flexors': 'Hip Flexors',
      'core': 'Core',
      'upper_chest': 'Upper Chest',
      'lower_chest': 'Lower Chest',
      'full_body': 'Full Body',
      'cardiovascular': 'Cardio',
    };
    return names[key] ?? key;
  }

  // Get equipment display name
  static String getEquipmentName(String key) {
    final Map<String, String> names = {
      'barbell': 'Barbell',
      'dumbbell': 'Dumbbell',
      'bodyweight': 'Bodyweight',
      'machine': 'Machine',
      'cable': 'Cable',
      'bench': 'Bench',
      'squat_rack': 'Squat Rack',
      'pull_up_bar': 'Pull-up Bar',
      'dip_bars': 'Dip Bars',
      'medicine_ball': 'Medicine Ball',
    };
    return names[key] ?? key;
  }
}