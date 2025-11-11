import '../models/exercise.dart';
import '../models/workout.dart';
import '../models/program.dart';
import 'dart:math';

class ProgramGeneratorService {
  // Exercise database categorized by type and equipment
  static final Map<String, List<Map<String, dynamic>>> exerciseDatabase = {
    'strength_no_equipment': [
      {
        'name': 'Push-ups',
        'description': 'Standard push-ups for chest and triceps',
        'sets': 3,
        'reps': 12,
        'difficulty': 'medium',
      },
      {
        'name': 'Squats',
        'description': 'Bodyweight squats for legs',
        'sets': 3,
        'reps': 15,
        'difficulty': 'medium',
      },
      {
        'name': 'Lunges',
        'description': 'Alternating lunges for legs',
        'sets': 3,
        'reps': 12,
        'difficulty': 'medium',
      },
      {
        'name': 'Plank',
        'description': 'Hold plank position for core',
        'sets': 3,
        'reps': 1,
        'difficulty': 'medium',
      },
      {
        'name': 'Mountain Climbers',
        'description': 'Dynamic core and cardio exercise',
        'sets': 3,
        'reps': 20,
        'difficulty': 'hard',
      },
      {
        'name': 'Burpees',
        'description': 'Full body explosive exercise',
        'sets': 3,
        'reps': 10,
        'difficulty': 'hard',
      },
      {
        'name': 'Tricep Dips',
        'description': 'Using chair or bench for triceps',
        'sets': 3,
        'reps': 12,
        'difficulty': 'medium',
      },
      {
        'name': 'Bicycle Crunches',
        'description': 'Core exercise targeting obliques',
        'sets': 3,
        'reps': 20,
        'difficulty': 'easy',
      },
    ],
    'strength_dumbbells': [
      {
        'name': 'Dumbbell Press',
        'description': 'Chest press with dumbbells',
        'sets': 3,
        'reps': 10,
        'difficulty': 'medium',
      },
      {
        'name': 'Dumbbell Rows',
        'description': 'Back exercise with dumbbells',
        'sets': 3,
        'reps': 12,
        'difficulty': 'medium',
      },
      {
        'name': 'Dumbbell Squats',
        'description': 'Squats holding dumbbells',
        'sets': 3,
        'reps': 12,
        'difficulty': 'medium',
      },
      {
        'name': 'Dumbbell Shoulder Press',
        'description': 'Overhead press for shoulders',
        'sets': 3,
        'reps': 10,
        'difficulty': 'medium',
      },
      {
        'name': 'Dumbbell Curls',
        'description': 'Bicep curls',
        'sets': 3,
        'reps': 12,
        'difficulty': 'easy',
      },
    ],
    'cardio': [
      {
        'name': 'Jumping Jacks',
        'description': 'Full body cardio warm-up',
        'sets': 3,
        'reps': 30,
        'difficulty': 'easy',
      },
      {
        'name': 'High Knees',
        'description': 'Running in place with high knees',
        'sets': 3,
        'reps': 40,
        'difficulty': 'medium',
      },
      {
        'name': 'Butt Kicks',
        'description': 'Running in place kicking heels to glutes',
        'sets': 3,
        'reps': 40,
        'difficulty': 'easy',
      },
      {
        'name': 'Jump Rope',
        'description': 'Cardio with jump rope',
        'sets': 3,
        'reps': 50,
        'difficulty': 'medium',
      },
    ],
    'flexibility': [
      {
        'name': 'Hamstring Stretch',
        'description': 'Stretch for hamstrings',
        'sets': 2,
        'reps': 1,
        'difficulty': 'easy',
      },
      {
        'name': 'Quad Stretch',
        'description': 'Stretch for quadriceps',
        'sets': 2,
        'reps': 1,
        'difficulty': 'easy',
      },
      {
        'name': 'Shoulder Stretch',
        'description': 'Stretch for shoulders and upper back',
        'sets': 2,
        'reps': 1,
        'difficulty': 'easy',
      },
      {
        'name': 'Cat-Cow Stretch',
        'description': 'Yoga pose for spine flexibility',
        'sets': 2,
        'reps': 10,
        'difficulty': 'easy',
      },
    ],
  };

  static Program generateProgram({
    required String goal,
    required String equipment,
    required int daysPerWeek,
    required int durationMinutes,
    required String experience,
  }) {
    final random = Random();
    
    // Determine difficulty based on experience
    String difficulty = experience == 'beginner'
        ? 'easy'
        : experience == 'intermediate'
            ? 'medium'
            : 'hard';

    // Select exercises based on goal and equipment
    List<Exercise> exercisePool = _getExercisePool(goal, equipment, experience);

    // Generate workouts for the week
    List<Workout> weeklyWorkouts = [];
    
    for (int day = 0; day < 7; day++) {
      if (day < daysPerWeek) {
        // Training day
        String workoutName = _getWorkoutName(day, goal);
        List<Exercise> workoutExercises = _selectExercises(
          exercisePool,
          durationMinutes,
          goal,
          random,
        );

        weeklyWorkouts.add(Workout(
          name: workoutName,
          description: _getWorkoutDescription(workoutName, goal),
          exercises: workoutExercises,
          durationMinutes: durationMinutes,
          difficulty: difficulty,
        ));
      } else {
        // Rest day
        weeklyWorkouts.add(Workout(
          name: 'Rest Day',
          description: 'Recovery and rest',
          exercises: [],
          durationMinutes: 0,
          difficulty: 'easy',
          isRestDay: true,
        ));
      }
    }

    // Create program name based on inputs
    String programName = _generateProgramName(goal, daysPerWeek, experience);

    return Program(
      name: programName,
      description: _generateProgramDescription(goal, equipment, daysPerWeek),
      goal: goal,
      durationWeeks: 4,
      workouts: weeklyWorkouts,
      difficulty: difficulty,
      equipment: equipment,
    );
  }

  static List<Exercise> _getExercisePool(
    String goal,
    String equipment,
    String experience,
  ) {
    List<Map<String, dynamic>> rawExercises = [];

    if (goal == 'fat_loss' || goal == 'cardio') {
      rawExercises.addAll(exerciseDatabase['cardio']!);
      rawExercises.addAll(exerciseDatabase['strength_no_equipment']!);
    } else if (goal == 'strength') {
      if (equipment == 'dumbbells' || equipment == 'full_gym') {
        rawExercises.addAll(exerciseDatabase['strength_dumbbells']!);
      }
      rawExercises.addAll(exerciseDatabase['strength_no_equipment']!);
    } else if (goal == 'flexibility') {
      rawExercises.addAll(exerciseDatabase['flexibility']!);
      rawExercises.addAll(exerciseDatabase['strength_no_equipment']!.take(3));
    }

    // Convert to Exercise objects
    return rawExercises.map((ex) {
      // Adjust sets/reps based on experience
      int sets = ex['sets'];
      int reps = ex['reps'];
      
      if (experience == 'beginner') {
        sets = (sets * 0.75).round();
        reps = (reps * 0.8).round();
      } else if (experience == 'advanced') {
        sets = (sets * 1.25).round();
        reps = (reps * 1.2).round();
      }

      return Exercise(
        name: ex['name'],
        description: ex['description'],
        sets: sets,
        reps: reps,
        equipment: equipment,
        difficulty: ex['difficulty'],
      );
    }).toList();
  }

  static List<Exercise> _selectExercises(
    List<Exercise> pool,
    int durationMinutes,
    String goal,
    Random random,
  ) {
    // Calculate number of exercises based on duration
    int exerciseCount;
    if (durationMinutes <= 20) {
      exerciseCount = 3;
    } else if (durationMinutes <= 30) {
      exerciseCount = 4;
    } else if (durationMinutes <= 45) {
      exerciseCount = 5;
    } else {
      exerciseCount = 6;
    }

    // Shuffle and take random exercises
    List<Exercise> shuffled = List.from(pool)..shuffle(random);
    return shuffled.take(exerciseCount).toList();
  }

  static String _getWorkoutName(int day, String goal) {
    List<String> strengthNames = [
      'Upper Body Power',
      'Lower Body Strength',
      'Full Body Blast',
      'Core & Stability',
      'Push Day',
      'Pull Day',
      'Leg Day'
    ];

    List<String> cardioNames = [
      'Cardio Burn',
      'HIIT Session',
      'Endurance Training',
      'Fat Burning Circuit',
      'Metabolic Boost',
      'Cardio Power',
      'Intensity Training'
    ];

    List<String> flexibilityNames = [
      'Flexibility Flow',
      'Stretch & Strengthen',
      'Mobility Session',
      'Active Recovery',
      'Yoga Fusion',
      'Dynamic Stretching',
      'Balance & Flexibility'
    ];

    if (goal == 'strength') {
      return strengthNames[day % strengthNames.length];
    } else if (goal == 'cardio' || goal == 'fat_loss') {
      return cardioNames[day % cardioNames.length];
    } else {
      return flexibilityNames[day % flexibilityNames.length];
    }
  }

  static String _getWorkoutDescription(String name, String goal) {
    return 'Targeted $goal workout focusing on $name exercises';
  }

  static String _generateProgramName(
    String goal,
    int days,
    String experience,
  ) {
    String goalName = goal == 'fat_loss'
        ? 'Fat Loss'
        : goal == 'strength'
            ? 'Strength Building'
            : goal == 'cardio'
                ? 'Cardio Endurance'
                : 'Flexibility';

    String level = experience == 'beginner'
        ? 'Beginner'
        : experience == 'intermediate'
            ? 'Intermediate'
            : 'Advanced';

    return '$level $goalName - $days Days/Week';
  }

  static String _generateProgramDescription(
    String goal,
    String equipment,
    int days,
  ) {
    return 'A customized $goal program designed for $days days per week using $equipment. '
        'This program adapts to your fitness level and helps you achieve your goals efficiently.';
  }
}