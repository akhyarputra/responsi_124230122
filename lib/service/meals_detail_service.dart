// Meal detail lookup API endpoint builder for TheMealDB
String mealDetailUrl(String idMeal) =>
    'https://www.themealdb.com/api/json/v1/1/lookup.php?i=${Uri.encodeComponent(idMeal)}';
