function CreateMetrologicalModel(name)
    return Dict("Name" => name, "MetrologicalStates" => [], "Edges" => [])
end

function AddMetrologicalState(metrological_model, name)
    push!(metrological_model["MetrologicalStates"], name)
    return metrological_model
end

function AddEdge(metrological_model, initial_state, final_state, emission, update_rule, second_log_derivative = nothing)
    if  !(initial_state in metrological_model["MetrologicalStates"]) && (final_state in metrological_model["MetrologicalStates"])
        error("Initial and/or final states not recognized")
        return
    end

    initial_state_index = findfirst(item -> item == initial_state, metrological_model["MetrologicalStates"])
    final_state_index = findfirst(item -> item == final_state, metrological_model["MetrologicalStates"])

    dict_edge = Dict("InitialStateName" => initial_state,
     "InitialStateIndex" => initial_state_index,
     "FinalStateName" => final_state,
     "FinalStateIndex" => final_state_index,
     "Emission" => emission,
     "UpdateRule" => update_rule)

    if second_log_derivative !== nothing
        merge!(dict_edge, Dict("SecondLogDerivative" => second_log_derivative))
    end

    push!(metrological_model["Edges"], dict_edge)

    return metrological_model
end

function Initialise(metrological_model, initial_state)
    current_state_index = findfirst(item -> item == initial_state, metrological_model["MetrologicalStates"])
    merge!(metrological_model, Dict("CurrentStateName" => initial_state, "CurrentStateIndex" => current_state_index))

    return metrological_model
end

function Evolve(metrological_model, symbol)
    current_state_index = metrological_model["CurrentStateIndex"]

    # Finds the right edge.
    edge_index = findfirst(item -> ((item["InitialStateIndex"] == current_state_index) && (item["Emission"] == symbol)), metrological_model["Edges"])

    new_state_index = metrological_model["Edges"][edge_index]["FinalStateIndex"]
    new_state_name = metrological_model["Edges"][edge_index]["FinalStateName"]
    update_rule = metrological_model["Edges"][edge_index]["UpdateRule"]

    metrological_model["CurrentStateIndex"] = new_state_index
    metrological_model["CurrentStateName"] = new_state_name

    return update_rule, metrological_model
end;

function EvolveAndComputeFisherContribution(metrological_model, symbol)
    current_state_index = metrological_model["CurrentStateIndex"]

    # Finds the right edge.
    edge_index = findfirst(item -> ((item["InitialStateIndex"] == current_state_index) && (item["Emission"] == symbol)), metrological_model["Edges"])

    new_state_index = metrological_model["Edges"][edge_index]["FinalStateIndex"]
    new_state_name = metrological_model["Edges"][edge_index]["FinalStateName"]
    update_rule = metrological_model["Edges"][edge_index]["UpdateRule"]
    second_log_derivative = metrological_model["Edges"][edge_index]["SecondLogDerivative"]

    metrological_model["CurrentStateIndex"] = new_state_index
    metrological_model["CurrentStateName"] = new_state_name

    return update_rule, second_log_derivative, metrological_model
end;