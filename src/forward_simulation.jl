# -----------------------------------------------------------------------------------------------------------------------------------------------------------
# FORWARD SIMULATION
# -----------------------------------------------------------------------------------------------------------------------------------------------------------
# Uses the decision rule as a strategy and runs individuals through a time series of events.
# Mark: Further optimization of the code performance can be acheived by specifying data type in more cases and saving arrays not in a dictionary but in separate files.

# -----------------------------------------------------------------------------------------------------------------------------------------------------------
# Packages and files
# -----------------------------------------------------------------------------------------------------------------------------------------------------------
using StatsBase #to use weights() function
using Distributions # work with probability distributions
using Random # to pick random


include("functions.jl")

# -----------------------------------------------------------------------------------------------------------------------------------------------------------
# Monte Carlo simulation
# -----------------------------------------------------------------------------------------------------------------------------------------------------------
function monte_carlo_simulation(decision_rule, num_simulations) # Runs forward simulations for specified number of individuals
    simulations = Dict(i => forward_simulation(decision_rule) for i in 1:num_simulations)
    return simulations
end


function forward_simulation(decision_rule) # uses decision rule as input to run simulations
    water = round(UInt8, rand(Truncated(Normal(water_max / 2, 33.33), 1, water_max))) # Range 0-200 happens with a probability of 99.7% rest is cut of.
    energy = round(UInt8, rand(Truncated(Normal(energy_max / 2, 3.33), 1, energy_max))) # Range 0-20 happens with a probability of 99.7% rest is cut of.

    # Saving information in variables that are updated throughout the simulation
    tot_offspring_season = 0
    fitnessvalue = 0
    time_steps_used_hiding = 0
    time_steps_used_feeding = 0
    time_steps_used_searching = 0
    reproductive_events = 0
    time_of_reproduction=Int[]
    time_of_searching = Int[]
    how_many_offspring=Int[]
    time_of_death = time_end
    death_cause = "Winter comes"
    temp_seq=Int[]
    hum_seq=Int[]

    decisions = zeros(UInt8, time_end - 1)
    state_decision_time = zeros(UInt16, water_max, energy_max, num_decisions, time_end-1)
    for time = 1:time_end-1 # Loop through time from beginning to end
        print("Current timestep in forward simulation: ", time, " where ")

        temp = get_temp() # Each timestep pick a weather
        humidity = get_hum()
        push!(temp_seq, temp)
        push!(hum_seq, humidity)


        state = [water, energy, temp, humidity]
        @show state
        decision = decision_rule[water, energy, temp, humidity, time]
        state_decision_time[water, energy, decision, time] +=1


        state_after_initial_decision = state_transition(state, decision)
        state = state_after_initial_decision


        found_mate = rand() |> x -> x < p_mate ? true : false # assigning true with the probability of p_mate
        dies = rand() |> x -> x < p_die ? true : false # assigning true with the probability of p_die


        if decision == SEARCH_MATE && found_mate
            state = state_transition(state, MATE)
            offspring_from_event = number_of_offspring_possible(state_after_initial_decision)
            tot_offspring_season += offspring_from_event
            fitnessvalue += direct_reward(state_after_initial_decision, time)
            reproductive_events += 1
            push!(time_of_reproduction, time)
            push!(how_many_offspring, offspring_from_event )
        end

        water, energy, _, _ = state

        decisions[time] = decision

        if decision == HIDE
            time_steps_used_hiding += 1

        elseif decision == FEED
            time_steps_used_feeding += 1

        elseif decision == SEARCH_MATE
            time_steps_used_searching += 1
            push!(time_of_searching, time)
        end


        if dies
            time_of_death = time
            death_cause = "Predation"
            break
        end

        if water == 1 && energy == 1
            time_of_death=time
            death_cause = "Dessication and Starvation"
            break
        end

        if water == 1
            time_of_death = time
            death_cause = "Dessication"
            break
        end

        if energy == 1
            time_of_death = time
            death_cause = "Starvation"
            break
        end

    end
    @show decisions
    @show fitnessvalue
    @show time_steps_used_hiding
    @show time_steps_used_feeding
    @show time_steps_used_searching
    @show time_of_searching
    @show reproductive_events
    @show how_many_offspring
    @show time_of_reproduction
    @show time_of_death
    @show death_cause
    @show temp_seq
    @show hum_seq


    data = Dict{String,Any}("decisions" => decisions,
        "state_decision_time" => state_decision_time,
        "temp_seq" => temp_seq,
        "hum_seq" => hum_seq,
        "tot_offspring_season" => tot_offspring_season,
        "fitnessvalue" => fitnessvalue,
        "time_steps_used_hiding" => time_steps_used_hiding,
        "time_steps_used_feeding" => time_steps_used_feeding,
        "time_steps_used_searching" => time_steps_used_searching,
        "time_of_searching" => time_of_searching,
        "reproductive_events" => reproductive_events,
        "how_many_offspring" => how_many_offspring,
        "time_of_reproduction" => time_of_reproduction,
        "time_of_death" => time_of_death,
        "death_cause" => death_cause)
    return data
end
