# -----------------------------------------------------------------------------------------------------------------------------------------------------------
# BACKWARDS ITERATION - CALCULATING THE OPTIMAL STRATEGY BASED ON STATE
# -----------------------------------------------------------------------------------------------------------------------------------------------------------
# In this scipt backwards iteration is used to loop through combinations of state and time and compare the fitness (reward) of different decisions to find the optimal
# strategy, here called decision rule.

using IterTools # Uses this package to use product() function instead of nested for loop
include("functions.jl")
include("parameters.jl")

function activity_rule()
    """
    Activity rule is a function figures out what desicion (choice of activity) that is optimal for each combination of states and time using backwards iteration.
    future_reward is a table that stores what the expected reward, given a state and time, from the given timestep and til time_end.
    This means that the reward at the final time step is 0, since the insect do not have any future timesteps to gain any reward.
    Reward_if_decision set up the a matrix with the reward the insect gets from doing the different decisions at different combinations of states, all decisions are put into same matrix.
    descition_rule stores the optimal descitions for a given state and timestep as the backward iteration passes.
    """

    future_reward = zeros(Float64, water_max, energy_max, temp_max, humidity_max, time_end)
    reward_if_decision = zeros(Float64, water_max, energy_max, temp_max, humidity_max, num_decisions)
    decision_rule = zeros(Int, water_max, energy_max, temp_max, humidity_max, time_end - 1) # Integer since it is only 1=HIDE, 2=FEED, 3=SEARCH_MATE

    for time = time_end-1:-1:1 # Run backwards through time, from end to start
        @info ("Timeteps remaining in backwards simulation: ", time)
        for (water, energy, temp, humidity, decision) in product(1:water_max, 1:energy_max, 1:temp_max, 1:humidity_max, [HIDE, FEED, SEARCH_MATE]) # Loop through all combinations of state decitions

            state_now = [water, energy, temp, humidity]

            total_reward = 0

            if decision == SEARCH_MATE
                state_after_search = state_transition(state_now, SEARCH_MATE)
                state_after_mated = state_transition(state_after_search, MATE)

                # DIRECT REWARD
                total_reward += p_mate * direct_reward(state_after_search, time)

                # FUTURE REWARD
                for (mated, _temp, _humidity) in product([true, false], 1:temp_max, 1:humidity_max)
                    _state = mated ? state_after_mated : state_after_search
                    mated_prob = mated ? p_mate : round(1 - p_mate, digits=2)
                    weather_prob = temp_probs[_temp] *hum_probs[_humidity]
                    _water, _energy, _, _ = _state

                    total_reward += p_survive * mated_prob * weather_prob * future_reward[_water, _energy, _temp, _humidity, time+1]
                end
            else
                next_state = state_transition(state_now, decision)
                # FUTURE REWARD
                for (_temp, _humidity) in product(1:temp_max, 1:humidity_max)
                    weather_prob = temp_probs[_temp] * hum_probs[_humidity]
                    _water, _energy, _, _ = next_state

                    total_reward += p_survive * weather_prob * future_reward[_water, _energy, _temp, _humidity, time+1]
                end
            end

            reward_if_decision[water, energy, temp, humidity, decision] = total_reward


        end
        reward_if_decision .= overwrite_death_value(reward_if_decision) # If water or energy becomes lower than 1 death occures and this sets the possibilities for more reward to 0 if so happens.
        reward_if_decision = round.(reward_if_decision, digits=4)
        value, index = findmax(reward_if_decision, dims=num_states + 1) # Compares reward of different decisions. Saves the max reward that can be optained for each combination of states and saves which descision this highest reward belongs to.
        future_reward[:, :, :, :, time] = value
        decision_rule[:, :, :, :, time] = getindex.(index, num_states + 1) # Saves the decision that has the highest reward for each combination of states at this timestep in the decision_rule matrix.
        # Notice: See from results that if two decisions have similar reward, default is to choose the lowest number
    end
    return decision_rule
end
