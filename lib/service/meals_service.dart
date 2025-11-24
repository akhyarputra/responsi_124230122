// Meals by category API endpoint builder for TheMealDB
String mealsByCategoryUrl(String category) =>
    'https://www.themealdb.com/api/json/v1/1/filter.php?c=${Uri.encodeComponent(category)}';
