using StatsBase

function CreateHMM(name)
    return Dict("Name" => name, "States" => [], "Edges" => [])
end

function AddStateHMM(HMM, name)
    push!(HMM["States"], name)
    return HMM
end

function AddEdgeHMM(HMM, initial_state, final_state, emission, probability)
    if  !(initial_state in HMM["States"]) && (final_state in HMM["States"])
        error("Initial and/or final states not recognized")
        return
    end

    initial_state_index = findfirst(item -> item == initial_state, HMM["States"])
    final_state_index = findfirst(item -> item == final_state, HMM["States"])

    dict_edge = Dict("InitialStateName" => initial_state,
     "InitialStateIndex" => initial_state_index,
     "FinalStateName" => final_state,
     "FinalStateIndex" => final_state_index,
     "Emission" => emission,
     "Probability" => probability)

    push!(HMM["Edges"], dict_edge)

    return HMM
end

function InitialiseHMM(HMM, initial_state)
    current_state_index = findfirst(item -> item == initial_state, HMM["States"])
    merge!(HMM, Dict("CurrentStateName" => initial_state, "CurrentStateIndex" => current_state_index))

    return HMM
end

function EvolveHMM(HMM)
    current_state_index = HMM["CurrentStateIndex"]

    # Extracts the emission and the new state with the appropriate probability.
    possible_edges = []
    for edge in HMM["Edges"]
        if edge["InitialStateIndex"] == current_state_index
            push!(possible_edges, edge)
        end
    end

    v_probabilities = [edge["Probability"] for edge in possible_edges]

    edge = sample(possible_edges, Weights(v_probabilities))

    new_state_index = edge["FinalStateIndex"]
    new_state_name = edge["FinalStateName"]
    emission = edge["Emission"]

    HMM["CurrentStateIndex"] = new_state_index
    HMM["CurrentStateName"] = new_state_name

    return emission, HMM
end;

function GenerateStringHMM(HMM, string_length)
    string = ""

    for item in 1:string_length
        emission, HMM = EvolveHMM(HMM)
        string *= emission
    end

    return string
end