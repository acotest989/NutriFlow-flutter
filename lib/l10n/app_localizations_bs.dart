// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bosnian (`bs`).
class AppLocalizationsBs extends AppLocalizations {
  AppLocalizationsBs([String locale = 'bs']) : super(locale);

  @override
  String get appLoadFailedTitle => 'Učitavanje podataka nije uspjelo';

  @override
  String get appLoadingWorkspace => 'Učitavam tvoj radni prostor…';

  @override
  String get appRetry => 'Pokušaj ponovo';

  @override
  String get appSyncing => 'Sinhronizujem podatke…';

  @override
  String get authBackToSignin => 'Nazad na prijavu';

  @override
  String get authBuildPlan => 'Prvi put ovdje? Napravi besplatan plan';

  @override
  String get authContinueGoogle => 'Nastavi sa Google-om';

  @override
  String get authCreateAccount => 'Kreiraj račun';

  @override
  String get authEmail => 'Email';

  @override
  String get authEmailPlaceholder => 'ti@primjer.com';

  @override
  String get authErrGeneric => 'Nešto je pošlo po zlu. Pokušaj ponovo.';

  @override
  String get authForgot => 'Zaboravljena lozinka?';

  @override
  String get authHaveAccount => 'Već imaš račun?';

  @override
  String get authHidePassword => 'Sakrij lozinku';

  @override
  String get authInfoConfirm => 'Račun je kreiran! Provjeri email za potvrdu, zatim se prijavi.';

  @override
  String get authInfoReset => 'Ako račun za taj email postoji, link za resetiranje lozinke stiže. Provjeri sanduče.';

  @override
  String get authNoAccount => 'Nemaš račun?';

  @override
  String get authOr => 'ili';

  @override
  String get authPassword => 'Lozinka';

  @override
  String get authPasswordPlaceholder => 'Tvoja lozinka';

  @override
  String get authPasswordPlaceholderSignup => 'Najmanje 6 znakova';

  @override
  String get authPleaseWait => 'Sačekaj...';

  @override
  String get authPrivacyNote => 'Tvoji podaci su privatni i zaštićeni po računu sigurnošću na nivou reda.';

  @override
  String get authPromoSaved => 'Plan je spreman — napravi račun da ga sačuvaš.';

  @override
  String get authSendReset => 'Pošalji link za reset';

  @override
  String get authShowPassword => 'Prikaži lozinku';

  @override
  String get authSignIn => 'Prijavi se';

  @override
  String get authSignInLink => 'Prijavi se';

  @override
  String get authSignUp => 'Registruj se';

  @override
  String get authSubtitleReset => 'Unesi svoj email za resetiranje lozinke.';

  @override
  String get authSubtitleSignin => 'Dobro došao nazad. Prijavi se za nastavak.';

  @override
  String get authSubtitleSignup => 'Kreiraj svoj račun za početak.';

  @override
  String get chartsAchievements => 'Postignuća';

  @override
  String get chartsAchievementsExplainer =>
      'Unesi obrok, trening ili vodu bilo kojeg dana da održiš niz — propustiš li cijeli dan, resetuje se. Budi dosljedan da otključaš ova postignuća:';

  @override
  String get chartsActiveBurn => 'Sagorijevanje';

  @override
  String get chartsBadgesCenturyDesc => 'Unesi ukupno 100 stavki';

  @override
  String get chartsBadgesCenturyLabel => 'Stotinar';

  @override
  String get chartsBadgesHydratedDesc => 'Unesi vodu 7 dana';

  @override
  String get chartsBadgesHydratedLabel => 'Hidriran';

  @override
  String get chartsBadgesStartDesc => 'Unesi svoju prvu stavku';

  @override
  String get chartsBadgesStartLabel => 'Prvi korak';

  @override
  String get chartsBadgesStreak14Desc => 'Dostigni niz od 14 dana';

  @override
  String get chartsBadgesStreak14Label => 'Predan';

  @override
  String get chartsBadgesStreak30Desc => 'Dostigni niz od 30 dana';

  @override
  String get chartsBadgesStreak30Label => 'Nezaustavljiv';

  @override
  String get chartsBadgesStreak3Desc => 'Dostigni niz od 3 dana';

  @override
  String get chartsBadgesStreak3Label => 'Dosljedan';

  @override
  String get chartsBadgesStreak7Desc => 'Dostigni niz od 7 dana';

  @override
  String get chartsBadgesStreak7Label => 'Zahuktao se';

  @override
  String get chartsCarbs => 'Ugljikohidrati';

  @override
  String chartsDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dana',
      few: '$count dana',
      one: '$count dan',
    );
    return '$_temp0';
  }

  @override
  String get chartsDefaultTemplate =>
      'Prikazan je zadani uravnoteženi predložak. Unesi namirnice da vidiš stvarne omjere!';

  @override
  String get chartsEnergyDesc =>
      'Pregled dnevnog doprinosa energiji (postotak kcal) iz unesenih proteina, ugljikohidrata i masti.';

  @override
  String get chartsEnergyTitle => 'Današnja raspodjela energije';

  @override
  String get chartsFat => 'Masti';

  @override
  String get chartsFoodIngested => 'Unesena hrana';

  @override
  String get chartsGoal => 'Cilj';

  @override
  String get chartsNetCalories => 'Neto kalorije';

  @override
  String chartsOfCalories(String value) {
    return '$value% kalorija';
  }

  @override
  String get chartsProtein => 'Proteini';

  @override
  String get chartsStartStreak => 'Započni niz';

  @override
  String chartsStreakAlive(String longest) {
    return 'Tvoj niz je živ — unesi bilo šta danas da ga produžiš. Najduži: $longest.';
  }

  @override
  String get chartsStreakStart => 'Unesi obrok, trening ili vodu danas da započneš svoj niz!';

  @override
  String chartsStreakTitle(String n, String days) {
    return 'Niz od $days';
  }

  @override
  String chartsStreakToday(String longest) {
    return 'Odličan rad danas! Samo nastavi — najduži niz: $longest.';
  }

  @override
  String get chartsTotalLogged => 'Ukupno uneseno';

  @override
  String get chartsTrendDesc =>
      'Uspoređuje ukupno unesene kalorije sa sagorjelim kalorijama treninga u odnosu na dnevni budžet.';

  @override
  String get chartsTrendTitle => '7-dnevni bilans';

  @override
  String get coachAnalyzing => 'Analiza u toku...';

  @override
  String get coachCalories => 'Kalorije';

  @override
  String get coachCarbs => 'Ugljikohidrati';

  @override
  String get coachChefTab => 'AI recepti';

  @override
  String get coachCoachRating => 'Ocjena trenera';

  @override
  String get coachCookingRecipes => 'Pripremam recepte...';

  @override
  String get coachDailyCoachTab => 'AI dnevni trener';

  @override
  String get coachDietitianSummary => 'Sažetak nutricioniste';

  @override
  String get coachErrCoach => 'Neuspješno dobivanje odgovora od AI trenera.';

  @override
  String get coachErrGeneric => 'Nešto je pošlo po zlu. Provjeri internet vezu.';

  @override
  String get coachErrRecipes => 'Neuspješno pravljenje AI recepata.';

  @override
  String get coachErrRecipesGeneric => 'Neuspješno generisanje recepata. Pokušaj sa jednostavnijim sastojcima.';

  @override
  String get coachFat => 'Masti';

  @override
  String get coachFormulate => 'Napravi 3 recepta';

  @override
  String get coachGrade => 'Ocjena';

  @override
  String get coachInstructions => 'Priprema i kuhanje:';

  @override
  String get coachLogged => 'Uneseno';

  @override
  String get coachLogMeal => 'Unesi obrok';

  @override
  String get coachMatchedOptions => 'Pronađene opcije obroka';

  @override
  String coachMins(String n) {
    return '$n min';
  }

  @override
  String get coachPantryDesc =>
      'Unesi sastojke iz frižidera/ostave da napraviš nutritivno bogate obroke sa puno makroa.';

  @override
  String get coachPantryPlaceholder => 'npr. pileća prsa, batat, špinat, maslinovo ulje';

  @override
  String get coachPantryTitle => 'Generator recepata iz ostave';

  @override
  String get coachProtein => 'Proteini';

  @override
  String get coachRecommendations => 'Direktne preporuke';

  @override
  String get coachReviewDesc =>
      'Analiziraj današnje kalorije, proteine, vježbe i ukupni trend kako bi optimizirao svoju formu.';

  @override
  String get coachReviewTitle => 'Dnevni pregled trenera';

  @override
  String get coachRunReview => 'Pokreni AI pregled trenera';

  @override
  String get commonAdd => 'Dodaj';

  @override
  String get commonAdded => 'Dodano';

  @override
  String get commonCancel => 'Otkaži';

  @override
  String get commonClose => 'Zatvori';

  @override
  String get commonDelete => 'Obriši';

  @override
  String get commonDismiss => 'Odbaci';

  @override
  String get commonLoading => 'Učitavanje…';

  @override
  String get commonOffline => 'Niste na mreži — povežite se za sinhronizaciju';

  @override
  String get commonRecent => 'Nedavno';

  @override
  String get commonSave => 'Sačuvaj';

  @override
  String get dashboardAdjustGoal => 'Podesi cilj';

  @override
  String get dashboardAdjustGoalTitle => 'Podesi prilagođene ciljeve';

  @override
  String get dashboardBalanceTitle => 'Bilans kalorija i ciljevi';

  @override
  String get dashboardBurnedWorkouts => 'Potrošeno treningom';

  @override
  String get dashboardCaloriesLabel => 'Kalorije (kcal)';

  @override
  String get dashboardCarbohydrates => 'Ugljikohidrati';

  @override
  String get dashboardCarbsLabel => 'Ugljikohidrati (g)';

  @override
  String get dashboardConsumedFood => 'Unesena hrana';

  @override
  String get dashboardCustomGoalSettings => 'Prilagođene postavke cilja';

  @override
  String get dashboardDailyBudget => 'Dnevni budžet:';

  @override
  String get dashboardExceeded => 'Premašeno';

  @override
  String get dashboardFatLabel => 'Masti (g)';

  @override
  String get dashboardFats => 'Masti';

  @override
  String get dashboardKcalLeft => 'kcal preostalo';

  @override
  String get dashboardMacrosNote =>
      'Makronutrijenti direktno doprinose oporavku mišića i stabilnoj energiji. Pokušaj unositi uravnotežene obroke kako bi ispunio ciljeve.';

  @override
  String get dashboardMacrosTitle => 'Dnevni makronutrijenti';

  @override
  String get dashboardNetCalories => 'Neto kalorije:';

  @override
  String get dashboardOverTarget => 'Iznad cilja';

  @override
  String dashboardPercentDone(String percent) {
    return '$percent% urađeno';
  }

  @override
  String get dashboardProtein => 'Proteini';

  @override
  String get dashboardProteinLabel => 'Proteini (g)';

  @override
  String get dashboardQuickAddExercise => 'Brzo dodaj -150 kcal';

  @override
  String get dashboardQuickAddMeal => 'Brzo dodaj +200 kcal';

  @override
  String get dashboardSaveGoals => 'Sačuvaj ciljeve';

  @override
  String get dashboardStatusDone =>
      'Ispunio si svoj dnevni cilj neto kalorija! Odličan rad na održavanju ravnoteže danas.';

  @override
  String dashboardStatusLeft(String kcal) {
    return 'Imaš još $kcal kcal do svog cilja. Samo nastavi!';
  }

  @override
  String get dashboardToday => 'Danas';

  @override
  String get dashboardYesterday => 'Jučer';

  @override
  String get errAiBusy => 'AI servis je trenutno zauzet. Pokušaj ponovo za trenutak.';

  @override
  String get errAiNotConfigured => 'AI funkcije još nisu dostupne u ovoj verziji.';

  @override
  String get errDeleteAccount => 'Račun nije obrisan. Pokušaj ponovo.';

  @override
  String get errDeleteEntry => 'Unos nije obrisan. Pokušaj ponovo.';

  @override
  String get errGeneric => 'Nešto je pošlo po zlu. Pokušaj ponovo.';

  @override
  String get errGoogleFailed => 'Google prijava nije uspjela. Pokušaj ponovo.';

  @override
  String get errGoogleNotConfigured => 'Google prijava još nije podešena u ovoj verziji.';

  @override
  String get errLoadData => 'Nije moguće učitati podatke. Provjeri vezu i pokušaj ponovo.';

  @override
  String get errNetwork => 'Greška mreže. Provjeri vezu i pokušaj ponovo.';

  @override
  String get errNotSignedIn => 'Nisi prijavljen.';

  @override
  String get errResetData => 'Resetovanje podataka nije uspjelo. Pokušaj ponovo.';

  @override
  String get errSaveEntry => 'Unos nije sačuvan. Pokušaj ponovo.';

  @override
  String get errSaveGoal => 'Cilj nije sačuvan. Pokušaj ponovo.';

  @override
  String get errSaveProfile => 'Profil nije sačuvan. Pokušaj ponovo.';

  @override
  String get errSaveWater => 'Unos vode nije sačuvan. Pokušaj ponovo.';

  @override
  String get exerciseActiveLogTitle => 'Dnevnik aktivnosti';

  @override
  String get exerciseActiveMinutes => 'Aktivne minute';

  @override
  String exerciseActivities(String n) {
    return '$n aktivnosti';
  }

  @override
  String get exerciseAdjustDuration => 'Podesi trajanje treninga';

  @override
  String get exerciseCaloriesBurned => 'Potrošene kalorije (kcal)';

  @override
  String get exerciseCatalogTitle => 'Katalog treninga';

  @override
  String get exerciseCustomWorkout => 'Prilagođeni trening';

  @override
  String get exerciseDeleteEntry => 'Obriši unos';

  @override
  String get exerciseDuration => 'Trajanje (minute)';

  @override
  String exerciseDurationValue(String n) {
    return 'Trajanje: $n minuta';
  }

  @override
  String exerciseEstBurn(String kcal) {
    return 'Procjena: ~$kcal kcal za 30 min';
  }

  @override
  String get exerciseExerciseDesc => 'Opis vježbe *';

  @override
  String get exerciseKcalToday => 'kcal danas';

  @override
  String get exerciseLogCustomBtn => 'Unesi prilagođeni trening';

  @override
  String get exerciseLogCustomTitle => 'Unesi prilagođeni trening';

  @override
  String get exerciseLogExercise => 'Unesi vježbu';

  @override
  String exerciseMins(String n) {
    return '$n min';
  }

  @override
  String exerciseMinutes(String n) {
    return '$n minuta';
  }

  @override
  String get exerciseNegativeCalories => 'Negativne kalorije';

  @override
  String get exerciseNoWorkouts => 'Još nema unesenih treninga za danas.';

  @override
  String get exercisePhCaloriesBurned => 'npr. 240';

  @override
  String get exercisePhDuration => 'npr. 30';

  @override
  String get exercisePhExerciseName => 'npr. Crossfit / penjanje / tenis';

  @override
  String get exercisePresetWorkouts => 'Gotovi treninzi';

  @override
  String get exerciseRecentEmpty => 'Još ništa nije zabilježeno — treninzi će se pojaviti ovdje.';

  @override
  String get exerciseRecentTitle => 'Nedavni treninzi';

  @override
  String get exerciseSearchPlaceholder => 'Traži trčanje, plivanje, dizanje...';

  @override
  String get foodAdjustPortion => 'Podesi množilac porcije';

  @override
  String get foodAiAnalyzing => 'Analiziram sastojke obroka...';

  @override
  String get foodAiDesc => 'Upiši ili izgovori bilo koji obrok i dobij trenutnu procjenu nutrijenata. Npr.,';

  @override
  String get foodAiError => 'Gemini nije uspio procijeniti nutrijente za ovaj tekst. Pokušaj sa jasnijim opisom.';

  @override
  String get foodAiEstimateBtn => 'AI procijeni kalorije i makroe';

  @override
  String get foodAiExample => '2 kajgane sa cheddar sirom i kriškom slanine';

  @override
  String get foodAiExtracted => 'AI izdvojeni podaci';

  @override
  String get foodAiPlaceholder => 'Šta si jeo? Opiši sastojke...';

  @override
  String get foodAiTitle => 'Gemini AI pametni asistent';

  @override
  String get foodCaloriesKcal => 'Kalorije (kcal)';

  @override
  String get foodCarbs => 'Ugljikohidrati';

  @override
  String get foodCarbsG => 'Ugljikohidrati (g)';

  @override
  String get foodDbLookup => 'Pretraga baze';

  @override
  String get foodDbSearchTitle => 'Pretraga baze hrane';

  @override
  String get foodDeleteEntry => 'Obriši unos';

  @override
  String get foodDiscard => 'Odbaci';

  @override
  String get foodFat => 'Masti';

  @override
  String get foodFatsG => 'Masti (g)';

  @override
  String get foodFoodName => 'Naziv namirnice *';

  @override
  String get foodHistoryTitle => 'Historija unesenih obroka';

  @override
  String foodItemsLoaded(String n) {
    return '$n stavki učitano';
  }

  @override
  String get foodKcal => 'Kcal';

  @override
  String get foodLogAiMeal => 'Unesi AI obrok';

  @override
  String get foodLogCustomFood => 'Unesi prilagođenu namirnicu';

  @override
  String foodLogNamed(String name) {
    return 'Unesi $name';
  }

  @override
  String get foodManualAiLog => 'Ručni i AI unos';

  @override
  String get foodManualTitle => 'Ručni prilagođeni unos';

  @override
  String foodNoLogs(String date) {
    return 'Nema unesenih obroka za $date.';
  }

  @override
  String get foodNoMatch => 'Nema podudarnih namirnica u standardnoj bazi. Pređi na AI unos!';

  @override
  String get foodNoOnlineMatches => 'Nema online rezultata';

  @override
  String get foodOnlineResults => 'Online rezultati';

  @override
  String get foodPhCalories => 'npr. 150';

  @override
  String get foodPhCarbs => 'npr. 15';

  @override
  String get foodPhFat => 'npr. 2';

  @override
  String get foodPhName => 'npr. čaša vanilla jogurta';

  @override
  String get foodPhProtein => 'npr. 8';

  @override
  String get foodPhServing => 'npr. 150';

  @override
  String get foodPortion => 'Porcija:';

  @override
  String get foodPortionSize => 'Veličina porcije:';

  @override
  String get foodProtein => 'Proteini';

  @override
  String get foodProteinG => 'Proteini (g)';

  @override
  String get foodRecentEmpty => 'Još ništa nije zabilježeno — obroci će se pojaviti ovdje.';

  @override
  String get foodRecentTitle => 'Nedavni obroci';

  @override
  String get foodSearchPlaceholder => 'Traži zobene pahuljice, jaja, avokado...';

  @override
  String get foodServing => 'Porcija:';

  @override
  String get foodServingSize => 'Veličina porcije';

  @override
  String get foodTodayLower => 'danas';

  @override
  String get foodTotal => 'Ukupno:';

  @override
  String get foodUnit => 'Jedinica';

  @override
  String get foodYesterdayLower => 'jučer';

  @override
  String get footerContact => 'Kontakt';

  @override
  String get footerDeleteAccount => 'Obriši račun';

  @override
  String get footerEditProfile => 'Uredi profil';

  @override
  String get footerPrivacy => 'Politika privatnosti';

  @override
  String get footerRate => 'Ocijeni na Play-u';

  @override
  String get footerResetData => 'Resetuj podatke';

  @override
  String get footerTagline => 'NutriFlow · AI praćenje ishrane, hidracije i vježbanja · © 2026';

  @override
  String footerVersion(String version) {
    return 'Verzija $version';
  }

  @override
  String get headerAiConnected => 'AI motori povezani';

  @override
  String get headerDarkLabel => 'Tamna tema';

  @override
  String get headerLightLabel => 'Svijetla tema';

  @override
  String get headerLoggedDate => 'Datum unosa:';

  @override
  String get headerSignOut => 'Odjava';

  @override
  String get headerSyncOn => 'Sinhronizirano';

  @override
  String get headerTagline => 'Profesionalni prostor za ishranu, hidraciju i vježbanje';

  @override
  String get headerThemeToDark => 'Prebaci na tamnu temu';

  @override
  String get headerThemeToLight => 'Prebaci na svijetlu temu (visoki kontrast)';

  @override
  String get langLabel => 'Jezik';

  @override
  String modalsDeleteBody(String who) {
    return 'Ovo trajno briše $who i sve tvoje podatke — obroke, vježbe, ciljeve i hidraciju. Ova radnja se ne može poništiti.';
  }

  @override
  String get modalsDeleteBtn => 'Obriši';

  @override
  String get modalsDeleteConfirmPost => 'za potvrdu';

  @override
  String get modalsDeleteConfirmPre => 'Ukucaj';

  @override
  String get modalsDeleteTitle => 'Obriši račun';

  @override
  String get modalsDeleteYourAccount => 'tvoj račun';

  @override
  String get modalsDeleting => 'Brisanje…';

  @override
  String get modalsResetBody =>
      'Ovo trajno briše sve tvoje unesene obroke, vježbe i hidraciju za sve dane. Tvoj račun, profil i cilj kalorija/makroa se zadržavaju. Ovo se ne može poništiti.';

  @override
  String get modalsResetBtn => 'Resetuj podatke';

  @override
  String get modalsResetDone => 'Podaci resetovani';

  @override
  String get modalsResetDoneNote => 'Tvoji unosi su obrisani — novi početak!';

  @override
  String get modalsResetting => 'Resetovanje…';

  @override
  String get modalsResetTitle => 'Resetuj unesene podatke';

  @override
  String get navActive => 'Trening';

  @override
  String get navCoach => 'AI Trener';

  @override
  String get navDashboard => 'Pregled';

  @override
  String get navMeals => 'Obroci';

  @override
  String get navScan => 'Skener';

  @override
  String get navTrends => 'Trendovi';

  @override
  String get onboardingActivitiesExtraHint => 'Fizički posao / 2× dnevno';

  @override
  String get onboardingActivitiesExtraLabel => 'Izuzetno aktivan';

  @override
  String get onboardingActivitiesLightHint => '1–3 dana/sedmično';

  @override
  String get onboardingActivitiesLightLabel => 'Blago aktivan';

  @override
  String get onboardingActivitiesModerateHint => '3–5 dana/sedmično';

  @override
  String get onboardingActivitiesModerateLabel => 'Umjereno aktivan';

  @override
  String get onboardingActivitiesSedentaryHint => 'Malo ili nimalo vježbanja';

  @override
  String get onboardingActivitiesSedentaryLabel => 'Sjedeći';

  @override
  String get onboardingActivitiesVeryHint => '6–7 dana/sedmično';

  @override
  String get onboardingActivitiesVeryLabel => 'Vrlo aktivan';

  @override
  String get onboardingAgeLabel => 'Dob';

  @override
  String get onboardingAgePlaceholder => 'npr. 28';

  @override
  String get onboardingBack => 'Nazad';

  @override
  String get onboardingCarbs => 'Ugljikohidrati';

  @override
  String get onboardingContinue => 'Nastavi';

  @override
  String get onboardingCurrentWeightLabel => 'Trenutna težina';

  @override
  String get onboardingDailyCalories => 'Dnevne kalorije';

  @override
  String get onboardingDietsHighProtein => 'Visok unos proteina';

  @override
  String get onboardingDietsKeto => 'Keto';

  @override
  String get onboardingDietsLowCarb => 'Malo ugljikohidrata';

  @override
  String get onboardingDietsMediterranean => 'Mediteranska';

  @override
  String get onboardingDietsNone => 'Uravnoteženo';

  @override
  String get onboardingDietsPaleo => 'Paleo';

  @override
  String get onboardingDietsVegan => 'Veganska';

  @override
  String get onboardingDietsVegetarian => 'Vegetarijanska';

  @override
  String get onboardingEditTitle => 'Uredi svoj profil';

  @override
  String get onboardingFat => 'Masti';

  @override
  String get onboardingGoalsBuildMuscleHint => 'Čist rast, puno proteina';

  @override
  String get onboardingGoalsBuildMuscleLabel => 'Izgradi mišiće';

  @override
  String get onboardingGoalsGainHint => 'Kalorijski suficit';

  @override
  String get onboardingGoalsGainLabel => 'Dobij na težini';

  @override
  String get onboardingGoalsLoseHint => 'Kalorijski deficit';

  @override
  String get onboardingGoalsLoseLabel => 'Smršaj';

  @override
  String get onboardingGoalsMaintainHint => 'Ostani gdje jesam';

  @override
  String get onboardingGoalsMaintainLabel => 'Održavaj';

  @override
  String get onboardingHeightLabel => 'Visina';

  @override
  String get onboardingImperial => 'Imperijalni (lb/ft)';

  @override
  String get onboardingMetric => 'Metrički (kg/cm)';

  @override
  String get onboardingOptional => '(opcionalno)';

  @override
  String get onboardingPersonalizeTitle => 'Personalizirajmo NutriFlow';

  @override
  String get onboardingPromoSecondary => 'Već imam račun';

  @override
  String get onboardingPromoSubmit => 'Kreiraj račun da sačuvaš';

  @override
  String get onboardingPromoTitle => 'Kreiraj svoj besplatan plan ishrane';

  @override
  String get onboardingProtein => 'Proteini';

  @override
  String get onboardingRestrictionsDairy => 'Mliječni proizvodi';

  @override
  String get onboardingRestrictionsEggs => 'Jaja';

  @override
  String get onboardingRestrictionsGluten => 'Gluten';

  @override
  String get onboardingRestrictionsLabel => 'Ima li ograničenja / alergija?';

  @override
  String get onboardingRestrictionsNuts => 'Orašasti plodovi';

  @override
  String get onboardingRestrictionsPork => 'Svinjetina';

  @override
  String get onboardingRestrictionsShellfish => 'Školjke';

  @override
  String get onboardingRestrictionsSoy => 'Soja';

  @override
  String get onboardingReviewNote =>
      'Izračunato na osnovu tvojih podataka (Mifflin–St Jeor). Možeš ih dotjerati bilo kada s kontrolne table.';

  @override
  String get onboardingSaveChanges => 'Sačuvaj izmjene';

  @override
  String get onboardingSaving => 'Čuvanje…';

  @override
  String get onboardingSexesFemale => 'Žensko';

  @override
  String get onboardingSexesMale => 'Muško';

  @override
  String get onboardingSexesOther => 'Ostalo';

  @override
  String get onboardingSexLabel => 'Spol (za procjenu kalorija)';

  @override
  String get onboardingSignOut => 'Odjava';

  @override
  String get onboardingStartTracking => 'Počni praćenje';

  @override
  String get onboardingStep0Title => 'Koji je tvoj glavni cilj?';

  @override
  String get onboardingStep1Title => 'Malo o tebi';

  @override
  String get onboardingStep2Title => 'Tvoje mjere';

  @override
  String get onboardingStep3Title => 'Koliko si aktivan?';

  @override
  String get onboardingStep4Title => 'Preferencija ishrane';

  @override
  String get onboardingStep5Title => 'Preferencije';

  @override
  String get onboardingStep6Title => 'Tvoji personalizirani dnevni ciljevi';

  @override
  String onboardingStepOf(String current, String total) {
    return 'Korak $current od $total';
  }

  @override
  String get onboardingStepsAbout => 'O tebi';

  @override
  String get onboardingStepsActivity => 'Aktivnost';

  @override
  String get onboardingStepsBody => 'Tijelo';

  @override
  String get onboardingStepsDiet => 'Ishrana';

  @override
  String get onboardingStepsGoal => 'Cilj';

  @override
  String get onboardingStepsPrefs => 'Preferencije';

  @override
  String get onboardingStepsReview => 'Pregled';

  @override
  String get onboardingTargetWeightLabel => 'Ciljana težina';

  @override
  String get onboardingWorkoutsCardio => 'Kardio';

  @override
  String get onboardingWorkoutsCycling => 'Biciklizam';

  @override
  String get onboardingWorkoutsHIIT => 'HIIT';

  @override
  String get onboardingWorkoutsLabel => 'Treninzi koje voliš';

  @override
  String get onboardingWorkoutsRunning => 'Trčanje';

  @override
  String get onboardingWorkoutsStrength => 'Snaga';

  @override
  String get onboardingWorkoutsSwimming => 'Plivanje';

  @override
  String get onboardingWorkoutsWalking => 'Hodanje';

  @override
  String get onboardingWorkoutsYoga => 'Joga';

  @override
  String get passwordConfirmLabel => 'Potvrdi novu lozinku';

  @override
  String get passwordConfirmPlaceholder => 'Ponovo unesi lozinku';

  @override
  String get passwordErrGeneric => 'Nije moguće ažurirati lozinku. Pokušaj ponovo.';

  @override
  String get passwordErrMinLength => 'Lozinka mora imati najmanje 6 znakova.';

  @override
  String get passwordErrMismatch => 'Lozinke se ne podudaraju.';

  @override
  String get passwordHidePassword => 'Sakrij lozinku';

  @override
  String get passwordNewPassword => 'Nova lozinka';

  @override
  String get passwordNewPlaceholder => 'Najmanje 6 znakova';

  @override
  String get passwordShowPassword => 'Prikaži lozinku';

  @override
  String get passwordSubtitle => 'Odaberi novu lozinku';

  @override
  String get passwordUpdateBtn => 'Ažuriraj lozinku';

  @override
  String get passwordUpdated => 'Lozinka ažurirana';

  @override
  String get passwordUpdatedNote => 'Sve je spremno — učitavam tvoju kontrolnu tablu…';

  @override
  String get passwordUpdating => 'Ažuriranje…';

  @override
  String get photoAiEstimate => 'AI procjena';

  @override
  String get photoAnalyzing => 'Analiziram tvoj obrok…';

  @override
  String get photoCalories => 'Kalorije';

  @override
  String get photoCapture => 'Snimi';

  @override
  String get photoCarbsG => 'Ugljikohidrati g';

  @override
  String get photoCloseCamera => 'Zatvori kameru';

  @override
  String get photoDesc =>
      'Uslikaj ili pošalji fotografiju hrane — AI procjenjuje kalorije i makroe, a ti pregledaš i uneseš.';

  @override
  String get photoErrAnalysisDefault => 'Analiza nije uspjela. Pokušaj ponovo.';

  @override
  String get photoErrAnalyze => 'Nije moguće analizirati fotografiju. Pokušaj ponovo.';

  @override
  String get photoErrCamera => 'Pristup kameri je odbijen ili nije dostupan. Koristi Pošalji umjesto toga.';

  @override
  String get photoErrCapture => 'Nije moguće uslikati. Pokušaj ponovo.';

  @override
  String get photoErrRead => 'Nije moguće učitati sliku. Pokušaj drugu.';

  @override
  String get photoFatG => 'Masti g';

  @override
  String get photoIdleDesc =>
      'Iskoristi kameru za fotografiranje tanjira ili odaberi postojeću fotografiju iz galerije.';

  @override
  String get photoIdleTitle => 'Uslikaj ili pošalji obrok';

  @override
  String get photoLoggedDiary => 'Uneseno u tvoj dnevnik!';

  @override
  String get photoLogMeal => 'Unesi obrok';

  @override
  String get photoMealNamePlaceholder => 'Naziv obroka';

  @override
  String get photoNoFood => 'Hrana nije prepoznata. Pokušaj jasniju fotografiju tanjira izbliza.';

  @override
  String get photoPreviewAlt => 'Pregled obroka';

  @override
  String get photoProteinG => 'Proteini g';

  @override
  String get photoRemovePhoto => 'Ukloni fotografiju';

  @override
  String get photoRetry => 'Pokušaj ponovo';

  @override
  String get photoReviewAdjust => 'Pregledaj i prilagodi prije unosa';

  @override
  String get photoTakePhoto => 'Uslikaj';

  @override
  String get photoTitle => 'Uslikaj obrok';

  @override
  String get photoTryAnother => 'Probaj drugu';

  @override
  String get photoUpload => 'Pošalji';

  @override
  String get scannerCarbs => 'Ugljikohidrati';

  @override
  String get scannerClear => 'Obriši';

  @override
  String get scannerDescManual =>
      'Unesi UPC/EAN barkod proizvoda da ga potražiš u Open Food Facts. Nepoznati kodovi prelaze na AI procjenu.';

  @override
  String get scannerDescSupported =>
      'Skeniraj barkod proizvoda kamerom ili ga unesi ručno. Pretražuje se u Open Food Facts — nepoznati kodovi prelaze na AI procjenu.';

  @override
  String get scannerErrCamera =>
      'Pristup kameri je odbijen ili nije dostupan. I dalje možeš ručno unijeti broj barkoda ispod.';

  @override
  String get scannerErrLookup => 'Analiza barkoda nije uspjela. Pokušaj sa registriranim kodom ili provjeri okruženje.';

  @override
  String get scannerFats => 'Masti';

  @override
  String get scannerLiveViewport => 'Prikaz uživo';

  @override
  String get scannerLogToLog => 'Unesi u dnevnik';

  @override
  String get scannerLookup => 'Potraži';

  @override
  String get scannerManualDesc =>
      'Skeniranje uživo nije dostupno u ovom pregledniku. I dalje možeš unijeti broj barkoda ispod.';

  @override
  String get scannerManualLabel => 'Ili unesi barkod ručno';

  @override
  String get scannerManualTitle => 'Preporučen ručni unos';

  @override
  String get scannerMatchScanned => 'Pronađeno!';

  @override
  String get scannerPlaceholder => 'Unesi numerički UPC/EAN kod...';

  @override
  String get scannerProtein => 'Proteini';

  @override
  String get scannerReadyDesc => 'Usmjeri kameru prema barkodu proizvoda — automatski se skenira i pretražuje.';

  @override
  String get scannerReadyTitle => 'Skener kamere spreman';

  @override
  String scannerServingQty(String size, String unit) {
    return 'Veličina porcije: $size $unit';
  }

  @override
  String get scannerStatusPoint => 'Usmjeri kameru prema barkodu — skenira se automatski.';

  @override
  String get scannerStatusStarting => 'Pokretanje prikaza kamere...';

  @override
  String get scannerStatusUnsupported => 'Skeniranje uživo nije podržano u ovom pregledniku — unesi kod ručno ispod.';

  @override
  String get scannerStopCamera => 'Zaustavi kameru';

  @override
  String get scannerTitle => 'Skener barkoda';

  @override
  String get scannerUseCamera => 'Koristi kameru uređaja';

  @override
  String get waterCup => 'Šolja';

  @override
  String get waterGlass => 'Čaša';

  @override
  String get waterHydrated => 'Hidriran';

  @override
  String get waterPerfect => 'Savršena hidracija! Cilj premašen danas.';

  @override
  String get waterReduce => 'Smanji';

  @override
  String get waterReduceTitle => 'Smanji unos vode';

  @override
  String waterRemaining(String ml) {
    return 'Još $ml ml do dnevnog minimuma.';
  }

  @override
  String get waterTarget => 'Cilj: 2.5L';

  @override
  String get waterTitle => 'Praćenje hidracije';
}
