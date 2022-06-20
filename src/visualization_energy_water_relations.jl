# -----------------------------------------------------------------------------------------------------------------------------------------------------------
# VISUALIZATION OF ENERGY AND WATER RELATIONS
# -----------------------------------------------------------------------------------------------------------------------------------------------------------


include("functions.jl")
include("parameters.jl")

using JLD2
using PlotlyJS
using DataFrames

# -----------------------------------------------------------------------------------------------------------------------------------------------------------
# PLOTTING NET WATER AS A FUNCTION OF WATER TEMPERATURE (for different hum/wateravailabilities)
# -----------------------------------------------------------------------------------------------------------------------------------------------------------
""" In this script it is needed to go in manually and specify file path for saving plots """

function calculate_net_water_feed(hum)
    waterloss_col=waterloss[hum,:]
    netto_water_hum_feed=[]
    for col in 1:5
        push!(netto_water_hum_feed, watergain[hum]-waterloss_col[col]*2)
    end
    return netto_water_hum_feed
end

calculate_net_water_feed(1)

waterloss=waterloss

function plot_net_water_decision()
    p=plot()
    color=["000000", "333333" ,"666666", "999999", "cccccc"] #TODO fix colors
    for decision in 1:3
        if decision == 1
            action = "Hide"
        elseif decision == 2
            action = "Feed"
        elseif decision == 3
            action = "Search mate"
        end
        for hum =1:5
            if decision == 1
                add_trace!(p, scatter(x=[1,2,3,4,5], y=-waterloss[hum, :], marker=attr(color=color[hum]), name="$action Humidity $hum", line=attr(color=color[hum], width=2, dash="dot")))
            elseif decision == 2
                add_trace!(p, scatter(x=[1,2,3,4,5], y=calculate_net_water_feed(hum), marker=attr(color=color[hum]), name="$action Humidity $hum", line=attr(color=color[hum], width=2, dash="dash")))
            elseif decision == 3
                add_trace!(p, scatter(x=[1,2,3,4,5], y=-waterloss[hum, :]*2, line=attr(color=color[hum], with=2), name="$action Humidity $hum"))
            end
        end
        relayout!(p, barmode="scatter", xaxis_title_text="Temperature", yaxis_title_text="Net water", plot_bgcolor="F1F3F9", title="Net water for different activities, temperatures and humidities.")
    end
    return savefig(p, "Visualizations/relationships_energy_and_water/water_plot_activities.png")
end

plot_net_water_decision()


# -----------------------------------------------------------------------------------------------------------------------------------------------------------
# PLOTTING ENERGY RELATIONS
# -----------------------------------------------------------------------------------------------------------------------------------------------------------

net_energy_feed_round=[]
net_energy_feed_float=[]
for temperature in 1:5
    push!(net_energy_feed_round, round(Int, -function_exp(a_feed_rep, temperature) + function_logistic(temperature, k_feed, x_0_feed, L_feed)))
    push!(net_energy_feed_float, - function_exp(a_feed_rep, temperature) + function_logistic(temperature, k_feed, x_0_feed, L_feed))
end

energy_loss_hide_round=[]
energy_loss_hide_float=[]
for temperature in 1:5
    push!(energy_loss_hide_round, - round(Int, function_exp(a_hide, temperature)))
    push!(energy_loss_hide_float, - function_exp(a_hide, temperature))
end


energy_loss_hide=[]
energy_loss_feed=[]
energy_gain_feed=[]
energy_loss_search=[]
for temperature in 1:5
    push!(energy_loss_hide, - round(Int, function_exp(a_hide, temperature)))
    push!(energy_loss_feed, - function_exp(a_feed_rep, temperature))
    push!(energy_loss_search, -(round(Int, function_exp(a_feed_rep, temperature)))-searchcost_energy)
    push!(energy_gain_feed, function_logistic(temperature, k_feed, x_0_feed, L_feed))
end
color=["000000", "000000" ,"999999", "999999",  "000000",  "000000"]
line1 = scatter(x=[1,2,3,4,5], y=energy_loss_hide, marker=attr(color=color[1]), name="Energy loss Hiding, - A<sub>1</sub>(z)", line=attr(color=color[1], width=2, dash="dot"))
line2 = scatter(x=[1,2,3,4,5], y=net_energy_feed_round, marker=attr(color=color[2]), name="Net energy Feeding, C<sub>1</sub>(z) - A<sub>2</sub>(z)", line=attr(color=color[2], width=2, dash="dash"))
line3 = scatter(x=[1,2,3,4,5], y=energy_loss_feed, marker=attr(color=color[3]), name="Energy loss Feeding, - A<sub>2</sub>(z)", line=attr(color=color[3], width=2, dash="dash"))
line4 = scatter(x=[1,2,3,4,5], y=energy_gain_feed, marker=attr(color=color[4]), name="Energy gain Feeding, C<sub>1</sub>(z)", line=attr(color=color[4], width=2, dash="dash"))
line5 = scatter(x=[1,2,3,4,5], y=energy_loss_search, marker=attr(color=color[5]), name="Energy loss Searching, - A<sub>3</sub>(z)", line=attr(color=color[5], width=2))

layout=Layout(title="Energy relations for the different activities", xaxis_title="Temperature", yaxis_title="Energy", plot_bgcolor="F1F3F9")
energy_plot=plot([line1, line2, line3, line4, line5], layout)

savefig(energy_plot, "Visualizations/relationships_energy_and_water/energy_plot_activities.png")
