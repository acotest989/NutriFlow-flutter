// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appLoadFailedTitle => 'Couldn\'t load your data';

  @override
  String get appLoadingWorkspace => 'Loading your workspace…';

  @override
  String get appRetry => 'Try again';

  @override
  String get appSyncing => 'Syncing your data…';

  @override
  String get authBackToSignin => 'Back to sign in';

  @override
  String get authBuildPlan => 'New here? Build your free plan first';

  @override
  String get authContinueGoogle => 'Continue with Google';

  @override
  String get authCreateAccount => 'Create Account';

  @override
  String get authEmail => 'Email';

  @override
  String get authEmailPlaceholder => 'you@example.com';

  @override
  String get authErrGeneric => 'Something went wrong. Please try again.';

  @override
  String get authForgot => 'Forgot password?';

  @override
  String get authHaveAccount => 'Already have an account?';

  @override
  String get authHidePassword => 'Hide password';

  @override
  String get authInfoConfirm => 'Account created! Check your email to confirm, then sign in.';

  @override
  String get authInfoReset =>
      'If an account exists for that email, a password reset link is on its way. Check your inbox.';

  @override
  String get authNoAccount => 'Don\'t have an account?';

  @override
  String get authOr => 'or';

  @override
  String get authPassword => 'Password';

  @override
  String get authPasswordPlaceholder => 'Your password';

  @override
  String get authPasswordPlaceholderSignup => 'At least 6 characters';

  @override
  String get authPleaseWait => 'Please wait...';

  @override
  String get authPrivacyNote => 'Your data is private and secured per-account with row-level security.';

  @override
  String get authPromoSaved => 'Your plan is ready — create an account to save it.';

  @override
  String get authSendReset => 'Send reset link';

  @override
  String get authShowPassword => 'Show password';

  @override
  String get authSignIn => 'Sign In';

  @override
  String get authSignInLink => 'Sign in';

  @override
  String get authSignUp => 'Sign up';

  @override
  String get authSubtitleReset => 'Enter your email to reset your password.';

  @override
  String get authSubtitleSignin => 'Welcome back. Sign in to continue.';

  @override
  String get authSubtitleSignup => 'Create your account to get started.';

  @override
  String get chartsAchievements => 'Achievements';

  @override
  String get chartsAchievementsExplainer =>
      'Log a meal, workout, or water on any day to keep your streak alive — miss a whole day and it resets. Stay consistent to unlock these:';

  @override
  String get chartsActiveBurn => 'Active Burn';

  @override
  String get chartsBadgesCenturyDesc => 'Log 100 items total';

  @override
  String get chartsBadgesCenturyLabel => 'Centurion';

  @override
  String get chartsBadgesHydratedDesc => 'Log water on 7 days';

  @override
  String get chartsBadgesHydratedLabel => 'Hydrated';

  @override
  String get chartsBadgesStartDesc => 'Log your first item';

  @override
  String get chartsBadgesStartLabel => 'Getting Started';

  @override
  String get chartsBadgesStreak14Desc => 'Reach a 14-day streak';

  @override
  String get chartsBadgesStreak14Label => 'Dedicated';

  @override
  String get chartsBadgesStreak30Desc => 'Reach a 30-day streak';

  @override
  String get chartsBadgesStreak30Label => 'Unstoppable';

  @override
  String get chartsBadgesStreak3Desc => 'Reach a 3-day streak';

  @override
  String get chartsBadgesStreak3Label => 'Consistent';

  @override
  String get chartsBadgesStreak7Desc => 'Reach a 7-day streak';

  @override
  String get chartsBadgesStreak7Label => 'On Fire';

  @override
  String get chartsCarbs => 'Carbs';

  @override
  String chartsDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count days', one: '$count day');
    return '$_temp0';
  }

  @override
  String get chartsDefaultTemplate =>
      'Default balanced template displayed. Please log food items in the database to see live ratios!';

  @override
  String get chartsEnergyDesc =>
      'Breakdown of daily energy contributions (kcal percentage) derived from logged proteins, carbs, and fats.';

  @override
  String get chartsEnergyTitle => 'Today\'s Energy Share';

  @override
  String get chartsFat => 'Fat';

  @override
  String get chartsFoodIngested => 'Food Ingested';

  @override
  String get chartsGoal => 'Goal';

  @override
  String get chartsNetCalories => 'Net Calories';

  @override
  String chartsOfCalories(String value) {
    return '$value% of calories';
  }

  @override
  String get chartsProtein => 'Protein';

  @override
  String get chartsStartStreak => 'Start a Streak';

  @override
  String chartsStreakAlive(String longest) {
    return 'Your streak is alive — log anything today to extend it. Longest: $longest.';
  }

  @override
  String get chartsStreakStart => 'Log a meal, workout, or water today to begin your streak!';

  @override
  String chartsStreakTitle(String n, String days) {
    return '$n-Day Streak';
  }

  @override
  String chartsStreakToday(String longest) {
    return 'Nice work today! Keep it going — longest streak: $longest.';
  }

  @override
  String get chartsTotalLogged => 'Total Logged';

  @override
  String get chartsTrendDesc =>
      'Compares total food consumed against negative burned workout calories versus daily budget.';

  @override
  String get chartsTrendTitle => '7-Day Balance Trend';

  @override
  String get coachAnalyzing => 'Cooking Analysis...';

  @override
  String get coachCalories => 'Calories';

  @override
  String get coachCarbs => 'Carbs';

  @override
  String get coachChefTab => 'AI Chef Recipes';

  @override
  String get coachCoachRating => 'Coach Rating';

  @override
  String get coachCookingRecipes => 'Cooking Recipes...';

  @override
  String get coachDailyCoachTab => 'AI Daily Coach';

  @override
  String get coachDietitianSummary => 'Dietitian Summary';

  @override
  String get coachErrCoach => 'Failed to get response from AI coach.';

  @override
  String get coachErrGeneric => 'Something went wrong. Please check your internet connection.';

  @override
  String get coachErrRecipes => 'Failed to cook up AI recipes.';

  @override
  String get coachErrRecipesGeneric => 'Failed to generate recipes. Try adding more simple ingredient terms.';

  @override
  String get coachFat => 'Fat';

  @override
  String get coachFormulate => 'Formulate 3 Recipes';

  @override
  String get coachGrade => 'Grade';

  @override
  String get coachInstructions => 'Prep & Cook Instructions:';

  @override
  String get coachLogged => 'Logged';

  @override
  String get coachLogMeal => 'Log Meal';

  @override
  String get coachMatchedOptions => 'Matched Meal Options';

  @override
  String coachMins(String n) {
    return '$n mins';
  }

  @override
  String get coachPantryDesc =>
      'Enter ingredients from your fridge/pantry to craft high-macro nutritious custom meals.';

  @override
  String get coachPantryPlaceholder => 'e.g. Chicken breast, sweet potato, spinach, olive oil';

  @override
  String get coachPantryTitle => 'Pantry Recipe Generator';

  @override
  String get coachProtein => 'Protein';

  @override
  String get coachRecommendations => 'Direct Recommendations';

  @override
  String get coachReviewDesc =>
      'Analyze today\'s calories, proteins, exercises, and overall trend to optimize your fitness.';

  @override
  String get coachReviewTitle => 'Daily Coach Review';

  @override
  String get coachRunReview => 'Run AI Coach Review';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonAdded => 'Added';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonClose => 'Close';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonDismiss => 'Dismiss';

  @override
  String get commonLoading => 'Loading…';

  @override
  String get commonOffline => 'You\'re offline — reconnect to sync';

  @override
  String get commonRecent => 'Recent';

  @override
  String get commonSave => 'Save';

  @override
  String get dashboardAdjustGoal => 'Adjust Goal';

  @override
  String get dashboardAdjustGoalTitle => 'Adjust Custom Goals';

  @override
  String get dashboardBalanceTitle => 'Calorie Balance & Goals';

  @override
  String get dashboardBurnedWorkouts => 'Burned Workouts';

  @override
  String get dashboardCaloriesLabel => 'Calories (kcal)';

  @override
  String get dashboardCarbohydrates => 'Carbohydrates';

  @override
  String get dashboardCarbsLabel => 'Carbs (g)';

  @override
  String get dashboardConsumedFood => 'Consumed Food';

  @override
  String get dashboardCustomGoalSettings => 'Custom Goal Settings';

  @override
  String get dashboardDailyBudget => 'Daily Budget:';

  @override
  String get dashboardExceeded => 'Exceeded';

  @override
  String get dashboardFatLabel => 'Fat (g)';

  @override
  String get dashboardFats => 'Fats';

  @override
  String get dashboardKcalLeft => 'kcal Left';

  @override
  String get dashboardMacrosNote =>
      'Macros contribute directly to muscle recovery and stable energy. Try logging balanced meals to match targets.';

  @override
  String get dashboardMacrosTitle => 'Daily Macronutrients';

  @override
  String get dashboardNetCalories => 'Net Calories:';

  @override
  String get dashboardOverTarget => 'Over Target';

  @override
  String dashboardPercentDone(String percent) {
    return '$percent% Done';
  }

  @override
  String get dashboardProtein => 'Protein';

  @override
  String get dashboardProteinLabel => 'Protein (g)';

  @override
  String get dashboardQuickAddExercise => 'Quick Log -150 kcal';

  @override
  String get dashboardQuickAddMeal => 'Quick Log +200 kcal';

  @override
  String get dashboardSaveGoals => 'Save Goals';

  @override
  String get dashboardStatusDone =>
      'You have completed your daily net calorie goal! Excellent work staying balanced today.';

  @override
  String dashboardStatusLeft(String kcal) {
    return 'You have $kcal kcal left for your active target. Keep going!';
  }

  @override
  String get dashboardToday => 'Today';

  @override
  String get dashboardYesterday => 'Yesterday';

  @override
  String get errAiBusy => 'The AI service is busy right now. Please try again in a moment.';

  @override
  String get errAiNotConfigured => 'AI features aren\'t available in this build yet.';

  @override
  String get errDeleteAccount => 'Couldn\'t delete your account. Please try again.';

  @override
  String get errDeleteEntry => 'Couldn\'t delete that entry. Please try again.';

  @override
  String get errGeneric => 'Something went wrong. Please try again.';

  @override
  String get errGoogleFailed => 'Google sign-in failed. Please try again.';

  @override
  String get errGoogleNotConfigured => 'Google sign-in isn\'t set up in this build yet.';

  @override
  String get errLoadData => 'Couldn\'t load your data. Check your connection and try again.';

  @override
  String get errNetwork => 'Network error. Please check your connection and try again.';

  @override
  String get errNotSignedIn => 'You\'re not signed in.';

  @override
  String get errResetData => 'Couldn\'t reset your data. Please try again.';

  @override
  String get errSaveEntry => 'Couldn\'t save that entry. Please try again.';

  @override
  String get errSaveGoal => 'Couldn\'t save your goal. Please try again.';

  @override
  String get errSaveProfile => 'Couldn\'t save your profile. Please try again.';

  @override
  String get errSaveWater => 'Couldn\'t save your water intake. Please try again.';

  @override
  String get exerciseActiveLogTitle => 'Active Workout Log';

  @override
  String get exerciseActiveMinutes => 'Active Minutes';

  @override
  String exerciseActivities(String n) {
    return '$n Activities';
  }

  @override
  String get exerciseAdjustDuration => 'Adjust Workout Duration';

  @override
  String get exerciseCaloriesBurned => 'Calories Burned (kcal)';

  @override
  String get exerciseCatalogTitle => 'Workout Catalog';

  @override
  String get exerciseCustomWorkout => 'Custom Workout';

  @override
  String get exerciseDeleteEntry => 'Delete Entry';

  @override
  String get exerciseDuration => 'Duration (minutes)';

  @override
  String exerciseDurationValue(String n) {
    return 'Duration: $n minutes';
  }

  @override
  String exerciseEstBurn(String kcal) {
    return 'Est. Burn: ~$kcal kcal per 30 mins';
  }

  @override
  String get exerciseExerciseDesc => 'Exercise Description *';

  @override
  String get exerciseKcalToday => 'kcal Today';

  @override
  String get exerciseLogCustomBtn => 'Log Custom Workout';

  @override
  String get exerciseLogCustomTitle => 'Log Custom Workout';

  @override
  String get exerciseLogExercise => 'Log Exercise';

  @override
  String exerciseMins(String n) {
    return '$n mins';
  }

  @override
  String exerciseMinutes(String n) {
    return '$n minutes';
  }

  @override
  String get exerciseNegativeCalories => 'Negative Calories';

  @override
  String get exerciseNoWorkouts => 'No negative calorie workouts logged yet today.';

  @override
  String get exercisePhCaloriesBurned => 'e.g. 240';

  @override
  String get exercisePhDuration => 'e.g. 30';

  @override
  String get exercisePhExerciseName => 'e.g. Crossfit / Rock Climbing / Tennis';

  @override
  String get exercisePresetWorkouts => 'Preset Workouts';

  @override
  String get exerciseRecentEmpty => 'Nothing logged yet — your workouts will appear here.';

  @override
  String get exerciseRecentTitle => 'Recent workouts';

  @override
  String get exerciseSearchPlaceholder => 'Search running, swimming, lifting...';

  @override
  String get foodAdjustPortion => 'Adjust Portion Multiplier';

  @override
  String get foodAiAnalyzing => 'Analyzing meal ingredients...';

  @override
  String get foodAiDesc => 'Type or speak any custom meal and get instant estimated nutrition. E.g.,';

  @override
  String get foodAiError => 'Gemini was unable to estimate nutrition for this text. Try a clearer description.';

  @override
  String get foodAiEstimateBtn => 'AI Estimate Calories & Macros';

  @override
  String get foodAiExample => '2 scrambled eggs with cheddar cheese and bacon slice';

  @override
  String get foodAiExtracted => 'AI Extracted Facts';

  @override
  String get foodAiPlaceholder => 'What did you eat? Describe ingredients...';

  @override
  String get foodAiTitle => 'Gemini AI Smart Assistant';

  @override
  String get foodCaloriesKcal => 'Calories (kcal)';

  @override
  String get foodCarbs => 'Carbs';

  @override
  String get foodCarbsG => 'Carbohydrates (g)';

  @override
  String get foodDbLookup => 'Database Lookup';

  @override
  String get foodDbSearchTitle => 'Food Database Search';

  @override
  String get foodDeleteEntry => 'Delete Entry';

  @override
  String get foodDiscard => 'Discard';

  @override
  String get foodFat => 'Fat';

  @override
  String get foodFatsG => 'Fats (g)';

  @override
  String get foodFoodName => 'Food Name *';

  @override
  String get foodHistoryTitle => 'Logged Meal History';

  @override
  String foodItemsLoaded(String n) {
    return '$n Items Loaded';
  }

  @override
  String get foodKcal => 'Kcal';

  @override
  String get foodLogAiMeal => 'Log AI Meal';

  @override
  String get foodLogCustomFood => 'Log Custom Food';

  @override
  String foodLogNamed(String name) {
    return 'Log $name';
  }

  @override
  String get foodManualAiLog => 'Manual & AI Log';

  @override
  String get foodManualTitle => 'Manual Custom Entry';

  @override
  String foodNoLogs(String date) {
    return 'No food logs completed for $date.';
  }

  @override
  String get foodNoMatch => 'No matching foods found in standard database. Switch to AI log!';

  @override
  String get foodNoOnlineMatches => 'No online matches';

  @override
  String get foodOnlineResults => 'Online results';

  @override
  String get foodPhCalories => 'e.g. 150';

  @override
  String get foodPhCarbs => 'e.g. 15';

  @override
  String get foodPhFat => 'e.g. 2';

  @override
  String get foodPhName => 'e.g. Vanilla Yogurt Cup';

  @override
  String get foodPhProtein => 'e.g. 8';

  @override
  String get foodPhServing => 'e.g. 150';

  @override
  String get foodPortion => 'Portion:';

  @override
  String get foodPortionSize => 'Portion size:';

  @override
  String get foodProtein => 'Protein';

  @override
  String get foodProteinG => 'Protein (g)';

  @override
  String get foodRecentEmpty => 'Nothing logged yet — your meals will appear here.';

  @override
  String get foodRecentTitle => 'Recent meals';

  @override
  String get foodSearchPlaceholder => 'Search oatmeal, eggs, avocado...';

  @override
  String get foodServing => 'Serving:';

  @override
  String get foodServingSize => 'Serving Size';

  @override
  String get foodTodayLower => 'today';

  @override
  String get foodTotal => 'Total:';

  @override
  String get foodUnit => 'Unit';

  @override
  String get foodYesterdayLower => 'yesterday';

  @override
  String get footerContact => 'Contact';

  @override
  String get footerDeleteAccount => 'Delete Account';

  @override
  String get footerEditProfile => 'Edit Profile';

  @override
  String get footerPrivacy => 'Privacy Policy';

  @override
  String get footerRate => 'Rate on Play';

  @override
  String get footerResetData => 'Reset Data';

  @override
  String get footerTagline => 'NutriFlow · AI diet, hydration & exercise tracker · © 2026';

  @override
  String footerVersion(String version) {
    return 'Version $version';
  }

  @override
  String get headerAiConnected => 'AI Engines Connected';

  @override
  String get headerDarkLabel => 'Deep Midnight';

  @override
  String get headerLightLabel => 'High Contrast Light';

  @override
  String get headerLoggedDate => 'Logged date:';

  @override
  String get headerSignOut => 'Sign Out';

  @override
  String get headerSyncOn => 'Sync On';

  @override
  String get headerTagline => 'Professional Diet, Hydration, and Active Workout Workspace';

  @override
  String get headerThemeToDark => 'Switch to Deep Midnight Theme';

  @override
  String get headerThemeToLight => 'Switch to High Contrast Light Theme';

  @override
  String get langLabel => 'Language';

  @override
  String modalsDeleteBody(String who) {
    return 'This permanently deletes $who and all your data — meals, exercises, goals, and hydration. This action cannot be undone.';
  }

  @override
  String get modalsDeleteBtn => 'Delete';

  @override
  String get modalsDeleteConfirmPost => 'to confirm';

  @override
  String get modalsDeleteConfirmPre => 'Type';

  @override
  String get modalsDeleteTitle => 'Delete account';

  @override
  String get modalsDeleteYourAccount => 'your account';

  @override
  String get modalsDeleting => 'Deleting…';

  @override
  String get modalsResetBody =>
      'This permanently deletes all your logged meals, exercises, and hydration across every day. Your account, profile, and calorie/macro goal are kept. This can’t be undone.';

  @override
  String get modalsResetBtn => 'Reset data';

  @override
  String get modalsResetDone => 'Data reset';

  @override
  String get modalsResetDoneNote => 'Your logs are cleared — fresh start!';

  @override
  String get modalsResetting => 'Resetting…';

  @override
  String get modalsResetTitle => 'Reset logged data';

  @override
  String get navActive => 'Active';

  @override
  String get navCoach => 'AI Coach';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navMeals => 'Meals';

  @override
  String get navScan => 'UPC Scan';

  @override
  String get navTrends => 'Trends';

  @override
  String get onboardingActivitiesExtraHint => 'Physical job / 2× a day';

  @override
  String get onboardingActivitiesExtraLabel => 'Extra active';

  @override
  String get onboardingActivitiesLightHint => '1–3 days/week';

  @override
  String get onboardingActivitiesLightLabel => 'Lightly active';

  @override
  String get onboardingActivitiesModerateHint => '3–5 days/week';

  @override
  String get onboardingActivitiesModerateLabel => 'Moderately active';

  @override
  String get onboardingActivitiesSedentaryHint => 'Little or no exercise';

  @override
  String get onboardingActivitiesSedentaryLabel => 'Sedentary';

  @override
  String get onboardingActivitiesVeryHint => '6–7 days/week';

  @override
  String get onboardingActivitiesVeryLabel => 'Very active';

  @override
  String get onboardingAgeLabel => 'Age';

  @override
  String get onboardingAgePlaceholder => 'e.g. 28';

  @override
  String get onboardingBack => 'Back';

  @override
  String get onboardingCarbs => 'Carbs';

  @override
  String get onboardingContinue => 'Continue';

  @override
  String get onboardingCurrentWeightLabel => 'Current weight';

  @override
  String get onboardingDailyCalories => 'Daily calories';

  @override
  String get onboardingDietsHighProtein => 'High protein';

  @override
  String get onboardingDietsKeto => 'Keto';

  @override
  String get onboardingDietsLowCarb => 'Low carb';

  @override
  String get onboardingDietsMediterranean => 'Mediterranean';

  @override
  String get onboardingDietsNone => 'Balanced';

  @override
  String get onboardingDietsPaleo => 'Paleo';

  @override
  String get onboardingDietsVegan => 'Vegan';

  @override
  String get onboardingDietsVegetarian => 'Vegetarian';

  @override
  String get onboardingEditTitle => 'Edit your profile';

  @override
  String get onboardingFat => 'Fat';

  @override
  String get onboardingGoalsBuildMuscleHint => 'Lean bulk, high protein';

  @override
  String get onboardingGoalsBuildMuscleLabel => 'Build muscle';

  @override
  String get onboardingGoalsGainHint => 'Calorie surplus';

  @override
  String get onboardingGoalsGainLabel => 'Gain weight';

  @override
  String get onboardingGoalsLoseHint => 'Calorie deficit';

  @override
  String get onboardingGoalsLoseLabel => 'Lose weight';

  @override
  String get onboardingGoalsMaintainHint => 'Stay where I am';

  @override
  String get onboardingGoalsMaintainLabel => 'Maintain';

  @override
  String get onboardingHeightLabel => 'Height';

  @override
  String get onboardingImperial => 'Imperial (lb/ft)';

  @override
  String get onboardingMetric => 'Metric (kg/cm)';

  @override
  String get onboardingOptional => '(optional)';

  @override
  String get onboardingPersonalizeTitle => 'Let’s personalize NutriFlow';

  @override
  String get onboardingPromoSecondary => 'I already have an account';

  @override
  String get onboardingPromoSubmit => 'Create account to save';

  @override
  String get onboardingPromoTitle => 'Build your free nutrition plan';

  @override
  String get onboardingProtein => 'Protein';

  @override
  String get onboardingRestrictionsDairy => 'Dairy';

  @override
  String get onboardingRestrictionsEggs => 'Eggs';

  @override
  String get onboardingRestrictionsGluten => 'Gluten';

  @override
  String get onboardingRestrictionsLabel => 'Any restrictions / allergies?';

  @override
  String get onboardingRestrictionsNuts => 'Nuts';

  @override
  String get onboardingRestrictionsPork => 'Pork';

  @override
  String get onboardingRestrictionsShellfish => 'Shellfish';

  @override
  String get onboardingRestrictionsSoy => 'Soy';

  @override
  String get onboardingReviewNote =>
      'Calculated from your details (Mifflin–St Jeor). You can fine-tune these anytime from the dashboard.';

  @override
  String get onboardingSaveChanges => 'Save changes';

  @override
  String get onboardingSaving => 'Saving…';

  @override
  String get onboardingSexesFemale => 'Female';

  @override
  String get onboardingSexesMale => 'Male';

  @override
  String get onboardingSexesOther => 'Other';

  @override
  String get onboardingSexLabel => 'Sex (for calorie estimate)';

  @override
  String get onboardingSignOut => 'Sign out';

  @override
  String get onboardingStartTracking => 'Start tracking';

  @override
  String get onboardingStep0Title => 'What’s your main goal?';

  @override
  String get onboardingStep1Title => 'A bit about you';

  @override
  String get onboardingStep2Title => 'Your measurements';

  @override
  String get onboardingStep3Title => 'How active are you?';

  @override
  String get onboardingStep4Title => 'Dietary preference';

  @override
  String get onboardingStep5Title => 'Preferences';

  @override
  String get onboardingStep6Title => 'Your personalized daily targets';

  @override
  String onboardingStepOf(String current, String total) {
    return 'Step $current of $total';
  }

  @override
  String get onboardingStepsAbout => 'About you';

  @override
  String get onboardingStepsActivity => 'Activity';

  @override
  String get onboardingStepsBody => 'Body';

  @override
  String get onboardingStepsDiet => 'Diet';

  @override
  String get onboardingStepsGoal => 'Goal';

  @override
  String get onboardingStepsPrefs => 'Preferences';

  @override
  String get onboardingStepsReview => 'Review';

  @override
  String get onboardingTargetWeightLabel => 'Target weight';

  @override
  String get onboardingWorkoutsCardio => 'Cardio';

  @override
  String get onboardingWorkoutsCycling => 'Cycling';

  @override
  String get onboardingWorkoutsHIIT => 'HIIT';

  @override
  String get onboardingWorkoutsLabel => 'Workouts you enjoy';

  @override
  String get onboardingWorkoutsRunning => 'Running';

  @override
  String get onboardingWorkoutsStrength => 'Strength';

  @override
  String get onboardingWorkoutsSwimming => 'Swimming';

  @override
  String get onboardingWorkoutsWalking => 'Walking';

  @override
  String get onboardingWorkoutsYoga => 'Yoga';

  @override
  String get passwordConfirmLabel => 'Confirm new password';

  @override
  String get passwordConfirmPlaceholder => 'Re-enter password';

  @override
  String get passwordErrGeneric => 'Could not update your password. Please try again.';

  @override
  String get passwordErrMinLength => 'Password must be at least 6 characters.';

  @override
  String get passwordErrMismatch => 'Passwords don\'t match.';

  @override
  String get passwordHidePassword => 'Hide password';

  @override
  String get passwordNewPassword => 'New password';

  @override
  String get passwordNewPlaceholder => 'At least 6 characters';

  @override
  String get passwordShowPassword => 'Show password';

  @override
  String get passwordSubtitle => 'Choose a new password';

  @override
  String get passwordUpdateBtn => 'Update password';

  @override
  String get passwordUpdated => 'Password updated';

  @override
  String get passwordUpdatedNote => 'You\'re all set — loading your dashboard…';

  @override
  String get passwordUpdating => 'Updating…';

  @override
  String get photoAiEstimate => 'AI Estimate';

  @override
  String get photoAnalyzing => 'Analyzing your meal…';

  @override
  String get photoCalories => 'Calories';

  @override
  String get photoCapture => 'Capture';

  @override
  String get photoCarbsG => 'Carbs g';

  @override
  String get photoCloseCamera => 'Close camera';

  @override
  String get photoDesc =>
      'Take or upload a food photo — AI estimates the calories and macros, then you review and log it.';

  @override
  String get photoErrAnalysisDefault => 'Analysis failed. Please try again.';

  @override
  String get photoErrAnalyze => 'Couldn\'t analyze that photo. Please try again.';

  @override
  String get photoErrCamera => 'Camera permission was denied or is unavailable. Use Upload instead.';

  @override
  String get photoErrCapture => 'Couldn\'t capture the photo. Try again.';

  @override
  String get photoErrRead => 'Couldn\'t read that image. Please try another.';

  @override
  String get photoFatG => 'Fat g';

  @override
  String get photoIdleDesc => 'Use your camera to photograph your plate, or pick an existing photo from your gallery.';

  @override
  String get photoIdleTitle => 'Snap or upload a meal';

  @override
  String get photoLoggedDiary => 'Logged to your diary!';

  @override
  String get photoLogMeal => 'Log meal';

  @override
  String get photoMealNamePlaceholder => 'Meal name';

  @override
  String get photoNoFood => 'No food detected. Try a clearer, closer shot of your plate.';

  @override
  String get photoPreviewAlt => 'Meal preview';

  @override
  String get photoProteinG => 'Protein g';

  @override
  String get photoRemovePhoto => 'Remove photo';

  @override
  String get photoRetry => 'Retry';

  @override
  String get photoReviewAdjust => 'Review & adjust before logging';

  @override
  String get photoTakePhoto => 'Take Photo';

  @override
  String get photoTitle => 'Snap a Meal';

  @override
  String get photoTryAnother => 'Try another';

  @override
  String get photoUpload => 'Upload';

  @override
  String get scannerCarbs => 'Carbohydrates';

  @override
  String get scannerClear => 'Clear';

  @override
  String get scannerDescManual =>
      'Enter a product\'s UPC/EAN barcode to look it up in Open Food Facts. Unknown codes fall back to an AI estimate.';

  @override
  String get scannerDescSupported =>
      'Scan a product barcode with your camera, or enter it manually. Looked up in Open Food Facts — unknown codes fall back to an AI estimate.';

  @override
  String get scannerErrCamera =>
      'Camera permission was denied or is unavailable. You can still enter the barcode number manually below.';

  @override
  String get scannerErrLookup => 'Barcode analysis failed. Try a pre-registered code or check environment.';

  @override
  String get scannerFats => 'Fats';

  @override
  String get scannerLiveViewport => 'Live Viewport';

  @override
  String get scannerLogToLog => 'Log to Meal Log';

  @override
  String get scannerLookup => 'Look up';

  @override
  String get scannerManualDesc =>
      'Live scanning isn\'t available on this browser. You can still type the barcode number below.';

  @override
  String get scannerManualLabel => 'Or enter the barcode manually';

  @override
  String get scannerManualTitle => 'Manual Entry Recommended';

  @override
  String get scannerMatchScanned => 'Match Scanned!';

  @override
  String get scannerPlaceholder => 'Enter numeric UPC/EAN code...';

  @override
  String get scannerProtein => 'Protein';

  @override
  String get scannerReadyDesc => 'Point your camera at a product barcode — it scans and looks it up automatically.';

  @override
  String get scannerReadyTitle => 'Camera Scanner Ready';

  @override
  String scannerServingQty(String size, String unit) {
    return 'Serving Quantity: $size $unit';
  }

  @override
  String get scannerStatusPoint => 'Point the camera at a barcode — it scans automatically.';

  @override
  String get scannerStatusStarting => 'Starting camera view...';

  @override
  String get scannerStatusUnsupported =>
      'Live scanning isn\'t supported on this browser — enter the code manually below.';

  @override
  String get scannerStopCamera => 'Stop Camera Feed';

  @override
  String get scannerTitle => 'Barcode Scanner';

  @override
  String get scannerUseCamera => 'Use Device Camera';

  @override
  String get waterCup => 'Cup';

  @override
  String get waterGlass => 'Glass';

  @override
  String get waterHydrated => 'Hydrated';

  @override
  String get waterPerfect => 'Perfect hydration! Goal exceeded today.';

  @override
  String get waterReduce => 'Reduce';

  @override
  String get waterReduceTitle => 'Reduce water log';

  @override
  String waterRemaining(String ml) {
    return '$ml ml remaining to meet daily baseline.';
  }

  @override
  String get waterTarget => 'Target: 2.5L';

  @override
  String get waterTitle => 'Hydration Tracker';
}
