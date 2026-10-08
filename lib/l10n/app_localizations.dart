import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bs.dart';
import 'app_localizations_en.dart';
import 'app_localizations_hr.dart';
import 'app_localizations_sr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('bs'), Locale('en'), Locale('hr'), Locale('sr')];

  /// No description provided for @appLoadFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your data'**
  String get appLoadFailedTitle;

  /// No description provided for @appLoadingWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Loading your workspace…'**
  String get appLoadingWorkspace;

  /// No description provided for @appRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get appRetry;

  /// No description provided for @appSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing your data…'**
  String get appSyncing;

  /// No description provided for @authBackToSignin.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get authBackToSignin;

  /// No description provided for @authBuildPlan.
  ///
  /// In en, this message translates to:
  /// **'New here? Build your free plan first'**
  String get authBuildPlan;

  /// No description provided for @authContinueGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authContinueGoogle;

  /// No description provided for @authCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get authCreateAccount;

  /// No description provided for @authEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authEmailPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get authEmailPlaceholder;

  /// No description provided for @authErrGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get authErrGeneric;

  /// No description provided for @authForgot.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgot;

  /// No description provided for @authHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get authHaveAccount;

  /// No description provided for @authHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get authHidePassword;

  /// No description provided for @authInfoConfirm.
  ///
  /// In en, this message translates to:
  /// **'Account created! Check your email to confirm, then sign in.'**
  String get authInfoConfirm;

  /// No description provided for @authInfoReset.
  ///
  /// In en, this message translates to:
  /// **'If an account exists for that email, a password reset link is on its way. Check your inbox.'**
  String get authInfoReset;

  /// No description provided for @authNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get authNoAccount;

  /// No description provided for @authOr.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get authOr;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authPasswordPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Your password'**
  String get authPasswordPlaceholder;

  /// No description provided for @authPasswordPlaceholderSignup.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get authPasswordPlaceholderSignup;

  /// No description provided for @authPleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get authPleaseWait;

  /// No description provided for @authPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'Your data is private and secured per-account with row-level security.'**
  String get authPrivacyNote;

  /// No description provided for @authPromoSaved.
  ///
  /// In en, this message translates to:
  /// **'Your plan is ready — create an account to save it.'**
  String get authPromoSaved;

  /// No description provided for @authSendReset.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get authSendReset;

  /// No description provided for @authShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get authShowPassword;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get authSignIn;

  /// No description provided for @authSignInLink.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignInLink;

  /// No description provided for @authSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get authSignUp;

  /// No description provided for @authSubtitleReset.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to reset your password.'**
  String get authSubtitleReset;

  /// No description provided for @authSubtitleSignin.
  ///
  /// In en, this message translates to:
  /// **'Welcome back. Sign in to continue.'**
  String get authSubtitleSignin;

  /// No description provided for @authSubtitleSignup.
  ///
  /// In en, this message translates to:
  /// **'Create your account to get started.'**
  String get authSubtitleSignup;

  /// No description provided for @chartsAchievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get chartsAchievements;

  /// No description provided for @chartsAchievementsExplainer.
  ///
  /// In en, this message translates to:
  /// **'Log a meal, workout, or water on any day to keep your streak alive — miss a whole day and it resets. Stay consistent to unlock these:'**
  String get chartsAchievementsExplainer;

  /// No description provided for @chartsActiveBurn.
  ///
  /// In en, this message translates to:
  /// **'Active Burn'**
  String get chartsActiveBurn;

  /// No description provided for @chartsBadgesCenturyDesc.
  ///
  /// In en, this message translates to:
  /// **'Log 100 items total'**
  String get chartsBadgesCenturyDesc;

  /// No description provided for @chartsBadgesCenturyLabel.
  ///
  /// In en, this message translates to:
  /// **'Centurion'**
  String get chartsBadgesCenturyLabel;

  /// No description provided for @chartsBadgesHydratedDesc.
  ///
  /// In en, this message translates to:
  /// **'Log water on 7 days'**
  String get chartsBadgesHydratedDesc;

  /// No description provided for @chartsBadgesHydratedLabel.
  ///
  /// In en, this message translates to:
  /// **'Hydrated'**
  String get chartsBadgesHydratedLabel;

  /// No description provided for @chartsBadgesStartDesc.
  ///
  /// In en, this message translates to:
  /// **'Log your first item'**
  String get chartsBadgesStartDesc;

  /// No description provided for @chartsBadgesStartLabel.
  ///
  /// In en, this message translates to:
  /// **'Getting Started'**
  String get chartsBadgesStartLabel;

  /// No description provided for @chartsBadgesStreak14Desc.
  ///
  /// In en, this message translates to:
  /// **'Reach a 14-day streak'**
  String get chartsBadgesStreak14Desc;

  /// No description provided for @chartsBadgesStreak14Label.
  ///
  /// In en, this message translates to:
  /// **'Dedicated'**
  String get chartsBadgesStreak14Label;

  /// No description provided for @chartsBadgesStreak30Desc.
  ///
  /// In en, this message translates to:
  /// **'Reach a 30-day streak'**
  String get chartsBadgesStreak30Desc;

  /// No description provided for @chartsBadgesStreak30Label.
  ///
  /// In en, this message translates to:
  /// **'Unstoppable'**
  String get chartsBadgesStreak30Label;

  /// No description provided for @chartsBadgesStreak3Desc.
  ///
  /// In en, this message translates to:
  /// **'Reach a 3-day streak'**
  String get chartsBadgesStreak3Desc;

  /// No description provided for @chartsBadgesStreak3Label.
  ///
  /// In en, this message translates to:
  /// **'Consistent'**
  String get chartsBadgesStreak3Label;

  /// No description provided for @chartsBadgesStreak7Desc.
  ///
  /// In en, this message translates to:
  /// **'Reach a 7-day streak'**
  String get chartsBadgesStreak7Desc;

  /// No description provided for @chartsBadgesStreak7Label.
  ///
  /// In en, this message translates to:
  /// **'On Fire'**
  String get chartsBadgesStreak7Label;

  /// No description provided for @chartsCarbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get chartsCarbs;

  /// No description provided for @chartsDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} day} other{{count} days}}'**
  String chartsDays(int count);

  /// No description provided for @chartsDefaultTemplate.
  ///
  /// In en, this message translates to:
  /// **'Default balanced template displayed. Please log food items in the database to see live ratios!'**
  String get chartsDefaultTemplate;

  /// No description provided for @chartsEnergyDesc.
  ///
  /// In en, this message translates to:
  /// **'Breakdown of daily energy contributions (kcal percentage) derived from logged proteins, carbs, and fats.'**
  String get chartsEnergyDesc;

  /// No description provided for @chartsEnergyTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Energy Share'**
  String get chartsEnergyTitle;

  /// No description provided for @chartsFat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get chartsFat;

  /// No description provided for @chartsFoodIngested.
  ///
  /// In en, this message translates to:
  /// **'Food Ingested'**
  String get chartsFoodIngested;

  /// No description provided for @chartsGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get chartsGoal;

  /// No description provided for @chartsNetCalories.
  ///
  /// In en, this message translates to:
  /// **'Net Calories'**
  String get chartsNetCalories;

  /// No description provided for @chartsOfCalories.
  ///
  /// In en, this message translates to:
  /// **'{value}% of calories'**
  String chartsOfCalories(String value);

  /// No description provided for @chartsProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get chartsProtein;

  /// No description provided for @chartsStartStreak.
  ///
  /// In en, this message translates to:
  /// **'Start a Streak'**
  String get chartsStartStreak;

  /// No description provided for @chartsStreakAlive.
  ///
  /// In en, this message translates to:
  /// **'Your streak is alive — log anything today to extend it. Longest: {longest}.'**
  String chartsStreakAlive(String longest);

  /// No description provided for @chartsStreakStart.
  ///
  /// In en, this message translates to:
  /// **'Log a meal, workout, or water today to begin your streak!'**
  String get chartsStreakStart;

  /// No description provided for @chartsStreakTitle.
  ///
  /// In en, this message translates to:
  /// **'{n}-Day Streak'**
  String chartsStreakTitle(String n, String days);

  /// No description provided for @chartsStreakToday.
  ///
  /// In en, this message translates to:
  /// **'Nice work today! Keep it going — longest streak: {longest}.'**
  String chartsStreakToday(String longest);

  /// No description provided for @chartsTotalLogged.
  ///
  /// In en, this message translates to:
  /// **'Total Logged'**
  String get chartsTotalLogged;

  /// No description provided for @chartsTrendDesc.
  ///
  /// In en, this message translates to:
  /// **'Compares total food consumed against negative burned workout calories versus daily budget.'**
  String get chartsTrendDesc;

  /// No description provided for @chartsTrendTitle.
  ///
  /// In en, this message translates to:
  /// **'7-Day Balance Trend'**
  String get chartsTrendTitle;

  /// No description provided for @coachAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'Cooking Analysis...'**
  String get coachAnalyzing;

  /// No description provided for @coachCalories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get coachCalories;

  /// No description provided for @coachCarbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get coachCarbs;

  /// No description provided for @coachChefTab.
  ///
  /// In en, this message translates to:
  /// **'AI Chef Recipes'**
  String get coachChefTab;

  /// No description provided for @coachCoachRating.
  ///
  /// In en, this message translates to:
  /// **'Coach Rating'**
  String get coachCoachRating;

  /// No description provided for @coachCookingRecipes.
  ///
  /// In en, this message translates to:
  /// **'Cooking Recipes...'**
  String get coachCookingRecipes;

  /// No description provided for @coachDailyCoachTab.
  ///
  /// In en, this message translates to:
  /// **'AI Daily Coach'**
  String get coachDailyCoachTab;

  /// No description provided for @coachDietitianSummary.
  ///
  /// In en, this message translates to:
  /// **'Dietitian Summary'**
  String get coachDietitianSummary;

  /// No description provided for @coachErrCoach.
  ///
  /// In en, this message translates to:
  /// **'Failed to get response from AI coach.'**
  String get coachErrCoach;

  /// No description provided for @coachErrGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please check your internet connection.'**
  String get coachErrGeneric;

  /// No description provided for @coachErrRecipes.
  ///
  /// In en, this message translates to:
  /// **'Failed to cook up AI recipes.'**
  String get coachErrRecipes;

  /// No description provided for @coachErrRecipesGeneric.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate recipes. Try adding more simple ingredient terms.'**
  String get coachErrRecipesGeneric;

  /// No description provided for @coachFat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get coachFat;

  /// No description provided for @coachFormulate.
  ///
  /// In en, this message translates to:
  /// **'Formulate 3 Recipes'**
  String get coachFormulate;

  /// No description provided for @coachGrade.
  ///
  /// In en, this message translates to:
  /// **'Grade'**
  String get coachGrade;

  /// No description provided for @coachInstructions.
  ///
  /// In en, this message translates to:
  /// **'Prep & Cook Instructions:'**
  String get coachInstructions;

  /// No description provided for @coachLogged.
  ///
  /// In en, this message translates to:
  /// **'Logged'**
  String get coachLogged;

  /// No description provided for @coachLogMeal.
  ///
  /// In en, this message translates to:
  /// **'Log Meal'**
  String get coachLogMeal;

  /// No description provided for @coachMatchedOptions.
  ///
  /// In en, this message translates to:
  /// **'Matched Meal Options'**
  String get coachMatchedOptions;

  /// No description provided for @coachMins.
  ///
  /// In en, this message translates to:
  /// **'{n} mins'**
  String coachMins(String n);

  /// No description provided for @coachPantryDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter ingredients from your fridge/pantry to craft high-macro nutritious custom meals.'**
  String get coachPantryDesc;

  /// No description provided for @coachPantryPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. Chicken breast, sweet potato, spinach, olive oil'**
  String get coachPantryPlaceholder;

  /// No description provided for @coachPantryTitle.
  ///
  /// In en, this message translates to:
  /// **'Pantry Recipe Generator'**
  String get coachPantryTitle;

  /// No description provided for @coachProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get coachProtein;

  /// No description provided for @coachRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Direct Recommendations'**
  String get coachRecommendations;

  /// No description provided for @coachReviewDesc.
  ///
  /// In en, this message translates to:
  /// **'Analyze today\'s calories, proteins, exercises, and overall trend to optimize your fitness.'**
  String get coachReviewDesc;

  /// No description provided for @coachReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Coach Review'**
  String get coachReviewTitle;

  /// No description provided for @coachRunReview.
  ///
  /// In en, this message translates to:
  /// **'Run AI Coach Review'**
  String get coachRunReview;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @commonAdded.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get commonAdded;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get commonDismiss;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get commonLoading;

  /// No description provided for @commonOffline.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline — reconnect to sync'**
  String get commonOffline;

  /// No description provided for @commonRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get commonRecent;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @dashboardAdjustGoal.
  ///
  /// In en, this message translates to:
  /// **'Adjust Goal'**
  String get dashboardAdjustGoal;

  /// No description provided for @dashboardAdjustGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Adjust Custom Goals'**
  String get dashboardAdjustGoalTitle;

  /// No description provided for @dashboardBalanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Calorie Balance & Goals'**
  String get dashboardBalanceTitle;

  /// No description provided for @dashboardBurnedWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Burned Workouts'**
  String get dashboardBurnedWorkouts;

  /// No description provided for @dashboardCaloriesLabel.
  ///
  /// In en, this message translates to:
  /// **'Calories (kcal)'**
  String get dashboardCaloriesLabel;

  /// No description provided for @dashboardCarbohydrates.
  ///
  /// In en, this message translates to:
  /// **'Carbohydrates'**
  String get dashboardCarbohydrates;

  /// No description provided for @dashboardCarbsLabel.
  ///
  /// In en, this message translates to:
  /// **'Carbs (g)'**
  String get dashboardCarbsLabel;

  /// No description provided for @dashboardConsumedFood.
  ///
  /// In en, this message translates to:
  /// **'Consumed Food'**
  String get dashboardConsumedFood;

  /// No description provided for @dashboardCustomGoalSettings.
  ///
  /// In en, this message translates to:
  /// **'Custom Goal Settings'**
  String get dashboardCustomGoalSettings;

  /// No description provided for @dashboardDailyBudget.
  ///
  /// In en, this message translates to:
  /// **'Daily Budget:'**
  String get dashboardDailyBudget;

  /// No description provided for @dashboardExceeded.
  ///
  /// In en, this message translates to:
  /// **'Exceeded'**
  String get dashboardExceeded;

  /// No description provided for @dashboardFatLabel.
  ///
  /// In en, this message translates to:
  /// **'Fat (g)'**
  String get dashboardFatLabel;

  /// No description provided for @dashboardFats.
  ///
  /// In en, this message translates to:
  /// **'Fats'**
  String get dashboardFats;

  /// No description provided for @dashboardKcalLeft.
  ///
  /// In en, this message translates to:
  /// **'kcal Left'**
  String get dashboardKcalLeft;

  /// No description provided for @dashboardMacrosNote.
  ///
  /// In en, this message translates to:
  /// **'Macros contribute directly to muscle recovery and stable energy. Try logging balanced meals to match targets.'**
  String get dashboardMacrosNote;

  /// No description provided for @dashboardMacrosTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Macronutrients'**
  String get dashboardMacrosTitle;

  /// No description provided for @dashboardNetCalories.
  ///
  /// In en, this message translates to:
  /// **'Net Calories:'**
  String get dashboardNetCalories;

  /// No description provided for @dashboardOverTarget.
  ///
  /// In en, this message translates to:
  /// **'Over Target'**
  String get dashboardOverTarget;

  /// No description provided for @dashboardPercentDone.
  ///
  /// In en, this message translates to:
  /// **'{percent}% Done'**
  String dashboardPercentDone(String percent);

  /// No description provided for @dashboardProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get dashboardProtein;

  /// No description provided for @dashboardProteinLabel.
  ///
  /// In en, this message translates to:
  /// **'Protein (g)'**
  String get dashboardProteinLabel;

  /// No description provided for @dashboardQuickAddExercise.
  ///
  /// In en, this message translates to:
  /// **'Quick Log -150 kcal'**
  String get dashboardQuickAddExercise;

  /// No description provided for @dashboardQuickAddMeal.
  ///
  /// In en, this message translates to:
  /// **'Quick Log +200 kcal'**
  String get dashboardQuickAddMeal;

  /// No description provided for @dashboardSaveGoals.
  ///
  /// In en, this message translates to:
  /// **'Save Goals'**
  String get dashboardSaveGoals;

  /// No description provided for @dashboardStatusDone.
  ///
  /// In en, this message translates to:
  /// **'You have completed your daily net calorie goal! Excellent work staying balanced today.'**
  String get dashboardStatusDone;

  /// No description provided for @dashboardStatusLeft.
  ///
  /// In en, this message translates to:
  /// **'You have {kcal} kcal left for your active target. Keep going!'**
  String dashboardStatusLeft(String kcal);

  /// No description provided for @dashboardToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dashboardToday;

  /// No description provided for @dashboardYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get dashboardYesterday;

  /// No description provided for @errAiBusy.
  ///
  /// In en, this message translates to:
  /// **'The AI service is busy right now. Please try again in a moment.'**
  String get errAiBusy;

  /// No description provided for @errAiNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'AI features aren\'t available in this build yet.'**
  String get errAiNotConfigured;

  /// No description provided for @errDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete your account. Please try again.'**
  String get errDeleteAccount;

  /// No description provided for @errDeleteEntry.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete that entry. Please try again.'**
  String get errDeleteEntry;

  /// No description provided for @errGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errGeneric;

  /// No description provided for @errGoogleFailed.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed. Please try again.'**
  String get errGoogleFailed;

  /// No description provided for @errGoogleNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in isn\'t set up in this build yet.'**
  String get errGoogleNotConfigured;

  /// No description provided for @errLoadData.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your data. Check your connection and try again.'**
  String get errLoadData;

  /// No description provided for @errNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection and try again.'**
  String get errNetwork;

  /// No description provided for @errNotSignedIn.
  ///
  /// In en, this message translates to:
  /// **'You\'re not signed in.'**
  String get errNotSignedIn;

  /// No description provided for @errResetData.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reset your data. Please try again.'**
  String get errResetData;

  /// No description provided for @errSaveEntry.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save that entry. Please try again.'**
  String get errSaveEntry;

  /// No description provided for @errSaveGoal.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save your goal. Please try again.'**
  String get errSaveGoal;

  /// No description provided for @errSaveProfile.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save your profile. Please try again.'**
  String get errSaveProfile;

  /// No description provided for @errSaveWater.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save your water intake. Please try again.'**
  String get errSaveWater;

  /// No description provided for @exerciseActiveLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Active Workout Log'**
  String get exerciseActiveLogTitle;

  /// No description provided for @exerciseActiveMinutes.
  ///
  /// In en, this message translates to:
  /// **'Active Minutes'**
  String get exerciseActiveMinutes;

  /// No description provided for @exerciseActivities.
  ///
  /// In en, this message translates to:
  /// **'{n} Activities'**
  String exerciseActivities(String n);

  /// No description provided for @exerciseAdjustDuration.
  ///
  /// In en, this message translates to:
  /// **'Adjust Workout Duration'**
  String get exerciseAdjustDuration;

  /// No description provided for @exerciseCaloriesBurned.
  ///
  /// In en, this message translates to:
  /// **'Calories Burned (kcal)'**
  String get exerciseCaloriesBurned;

  /// No description provided for @exerciseCatalogTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout Catalog'**
  String get exerciseCatalogTitle;

  /// No description provided for @exerciseCustomWorkout.
  ///
  /// In en, this message translates to:
  /// **'Custom Workout'**
  String get exerciseCustomWorkout;

  /// No description provided for @exerciseDeleteEntry.
  ///
  /// In en, this message translates to:
  /// **'Delete Entry'**
  String get exerciseDeleteEntry;

  /// No description provided for @exerciseDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration (minutes)'**
  String get exerciseDuration;

  /// No description provided for @exerciseDurationValue.
  ///
  /// In en, this message translates to:
  /// **'Duration: {n} minutes'**
  String exerciseDurationValue(String n);

  /// No description provided for @exerciseEstBurn.
  ///
  /// In en, this message translates to:
  /// **'Est. Burn: ~{kcal} kcal per 30 mins'**
  String exerciseEstBurn(String kcal);

  /// No description provided for @exerciseExerciseDesc.
  ///
  /// In en, this message translates to:
  /// **'Exercise Description *'**
  String get exerciseExerciseDesc;

  /// No description provided for @exerciseKcalToday.
  ///
  /// In en, this message translates to:
  /// **'kcal Today'**
  String get exerciseKcalToday;

  /// No description provided for @exerciseLogCustomBtn.
  ///
  /// In en, this message translates to:
  /// **'Log Custom Workout'**
  String get exerciseLogCustomBtn;

  /// No description provided for @exerciseLogCustomTitle.
  ///
  /// In en, this message translates to:
  /// **'Log Custom Workout'**
  String get exerciseLogCustomTitle;

  /// No description provided for @exerciseLogExercise.
  ///
  /// In en, this message translates to:
  /// **'Log Exercise'**
  String get exerciseLogExercise;

  /// No description provided for @exerciseMins.
  ///
  /// In en, this message translates to:
  /// **'{n} mins'**
  String exerciseMins(String n);

  /// No description provided for @exerciseMinutes.
  ///
  /// In en, this message translates to:
  /// **'{n} minutes'**
  String exerciseMinutes(String n);

  /// No description provided for @exerciseNegativeCalories.
  ///
  /// In en, this message translates to:
  /// **'Negative Calories'**
  String get exerciseNegativeCalories;

  /// No description provided for @exerciseNoWorkouts.
  ///
  /// In en, this message translates to:
  /// **'No negative calorie workouts logged yet today.'**
  String get exerciseNoWorkouts;

  /// No description provided for @exercisePhCaloriesBurned.
  ///
  /// In en, this message translates to:
  /// **'e.g. 240'**
  String get exercisePhCaloriesBurned;

  /// No description provided for @exercisePhDuration.
  ///
  /// In en, this message translates to:
  /// **'e.g. 30'**
  String get exercisePhDuration;

  /// No description provided for @exercisePhExerciseName.
  ///
  /// In en, this message translates to:
  /// **'e.g. Crossfit / Rock Climbing / Tennis'**
  String get exercisePhExerciseName;

  /// No description provided for @exercisePresetWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Preset Workouts'**
  String get exercisePresetWorkouts;

  /// No description provided for @exerciseRecentEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing logged yet — your workouts will appear here.'**
  String get exerciseRecentEmpty;

  /// No description provided for @exerciseRecentTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent workouts'**
  String get exerciseRecentTitle;

  /// No description provided for @exerciseSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search running, swimming, lifting...'**
  String get exerciseSearchPlaceholder;

  /// No description provided for @foodAdjustPortion.
  ///
  /// In en, this message translates to:
  /// **'Adjust Portion Multiplier'**
  String get foodAdjustPortion;

  /// No description provided for @foodAiAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing meal ingredients...'**
  String get foodAiAnalyzing;

  /// No description provided for @foodAiDesc.
  ///
  /// In en, this message translates to:
  /// **'Type or speak any custom meal and get instant estimated nutrition. E.g.,'**
  String get foodAiDesc;

  /// No description provided for @foodAiError.
  ///
  /// In en, this message translates to:
  /// **'Gemini was unable to estimate nutrition for this text. Try a clearer description.'**
  String get foodAiError;

  /// No description provided for @foodAiEstimateBtn.
  ///
  /// In en, this message translates to:
  /// **'AI Estimate Calories & Macros'**
  String get foodAiEstimateBtn;

  /// No description provided for @foodAiExample.
  ///
  /// In en, this message translates to:
  /// **'2 scrambled eggs with cheddar cheese and bacon slice'**
  String get foodAiExample;

  /// No description provided for @foodAiExtracted.
  ///
  /// In en, this message translates to:
  /// **'AI Extracted Facts'**
  String get foodAiExtracted;

  /// No description provided for @foodAiPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'What did you eat? Describe ingredients...'**
  String get foodAiPlaceholder;

  /// No description provided for @foodAiTitle.
  ///
  /// In en, this message translates to:
  /// **'Gemini AI Smart Assistant'**
  String get foodAiTitle;

  /// No description provided for @foodCaloriesKcal.
  ///
  /// In en, this message translates to:
  /// **'Calories (kcal)'**
  String get foodCaloriesKcal;

  /// No description provided for @foodCarbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get foodCarbs;

  /// No description provided for @foodCarbsG.
  ///
  /// In en, this message translates to:
  /// **'Carbohydrates (g)'**
  String get foodCarbsG;

  /// No description provided for @foodDbLookup.
  ///
  /// In en, this message translates to:
  /// **'Database Lookup'**
  String get foodDbLookup;

  /// No description provided for @foodDbSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Food Database Search'**
  String get foodDbSearchTitle;

  /// No description provided for @foodDeleteEntry.
  ///
  /// In en, this message translates to:
  /// **'Delete Entry'**
  String get foodDeleteEntry;

  /// No description provided for @foodDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get foodDiscard;

  /// No description provided for @foodFat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get foodFat;

  /// No description provided for @foodFatsG.
  ///
  /// In en, this message translates to:
  /// **'Fats (g)'**
  String get foodFatsG;

  /// No description provided for @foodFoodName.
  ///
  /// In en, this message translates to:
  /// **'Food Name *'**
  String get foodFoodName;

  /// No description provided for @foodHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Logged Meal History'**
  String get foodHistoryTitle;

  /// No description provided for @foodItemsLoaded.
  ///
  /// In en, this message translates to:
  /// **'{n} Items Loaded'**
  String foodItemsLoaded(String n);

  /// No description provided for @foodKcal.
  ///
  /// In en, this message translates to:
  /// **'Kcal'**
  String get foodKcal;

  /// No description provided for @foodLogAiMeal.
  ///
  /// In en, this message translates to:
  /// **'Log AI Meal'**
  String get foodLogAiMeal;

  /// No description provided for @foodLogCustomFood.
  ///
  /// In en, this message translates to:
  /// **'Log Custom Food'**
  String get foodLogCustomFood;

  /// No description provided for @foodLogNamed.
  ///
  /// In en, this message translates to:
  /// **'Log {name}'**
  String foodLogNamed(String name);

  /// No description provided for @foodManualAiLog.
  ///
  /// In en, this message translates to:
  /// **'Manual & AI Log'**
  String get foodManualAiLog;

  /// No description provided for @foodManualTitle.
  ///
  /// In en, this message translates to:
  /// **'Manual Custom Entry'**
  String get foodManualTitle;

  /// No description provided for @foodNoLogs.
  ///
  /// In en, this message translates to:
  /// **'No food logs completed for {date}.'**
  String foodNoLogs(String date);

  /// No description provided for @foodNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No matching foods found in standard database. Switch to AI log!'**
  String get foodNoMatch;

  /// No description provided for @foodNoOnlineMatches.
  ///
  /// In en, this message translates to:
  /// **'No online matches'**
  String get foodNoOnlineMatches;

  /// No description provided for @foodOnlineResults.
  ///
  /// In en, this message translates to:
  /// **'Online results'**
  String get foodOnlineResults;

  /// No description provided for @foodPhCalories.
  ///
  /// In en, this message translates to:
  /// **'e.g. 150'**
  String get foodPhCalories;

  /// No description provided for @foodPhCarbs.
  ///
  /// In en, this message translates to:
  /// **'e.g. 15'**
  String get foodPhCarbs;

  /// No description provided for @foodPhFat.
  ///
  /// In en, this message translates to:
  /// **'e.g. 2'**
  String get foodPhFat;

  /// No description provided for @foodPhName.
  ///
  /// In en, this message translates to:
  /// **'e.g. Vanilla Yogurt Cup'**
  String get foodPhName;

  /// No description provided for @foodPhProtein.
  ///
  /// In en, this message translates to:
  /// **'e.g. 8'**
  String get foodPhProtein;

  /// No description provided for @foodPhServing.
  ///
  /// In en, this message translates to:
  /// **'e.g. 150'**
  String get foodPhServing;

  /// No description provided for @foodPortion.
  ///
  /// In en, this message translates to:
  /// **'Portion:'**
  String get foodPortion;

  /// No description provided for @foodPortionSize.
  ///
  /// In en, this message translates to:
  /// **'Portion size:'**
  String get foodPortionSize;

  /// No description provided for @foodProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get foodProtein;

  /// No description provided for @foodProteinG.
  ///
  /// In en, this message translates to:
  /// **'Protein (g)'**
  String get foodProteinG;

  /// No description provided for @foodRecentEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing logged yet — your meals will appear here.'**
  String get foodRecentEmpty;

  /// No description provided for @foodRecentTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent meals'**
  String get foodRecentTitle;

  /// No description provided for @foodSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search oatmeal, eggs, avocado...'**
  String get foodSearchPlaceholder;

  /// No description provided for @foodServing.
  ///
  /// In en, this message translates to:
  /// **'Serving:'**
  String get foodServing;

  /// No description provided for @foodServingSize.
  ///
  /// In en, this message translates to:
  /// **'Serving Size'**
  String get foodServingSize;

  /// No description provided for @foodTodayLower.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get foodTodayLower;

  /// No description provided for @foodTotal.
  ///
  /// In en, this message translates to:
  /// **'Total:'**
  String get foodTotal;

  /// No description provided for @foodUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get foodUnit;

  /// No description provided for @foodYesterdayLower.
  ///
  /// In en, this message translates to:
  /// **'yesterday'**
  String get foodYesterdayLower;

  /// No description provided for @footerContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get footerContact;

  /// No description provided for @footerDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get footerDeleteAccount;

  /// No description provided for @footerEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get footerEditProfile;

  /// No description provided for @footerPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get footerPrivacy;

  /// No description provided for @footerRate.
  ///
  /// In en, this message translates to:
  /// **'Rate on Play'**
  String get footerRate;

  /// No description provided for @footerResetData.
  ///
  /// In en, this message translates to:
  /// **'Reset Data'**
  String get footerResetData;

  /// No description provided for @footerTagline.
  ///
  /// In en, this message translates to:
  /// **'NutriFlow · AI diet, hydration & exercise tracker · © 2026'**
  String get footerTagline;

  /// No description provided for @footerVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String footerVersion(String version);

  /// No description provided for @headerAiConnected.
  ///
  /// In en, this message translates to:
  /// **'AI Engines Connected'**
  String get headerAiConnected;

  /// No description provided for @headerDarkLabel.
  ///
  /// In en, this message translates to:
  /// **'Deep Midnight'**
  String get headerDarkLabel;

  /// No description provided for @headerLightLabel.
  ///
  /// In en, this message translates to:
  /// **'High Contrast Light'**
  String get headerLightLabel;

  /// No description provided for @headerLoggedDate.
  ///
  /// In en, this message translates to:
  /// **'Logged date:'**
  String get headerLoggedDate;

  /// No description provided for @headerSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get headerSignOut;

  /// No description provided for @headerSyncOn.
  ///
  /// In en, this message translates to:
  /// **'Sync On'**
  String get headerSyncOn;

  /// No description provided for @headerTagline.
  ///
  /// In en, this message translates to:
  /// **'Professional Diet, Hydration, and Active Workout Workspace'**
  String get headerTagline;

  /// No description provided for @headerThemeToDark.
  ///
  /// In en, this message translates to:
  /// **'Switch to Deep Midnight Theme'**
  String get headerThemeToDark;

  /// No description provided for @headerThemeToLight.
  ///
  /// In en, this message translates to:
  /// **'Switch to High Contrast Light Theme'**
  String get headerThemeToLight;

  /// No description provided for @langLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get langLabel;

  /// No description provided for @modalsDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes {who} and all your data — meals, exercises, goals, and hydration. This action cannot be undone.'**
  String modalsDeleteBody(String who);

  /// No description provided for @modalsDeleteBtn.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get modalsDeleteBtn;

  /// No description provided for @modalsDeleteConfirmPost.
  ///
  /// In en, this message translates to:
  /// **'to confirm'**
  String get modalsDeleteConfirmPost;

  /// No description provided for @modalsDeleteConfirmPre.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get modalsDeleteConfirmPre;

  /// No description provided for @modalsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get modalsDeleteTitle;

  /// No description provided for @modalsDeleteYourAccount.
  ///
  /// In en, this message translates to:
  /// **'your account'**
  String get modalsDeleteYourAccount;

  /// No description provided for @modalsDeleting.
  ///
  /// In en, this message translates to:
  /// **'Deleting…'**
  String get modalsDeleting;

  /// No description provided for @modalsResetBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes all your logged meals, exercises, and hydration across every day. Your account, profile, and calorie/macro goal are kept. This can’t be undone.'**
  String get modalsResetBody;

  /// No description provided for @modalsResetBtn.
  ///
  /// In en, this message translates to:
  /// **'Reset data'**
  String get modalsResetBtn;

  /// No description provided for @modalsResetDone.
  ///
  /// In en, this message translates to:
  /// **'Data reset'**
  String get modalsResetDone;

  /// No description provided for @modalsResetDoneNote.
  ///
  /// In en, this message translates to:
  /// **'Your logs are cleared — fresh start!'**
  String get modalsResetDoneNote;

  /// No description provided for @modalsResetting.
  ///
  /// In en, this message translates to:
  /// **'Resetting…'**
  String get modalsResetting;

  /// No description provided for @modalsResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset logged data'**
  String get modalsResetTitle;

  /// No description provided for @navActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get navActive;

  /// No description provided for @navCoach.
  ///
  /// In en, this message translates to:
  /// **'AI Coach'**
  String get navCoach;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navMeals.
  ///
  /// In en, this message translates to:
  /// **'Meals'**
  String get navMeals;

  /// No description provided for @navScan.
  ///
  /// In en, this message translates to:
  /// **'UPC Scan'**
  String get navScan;

  /// No description provided for @navTrends.
  ///
  /// In en, this message translates to:
  /// **'Trends'**
  String get navTrends;

  /// No description provided for @onboardingActivitiesExtraHint.
  ///
  /// In en, this message translates to:
  /// **'Physical job / 2× a day'**
  String get onboardingActivitiesExtraHint;

  /// No description provided for @onboardingActivitiesExtraLabel.
  ///
  /// In en, this message translates to:
  /// **'Extra active'**
  String get onboardingActivitiesExtraLabel;

  /// No description provided for @onboardingActivitiesLightHint.
  ///
  /// In en, this message translates to:
  /// **'1–3 days/week'**
  String get onboardingActivitiesLightHint;

  /// No description provided for @onboardingActivitiesLightLabel.
  ///
  /// In en, this message translates to:
  /// **'Lightly active'**
  String get onboardingActivitiesLightLabel;

  /// No description provided for @onboardingActivitiesModerateHint.
  ///
  /// In en, this message translates to:
  /// **'3–5 days/week'**
  String get onboardingActivitiesModerateHint;

  /// No description provided for @onboardingActivitiesModerateLabel.
  ///
  /// In en, this message translates to:
  /// **'Moderately active'**
  String get onboardingActivitiesModerateLabel;

  /// No description provided for @onboardingActivitiesSedentaryHint.
  ///
  /// In en, this message translates to:
  /// **'Little or no exercise'**
  String get onboardingActivitiesSedentaryHint;

  /// No description provided for @onboardingActivitiesSedentaryLabel.
  ///
  /// In en, this message translates to:
  /// **'Sedentary'**
  String get onboardingActivitiesSedentaryLabel;

  /// No description provided for @onboardingActivitiesVeryHint.
  ///
  /// In en, this message translates to:
  /// **'6–7 days/week'**
  String get onboardingActivitiesVeryHint;

  /// No description provided for @onboardingActivitiesVeryLabel.
  ///
  /// In en, this message translates to:
  /// **'Very active'**
  String get onboardingActivitiesVeryLabel;

  /// No description provided for @onboardingAgeLabel.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get onboardingAgeLabel;

  /// No description provided for @onboardingAgePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. 28'**
  String get onboardingAgePlaceholder;

  /// No description provided for @onboardingBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get onboardingBack;

  /// No description provided for @onboardingCarbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get onboardingCarbs;

  /// No description provided for @onboardingContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingContinue;

  /// No description provided for @onboardingCurrentWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Current weight'**
  String get onboardingCurrentWeightLabel;

  /// No description provided for @onboardingDailyCalories.
  ///
  /// In en, this message translates to:
  /// **'Daily calories'**
  String get onboardingDailyCalories;

  /// No description provided for @onboardingDietsHighProtein.
  ///
  /// In en, this message translates to:
  /// **'High protein'**
  String get onboardingDietsHighProtein;

  /// No description provided for @onboardingDietsKeto.
  ///
  /// In en, this message translates to:
  /// **'Keto'**
  String get onboardingDietsKeto;

  /// No description provided for @onboardingDietsLowCarb.
  ///
  /// In en, this message translates to:
  /// **'Low carb'**
  String get onboardingDietsLowCarb;

  /// No description provided for @onboardingDietsMediterranean.
  ///
  /// In en, this message translates to:
  /// **'Mediterranean'**
  String get onboardingDietsMediterranean;

  /// No description provided for @onboardingDietsNone.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get onboardingDietsNone;

  /// No description provided for @onboardingDietsPaleo.
  ///
  /// In en, this message translates to:
  /// **'Paleo'**
  String get onboardingDietsPaleo;

  /// No description provided for @onboardingDietsVegan.
  ///
  /// In en, this message translates to:
  /// **'Vegan'**
  String get onboardingDietsVegan;

  /// No description provided for @onboardingDietsVegetarian.
  ///
  /// In en, this message translates to:
  /// **'Vegetarian'**
  String get onboardingDietsVegetarian;

  /// No description provided for @onboardingEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit your profile'**
  String get onboardingEditTitle;

  /// No description provided for @onboardingFat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get onboardingFat;

  /// No description provided for @onboardingGoalsBuildMuscleHint.
  ///
  /// In en, this message translates to:
  /// **'Lean bulk, high protein'**
  String get onboardingGoalsBuildMuscleHint;

  /// No description provided for @onboardingGoalsBuildMuscleLabel.
  ///
  /// In en, this message translates to:
  /// **'Build muscle'**
  String get onboardingGoalsBuildMuscleLabel;

  /// No description provided for @onboardingGoalsGainHint.
  ///
  /// In en, this message translates to:
  /// **'Calorie surplus'**
  String get onboardingGoalsGainHint;

  /// No description provided for @onboardingGoalsGainLabel.
  ///
  /// In en, this message translates to:
  /// **'Gain weight'**
  String get onboardingGoalsGainLabel;

  /// No description provided for @onboardingGoalsLoseHint.
  ///
  /// In en, this message translates to:
  /// **'Calorie deficit'**
  String get onboardingGoalsLoseHint;

  /// No description provided for @onboardingGoalsLoseLabel.
  ///
  /// In en, this message translates to:
  /// **'Lose weight'**
  String get onboardingGoalsLoseLabel;

  /// No description provided for @onboardingGoalsMaintainHint.
  ///
  /// In en, this message translates to:
  /// **'Stay where I am'**
  String get onboardingGoalsMaintainHint;

  /// No description provided for @onboardingGoalsMaintainLabel.
  ///
  /// In en, this message translates to:
  /// **'Maintain'**
  String get onboardingGoalsMaintainLabel;

  /// No description provided for @onboardingHeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get onboardingHeightLabel;

  /// No description provided for @onboardingImperial.
  ///
  /// In en, this message translates to:
  /// **'Imperial (lb/ft)'**
  String get onboardingImperial;

  /// No description provided for @onboardingMetric.
  ///
  /// In en, this message translates to:
  /// **'Metric (kg/cm)'**
  String get onboardingMetric;

  /// No description provided for @onboardingOptional.
  ///
  /// In en, this message translates to:
  /// **'(optional)'**
  String get onboardingOptional;

  /// No description provided for @onboardingPersonalizeTitle.
  ///
  /// In en, this message translates to:
  /// **'Let’s personalize NutriFlow'**
  String get onboardingPersonalizeTitle;

  /// No description provided for @onboardingPromoSecondary.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get onboardingPromoSecondary;

  /// No description provided for @onboardingPromoSubmit.
  ///
  /// In en, this message translates to:
  /// **'Create account to save'**
  String get onboardingPromoSubmit;

  /// No description provided for @onboardingPromoTitle.
  ///
  /// In en, this message translates to:
  /// **'Build your free nutrition plan'**
  String get onboardingPromoTitle;

  /// No description provided for @onboardingProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get onboardingProtein;

  /// No description provided for @onboardingRestrictionsDairy.
  ///
  /// In en, this message translates to:
  /// **'Dairy'**
  String get onboardingRestrictionsDairy;

  /// No description provided for @onboardingRestrictionsEggs.
  ///
  /// In en, this message translates to:
  /// **'Eggs'**
  String get onboardingRestrictionsEggs;

  /// No description provided for @onboardingRestrictionsGluten.
  ///
  /// In en, this message translates to:
  /// **'Gluten'**
  String get onboardingRestrictionsGluten;

  /// No description provided for @onboardingRestrictionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Any restrictions / allergies?'**
  String get onboardingRestrictionsLabel;

  /// No description provided for @onboardingRestrictionsNuts.
  ///
  /// In en, this message translates to:
  /// **'Nuts'**
  String get onboardingRestrictionsNuts;

  /// No description provided for @onboardingRestrictionsPork.
  ///
  /// In en, this message translates to:
  /// **'Pork'**
  String get onboardingRestrictionsPork;

  /// No description provided for @onboardingRestrictionsShellfish.
  ///
  /// In en, this message translates to:
  /// **'Shellfish'**
  String get onboardingRestrictionsShellfish;

  /// No description provided for @onboardingRestrictionsSoy.
  ///
  /// In en, this message translates to:
  /// **'Soy'**
  String get onboardingRestrictionsSoy;

  /// No description provided for @onboardingReviewNote.
  ///
  /// In en, this message translates to:
  /// **'Calculated from your details (Mifflin–St Jeor). You can fine-tune these anytime from the dashboard.'**
  String get onboardingReviewNote;

  /// No description provided for @onboardingSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get onboardingSaveChanges;

  /// No description provided for @onboardingSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get onboardingSaving;

  /// No description provided for @onboardingSexesFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get onboardingSexesFemale;

  /// No description provided for @onboardingSexesMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get onboardingSexesMale;

  /// No description provided for @onboardingSexesOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get onboardingSexesOther;

  /// No description provided for @onboardingSexLabel.
  ///
  /// In en, this message translates to:
  /// **'Sex (for calorie estimate)'**
  String get onboardingSexLabel;

  /// No description provided for @onboardingSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get onboardingSignOut;

  /// No description provided for @onboardingStartTracking.
  ///
  /// In en, this message translates to:
  /// **'Start tracking'**
  String get onboardingStartTracking;

  /// No description provided for @onboardingStep0Title.
  ///
  /// In en, this message translates to:
  /// **'What’s your main goal?'**
  String get onboardingStep0Title;

  /// No description provided for @onboardingStep1Title.
  ///
  /// In en, this message translates to:
  /// **'A bit about you'**
  String get onboardingStep1Title;

  /// No description provided for @onboardingStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Your measurements'**
  String get onboardingStep2Title;

  /// No description provided for @onboardingStep3Title.
  ///
  /// In en, this message translates to:
  /// **'How active are you?'**
  String get onboardingStep3Title;

  /// No description provided for @onboardingStep4Title.
  ///
  /// In en, this message translates to:
  /// **'Dietary preference'**
  String get onboardingStep4Title;

  /// No description provided for @onboardingStep5Title.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get onboardingStep5Title;

  /// No description provided for @onboardingStep6Title.
  ///
  /// In en, this message translates to:
  /// **'Your personalized daily targets'**
  String get onboardingStep6Title;

  /// No description provided for @onboardingStepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String onboardingStepOf(String current, String total);

  /// No description provided for @onboardingStepsAbout.
  ///
  /// In en, this message translates to:
  /// **'About you'**
  String get onboardingStepsAbout;

  /// No description provided for @onboardingStepsActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get onboardingStepsActivity;

  /// No description provided for @onboardingStepsBody.
  ///
  /// In en, this message translates to:
  /// **'Body'**
  String get onboardingStepsBody;

  /// No description provided for @onboardingStepsDiet.
  ///
  /// In en, this message translates to:
  /// **'Diet'**
  String get onboardingStepsDiet;

  /// No description provided for @onboardingStepsGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get onboardingStepsGoal;

  /// No description provided for @onboardingStepsPrefs.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get onboardingStepsPrefs;

  /// No description provided for @onboardingStepsReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get onboardingStepsReview;

  /// No description provided for @onboardingTargetWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Target weight'**
  String get onboardingTargetWeightLabel;

  /// No description provided for @onboardingWorkoutsCardio.
  ///
  /// In en, this message translates to:
  /// **'Cardio'**
  String get onboardingWorkoutsCardio;

  /// No description provided for @onboardingWorkoutsCycling.
  ///
  /// In en, this message translates to:
  /// **'Cycling'**
  String get onboardingWorkoutsCycling;

  /// No description provided for @onboardingWorkoutsHIIT.
  ///
  /// In en, this message translates to:
  /// **'HIIT'**
  String get onboardingWorkoutsHIIT;

  /// No description provided for @onboardingWorkoutsLabel.
  ///
  /// In en, this message translates to:
  /// **'Workouts you enjoy'**
  String get onboardingWorkoutsLabel;

  /// No description provided for @onboardingWorkoutsRunning.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get onboardingWorkoutsRunning;

  /// No description provided for @onboardingWorkoutsStrength.
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get onboardingWorkoutsStrength;

  /// No description provided for @onboardingWorkoutsSwimming.
  ///
  /// In en, this message translates to:
  /// **'Swimming'**
  String get onboardingWorkoutsSwimming;

  /// No description provided for @onboardingWorkoutsWalking.
  ///
  /// In en, this message translates to:
  /// **'Walking'**
  String get onboardingWorkoutsWalking;

  /// No description provided for @onboardingWorkoutsYoga.
  ///
  /// In en, this message translates to:
  /// **'Yoga'**
  String get onboardingWorkoutsYoga;

  /// No description provided for @passwordConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get passwordConfirmLabel;

  /// No description provided for @passwordConfirmPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Re-enter password'**
  String get passwordConfirmPlaceholder;

  /// No description provided for @passwordErrGeneric.
  ///
  /// In en, this message translates to:
  /// **'Could not update your password. Please try again.'**
  String get passwordErrGeneric;

  /// No description provided for @passwordErrMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get passwordErrMinLength;

  /// No description provided for @passwordErrMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match.'**
  String get passwordErrMismatch;

  /// No description provided for @passwordHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get passwordHidePassword;

  /// No description provided for @passwordNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get passwordNewPassword;

  /// No description provided for @passwordNewPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get passwordNewPlaceholder;

  /// No description provided for @passwordShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get passwordShowPassword;

  /// No description provided for @passwordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a new password'**
  String get passwordSubtitle;

  /// No description provided for @passwordUpdateBtn.
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get passwordUpdateBtn;

  /// No description provided for @passwordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated'**
  String get passwordUpdated;

  /// No description provided for @passwordUpdatedNote.
  ///
  /// In en, this message translates to:
  /// **'You\'re all set — loading your dashboard…'**
  String get passwordUpdatedNote;

  /// No description provided for @passwordUpdating.
  ///
  /// In en, this message translates to:
  /// **'Updating…'**
  String get passwordUpdating;

  /// No description provided for @photoAiEstimate.
  ///
  /// In en, this message translates to:
  /// **'AI Estimate'**
  String get photoAiEstimate;

  /// No description provided for @photoAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing your meal…'**
  String get photoAnalyzing;

  /// No description provided for @photoCalories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get photoCalories;

  /// No description provided for @photoCapture.
  ///
  /// In en, this message translates to:
  /// **'Capture'**
  String get photoCapture;

  /// No description provided for @photoCarbsG.
  ///
  /// In en, this message translates to:
  /// **'Carbs g'**
  String get photoCarbsG;

  /// No description provided for @photoCloseCamera.
  ///
  /// In en, this message translates to:
  /// **'Close camera'**
  String get photoCloseCamera;

  /// No description provided for @photoDesc.
  ///
  /// In en, this message translates to:
  /// **'Take or upload a food photo — AI estimates the calories and macros, then you review and log it.'**
  String get photoDesc;

  /// No description provided for @photoErrAnalysisDefault.
  ///
  /// In en, this message translates to:
  /// **'Analysis failed. Please try again.'**
  String get photoErrAnalysisDefault;

  /// No description provided for @photoErrAnalyze.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t analyze that photo. Please try again.'**
  String get photoErrAnalyze;

  /// No description provided for @photoErrCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera permission was denied or is unavailable. Use Upload instead.'**
  String get photoErrCamera;

  /// No description provided for @photoErrCapture.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t capture the photo. Try again.'**
  String get photoErrCapture;

  /// No description provided for @photoErrRead.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t read that image. Please try another.'**
  String get photoErrRead;

  /// No description provided for @photoFatG.
  ///
  /// In en, this message translates to:
  /// **'Fat g'**
  String get photoFatG;

  /// No description provided for @photoIdleDesc.
  ///
  /// In en, this message translates to:
  /// **'Use your camera to photograph your plate, or pick an existing photo from your gallery.'**
  String get photoIdleDesc;

  /// No description provided for @photoIdleTitle.
  ///
  /// In en, this message translates to:
  /// **'Snap or upload a meal'**
  String get photoIdleTitle;

  /// No description provided for @photoLoggedDiary.
  ///
  /// In en, this message translates to:
  /// **'Logged to your diary!'**
  String get photoLoggedDiary;

  /// No description provided for @photoLogMeal.
  ///
  /// In en, this message translates to:
  /// **'Log meal'**
  String get photoLogMeal;

  /// No description provided for @photoMealNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Meal name'**
  String get photoMealNamePlaceholder;

  /// No description provided for @photoNoFood.
  ///
  /// In en, this message translates to:
  /// **'No food detected. Try a clearer, closer shot of your plate.'**
  String get photoNoFood;

  /// No description provided for @photoPreviewAlt.
  ///
  /// In en, this message translates to:
  /// **'Meal preview'**
  String get photoPreviewAlt;

  /// No description provided for @photoProteinG.
  ///
  /// In en, this message translates to:
  /// **'Protein g'**
  String get photoProteinG;

  /// No description provided for @photoRemovePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get photoRemovePhoto;

  /// No description provided for @photoRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get photoRetry;

  /// No description provided for @photoReviewAdjust.
  ///
  /// In en, this message translates to:
  /// **'Review & adjust before logging'**
  String get photoReviewAdjust;

  /// No description provided for @photoTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get photoTakePhoto;

  /// No description provided for @photoTitle.
  ///
  /// In en, this message translates to:
  /// **'Snap a Meal'**
  String get photoTitle;

  /// No description provided for @photoTryAnother.
  ///
  /// In en, this message translates to:
  /// **'Try another'**
  String get photoTryAnother;

  /// No description provided for @photoUpload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get photoUpload;

  /// No description provided for @scannerCarbs.
  ///
  /// In en, this message translates to:
  /// **'Carbohydrates'**
  String get scannerCarbs;

  /// No description provided for @scannerClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get scannerClear;

  /// No description provided for @scannerDescManual.
  ///
  /// In en, this message translates to:
  /// **'Enter a product\'s UPC/EAN barcode to look it up in Open Food Facts. Unknown codes fall back to an AI estimate.'**
  String get scannerDescManual;

  /// No description provided for @scannerDescSupported.
  ///
  /// In en, this message translates to:
  /// **'Scan a product barcode with your camera, or enter it manually. Looked up in Open Food Facts — unknown codes fall back to an AI estimate.'**
  String get scannerDescSupported;

  /// No description provided for @scannerErrCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera permission was denied or is unavailable. You can still enter the barcode number manually below.'**
  String get scannerErrCamera;

  /// No description provided for @scannerErrLookup.
  ///
  /// In en, this message translates to:
  /// **'Barcode analysis failed. Try a pre-registered code or check environment.'**
  String get scannerErrLookup;

  /// No description provided for @scannerFats.
  ///
  /// In en, this message translates to:
  /// **'Fats'**
  String get scannerFats;

  /// No description provided for @scannerLiveViewport.
  ///
  /// In en, this message translates to:
  /// **'Live Viewport'**
  String get scannerLiveViewport;

  /// No description provided for @scannerLogToLog.
  ///
  /// In en, this message translates to:
  /// **'Log to Meal Log'**
  String get scannerLogToLog;

  /// No description provided for @scannerLookup.
  ///
  /// In en, this message translates to:
  /// **'Look up'**
  String get scannerLookup;

  /// No description provided for @scannerManualDesc.
  ///
  /// In en, this message translates to:
  /// **'Live scanning isn\'t available on this browser. You can still type the barcode number below.'**
  String get scannerManualDesc;

  /// No description provided for @scannerManualLabel.
  ///
  /// In en, this message translates to:
  /// **'Or enter the barcode manually'**
  String get scannerManualLabel;

  /// No description provided for @scannerManualTitle.
  ///
  /// In en, this message translates to:
  /// **'Manual Entry Recommended'**
  String get scannerManualTitle;

  /// No description provided for @scannerMatchScanned.
  ///
  /// In en, this message translates to:
  /// **'Match Scanned!'**
  String get scannerMatchScanned;

  /// No description provided for @scannerPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter numeric UPC/EAN code...'**
  String get scannerPlaceholder;

  /// No description provided for @scannerProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get scannerProtein;

  /// No description provided for @scannerReadyDesc.
  ///
  /// In en, this message translates to:
  /// **'Point your camera at a product barcode — it scans and looks it up automatically.'**
  String get scannerReadyDesc;

  /// No description provided for @scannerReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera Scanner Ready'**
  String get scannerReadyTitle;

  /// No description provided for @scannerServingQty.
  ///
  /// In en, this message translates to:
  /// **'Serving Quantity: {size} {unit}'**
  String scannerServingQty(String size, String unit);

  /// No description provided for @scannerStatusPoint.
  ///
  /// In en, this message translates to:
  /// **'Point the camera at a barcode — it scans automatically.'**
  String get scannerStatusPoint;

  /// No description provided for @scannerStatusStarting.
  ///
  /// In en, this message translates to:
  /// **'Starting camera view...'**
  String get scannerStatusStarting;

  /// No description provided for @scannerStatusUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Live scanning isn\'t supported on this browser — enter the code manually below.'**
  String get scannerStatusUnsupported;

  /// No description provided for @scannerStopCamera.
  ///
  /// In en, this message translates to:
  /// **'Stop Camera Feed'**
  String get scannerStopCamera;

  /// No description provided for @scannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Barcode Scanner'**
  String get scannerTitle;

  /// No description provided for @scannerUseCamera.
  ///
  /// In en, this message translates to:
  /// **'Use Device Camera'**
  String get scannerUseCamera;

  /// No description provided for @waterCup.
  ///
  /// In en, this message translates to:
  /// **'Cup'**
  String get waterCup;

  /// No description provided for @waterGlass.
  ///
  /// In en, this message translates to:
  /// **'Glass'**
  String get waterGlass;

  /// No description provided for @waterHydrated.
  ///
  /// In en, this message translates to:
  /// **'Hydrated'**
  String get waterHydrated;

  /// No description provided for @waterPerfect.
  ///
  /// In en, this message translates to:
  /// **'Perfect hydration! Goal exceeded today.'**
  String get waterPerfect;

  /// No description provided for @waterReduce.
  ///
  /// In en, this message translates to:
  /// **'Reduce'**
  String get waterReduce;

  /// No description provided for @waterReduceTitle.
  ///
  /// In en, this message translates to:
  /// **'Reduce water log'**
  String get waterReduceTitle;

  /// No description provided for @waterRemaining.
  ///
  /// In en, this message translates to:
  /// **'{ml} ml remaining to meet daily baseline.'**
  String waterRemaining(String ml);

  /// No description provided for @waterTarget.
  ///
  /// In en, this message translates to:
  /// **'Target: 2.5L'**
  String get waterTarget;

  /// No description provided for @waterTitle.
  ///
  /// In en, this message translates to:
  /// **'Hydration Tracker'**
  String get waterTitle;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['bs', 'en', 'hr', 'sr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bs':
      return AppLocalizationsBs();
    case 'en':
      return AppLocalizationsEn();
    case 'hr':
      return AppLocalizationsHr();
    case 'sr':
      return AppLocalizationsSr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
