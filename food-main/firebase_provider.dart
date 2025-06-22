//final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  //return FirebaseService();
//});

//final userOrdersProvider = StreamProvider((ref) {
  //final firebaseService = ref.watch(firebaseServiceProvider);
  //return firebaseService.getUserOrders();
//});

//final userNotificationsProvider = StreamProvider((ref) {
  //final firebaseService = ref.watch(firebaseServiceProvider);
  //return firebaseService.getUserNotifications();
//});

//final mealReviewsProvider = StreamProvider.family((ref, String mealId) {
  //final firebaseService = ref.watch(firebaseServiceProvider);
  //return firebaseService.getMealReviews(mealId);
//});

//final mealPlanProvider = StreamProvider((ref) {
  //final firebaseService = ref.watch(firebaseServiceProvider);
  //return Stream.fromFuture(firebaseService.getMealPlans());
//}); 