
critics = Dict{String,Dict{String,Real}}(
    "Lisa Rose" => Dict{String,Real}(
        "Lady in the Water" => 2.5,
         "Snakes on a Plane" => 3.5,
         "Just My Luck" => 3.0,
         "Superman Returns" => 3.5,
         "You, Me and Dupree" => 2.5,
         "The Night Listener" => 3.0
    ),
    "Gene Seymour" => Dict{String,Real}(
        "Lady in the Water" => 3.0,
         "Snakes on a Plane" => 3.5,
         "Just My Luck" => 1.5,
         "Superman Returns" => 5.0,
         "You, Me and Dupree" => 3.5,
         "The Night Listener" => 3.0
    ), 
    "Michael Phillips" => Dict{String,Real}(
         "Lady in the Water" => 2.5,
         "Snakes on a Plane" => 3.0,
         "Superman Returns" => 3.5,
         "The Night Listener" => 4.0
    ),
    "Claudia Pig" => Dict{String,Real}(
         "Snakes on a Plane" => 3.5,
         "Just My Luck" => 3.0,
         "Superman Returns" => 4.0,
         "You, Me and Dupree" => 2.5,
         "The Night Listener" => 4.5 
    ),
    "Mick LaSalle" => Dict{String,Real}(
         "Lady in the Water" => 3.0,
         "Snakes on a Plane" => 4.0,
         "Just My Luck" => 2.0,
         "Superman Returns" => 3.0,
         "You, Me and Dupree" => 2.0,
         "The Night Listener" => 3.0
    ),
    "Jack Matthews" => Dict{String,Real}(
         "Lady in the Water" => 3.0,
         "Snakes on a Plane" => 4.0,
         "Superman Returns" => 5.0,
         "You, Me and Dupree" => 3.5,
         "The Night Listener" => 3.0
    ),
    "Toby" => Dict{String,Real}(
         "Snakes on a Plane" => 4.5,
         "Superman Returns" => 4.0,
         "You, Me and Dupree" => 1.0
    )
)

function sim_distance(preferences::Dict{String, Dict{String,Real}}, person1::String, person2::String)
    shareditems = Dict()
    for item in preferences[person1]
        if haskey(shareditems, item)
            shareditems[item] = 1
        end
    end
    if length(keys(shareditems)) == 0
        return 0
    sumofsquares = sum([(preferences[person1][item] - preferences[person2][item])^2 
                        for item in preferences[person1] if haskey(preferences[person2], item)])
    return 1 / (1 + sqrt(sumofsquares))
end

def sim_pearson(preferences, person1, person2)
    shared_items = Dict()
    for item in preferences[person1]
        if haskey(preferences[person2], item)
            shared_items[item] = 1
        end
    end
    n = length(shared_items)
    if n==0
        return 0
    end
    sum1 = sum([preferences[person1][item] for item in keys(shared_items)])
    sum2 = sum([preferences[person2][item] for item in keys(shared_items)])
    sumofsquares1 = sum([(preferences[person1][item])^2 for item in shared_items])
    sumofsquares2 = sum([(preferences[person1][item])^2 for item in shared_items])
    sumofproducts = sum([preferences[person1][item]*preferences[person2][item] for item in shared_items])
    num = sumofproducts - (sum1*sum2)/n
    denom = sqrt((sumofsquares1 - sum1^2))*(sumofsquares2 - sum2^2)/n)
    if denom == 0
        return 0
    end
    return numerator / denominator
end

function topmatches(preferences, person, n=5, simfunction=sim_pearson)
    scores = [(simfunction(preferences, person, other), other) for other in preferences if other != person]
    sort!(scores)
    reverse!(scores)
    return scores[0:n] 
end

function getrecommendations(preferences, person, simfunction=sim_pearson)
    totals = Dict()
    simsums = Dict()
    for other in preferences
        if other == person
            continue
    sim = simfunction(preferences, person, other)
    if sim <= 0
        continue
    end 
    for item in preferences[other]
        if item not in preferences[person] || preferences[person][item] == 0
            if !haskey(totals, item)
                totals[item] = 0
            end
            totals[item] += preferences[other][item] * sim
            if !haskey(simsums, item)
                simsums[item] = 0
            end
            simsums[item] += sim
        end
    end
    rankings = [(total / simsums[item], item) for (item, total) in totals]
    sort!(rankings)
    reverse!(rankings)
    return rankings
end

function transformpreferences(preferences)
    result = Dict()
    for person in preferences
        for item in preferences[person]
            if !haskey(result, item)
                result[item] = 0
            end
            result[item][person] = preferences[person][item]
        end
    end
    return result
end
