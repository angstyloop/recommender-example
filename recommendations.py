from math import sqrt

critics = {
    'Lisa Rose': {
        'Lady in the Water': 2.5,
        'Snakes on a Plane': 3.5,
        'Just My Luck': 3.0,
        'Superman Returns': 3.5,
        'You, Me and Dupree': 2.5,
        'The Night Listener': 3.0
    },
    'Gene Seymour': {
        'Lady in the Water': 3.0,
        'Snakes on a Plane': 3.5,
        'Just My Luck': 1.5,
        'Superman Returns': 5.0,
        'You, Me and Dupree': 3.5,
        'The Night Listener': 3.0
    },
    'Michael Phillips': {
        'Lady in the Water': 2.5,
        'Snakes on a Plane': 3.0,
        'Superman Returns': 3.5,
        'The Night Listener': 4.0
    },
    'Claudia Puig': {
        'Snakes on a Plane': 3.5,
        'Just My Luck': 3.0,
        'Superman Returns': 4.0,
        'You, Me and Dupree': 2.5,
        'The Night Listener': 4.5
    },
    'Mick LaSalle': {
        'Lady in the Water': 3.0,
        'Snakes on a Plane': 4.0,
        'Just My Luck': 2.0,
        'Superman Returns': 3.0,
        'You, Me and Dupree': 2.0,
        'The Night Listener': 3.0
    },
    'Jack Matthews': {
        'Lady in the Water': 3.0,
        'Snakes on a Plane': 4.0,
        'Superman Returns': 5.0,
        'You, Me and Dupree': 3.5,
        'The Night Listener': 3.0
    },
    'Toby': {
        'Snakes on a Plane': 4.5,
        'Superman Returns': 4.0,
        'You, Me and Dupree': 1.0,
    }
}


def sim_distance(preferences, person1, person2):
    shared_items = {}
    for item in preferences[person1]:
        if item in preferences[person2]:
            shared_items[item] = 1
    if len(shared_items) == 0:
        return 0
    sum_of_squares = sum([pow(preferences[person1][item] - preferences[person2][item], 2)
                    for item in preferences[person1] if item in preferences[person2]])
    return 1 / (1 + sqrt(sum_of_squares))


def sim_pearson(preferences, person1, person2):
    shared_items = {}
    for item in preferences[person1]:
        if item in preferences[person2]:
            shared_items[item] = 1
    n = len(shared_items)
    if n == 0:
        return 0
    sum1 = sum([preferences[person1][item] for item in shared_items])
    sum2 = sum([preferences[person2][item] for item in shared_items])
    sum1_of_squares = sum([pow(preferences[person1][item], 2) for item in shared_items])
    sum2_of_squares = sum([pow(preferences[person2][item], 2) for item in shared_items])
    sum_of_products = sum([preferences[person1][item]*preferences[person2][item] for item in shared_items])
    numerator = sum_of_products - (sum1 * sum2) / n
    denominator = sqrt((sum1_of_squares - pow(sum1, 2)) * (sum2_of_squares - pow(sum2, 2)) / n)
    if denominator == 0:
        return 0
    return numerator / denominator


def top_matches(preferences, person, n=5, similarity_function=sim_pearson):
    scores = [(similarity_function(preferences, person, other), other) for other in preferences if other != person]
    scores.sort()
    scores.reverse()
    return scores[0:n]


def get_recommendations(preferences, person, similarity_function=sim_pearson):
    totals = {}
    similarity_sums = {}
    for other in preferences:
        if other == person:
            continue
        similarity = similarity_function(preferences, person, other)
        if similarity <= 0:
            continue
        for item in preferences[other]:
            if item not in preferences[person] or preferences[person][item] == 0:
                totals.setdefault(item, 0)
                totals[item] += preferences[other][item] * similarity
                similarity_sums.setdefault(item, 0)
                similarity_sums[item] += similarity
        rankings = [(totals[item] / similarity_sums[item], item) for item, total in totals.items()]
        rankings.sort()
        rankings.reverse()
        return rankings


def transform_preferences(preferences):
    result = {}
    for person in preferences:
        for item in preferences[person]:
            result.setdefault(item, {})
            result[item][person] = preferences[person][item]
    return result
