# -----------------------------------------------------------------------------------------------------------------------------------------------------------
# VISUALIZATION OF DECISION RULE
# -----------------------------------------------------------------------------------------------------------------------------------------------------------

include("parameters.jl")

using PlotlyJS # For plotting
using JLD2 # To load jld files


""" In this script it is needed to go in manually and specify funtion input and file path for saving plots """

desicion_rule_folder="baseline"
visualization_folder="baseline"
decision_rule = load("simulations/$desicion_rule_folder/decision_rule.jld2")["decision_rule"]


function plot_decision_rule_diff_weathers(timestep, temp)
    color_list=["#882255", "#117733", "#DDCC77", "#8cbb7d"]
    categories = [ "Hide", "Feed", "Search"]
    levels = [0,1,2,3]
    label_levels = levels .+ 0.5
    norm_levels = (levels .- minimum(levels))/maximum(levels)
    color_marks = [[norm_levels[1], color_list[1]]]
    for i in 2:length(levels)
        push!(color_marks, [norm_levels[i], color_list[i-1]])
        push!(color_marks, [norm_levels[i], color_list[i]])
    end


        data = decision_rule[:, :, temp, 1, timestep]
        trace1=heatmap(z=data, y=1:200, x=1:20, autocolorscale=false, colorscale=color_marks, colorbar=attr(tickmode="array", tickvals=label_levels, ticktext=categories, ticksize=9), zmin=1,
        zmax=3, showscale=false)
        layout1=Layout(title="Temp=$temp Hum=1")
        p1=plot(trace1, layout1)
        data = decision_rule[:, :, temp, 2, timestep]
        trace2=heatmap(z=data, y=1:200, x=1:20, autocolorscale=false, colorscale=color_marks, colorbar=attr(tickmode="array", tickvals=label_levels, ticktext=categories, ticksize=9),  zmin=1,
        zmax=3, showscale=false)
        layout2=Layout(title="Temp=$temp Hum=2")
        p2=plot(trace2, layout2)
        data = decision_rule[:, :, temp, 3, timestep]
        trace3=heatmap(z=data, y=1:200, x=1:20, autocolorscale=false, colorscale=color_marks, colorbar=attr(tickmode="array", tickvals=label_levels, ticktext=categories, ticksize=9),  zmin=1,
        zmax=3, showscale=false)
        layout3=Layout(title="Temp=$temp Hum=3")
        p3=plot(trace2, layout3)
        data = decision_rule[:, :, temp, 4, timestep]
        trace4=heatmap(z=data, y=1:200, x=1:20, autocolorscale=false, colorscale=color_marks, colorbar=attr(tickmode="array", tickvals=label_levels, ticktext=categories, ticksize=9),  zmin=1,
        zmax=3, showscale=false)
        layout4=Layout(title="Temp=$temp Hum=4")
        p4=plot(trace4, layout4)
        data = decision_rule[:, :, temp, 5, timestep]
        trace5=heatmap(z=data, y=1:200, x=1:20, autocolorscale=false, colorscale=color_marks, colorbar=attr(tickmode="array", tickvals=label_levels, ticktext=categories, ticksize=9),  zmin=1,
        zmax=3, showscale=false)
        layout5=Layout(title="Temp=$temp Hum=5")
        p5=plot(trace5, layout5)
        data = decision_rule[:, :, temp, 5, timestep] # This one is just the same, just to make it 2*3
        trace6=heatmap(z=data, y=1:200, x=1:20, autocolorscale=false, colorscale=color_marks, colorbar=attr(tickmode="array", tickvals=label_levels, ticktext=categories, ticksize=9),  zmin=1,
        zmax=3, showscale=false)
        layout6=Layout(title="same")
        p6=plot(trace6, layout6)



    p=[p1 p2 p3; p4 p5 p5]
    relayout!(p, title_text="Decision rule, timestep $timestep, different weathers", x_title="Energy", y_title="Water")
    return savefig(p, "Visualizations/$visualization_folder/decision_rule_weather_time=$timestep-temp=$temp.png") # Saves the plot at the specified location with name
end


plot_decision_rule_diff_weathers(30, 1)
plot_decision_rule_diff_weathers(30, 2)
plot_decision_rule_diff_weathers(30, 3)
plot_decision_rule_diff_weathers(30, 4)
plot_decision_rule_diff_weathers(30, 5)



function plot_decision_rule_throug_time(time1, time2, time3, time4, time5, time6, temp, hum)
    color_list=["#882255", "#117733", "#DDCC77", "#8cbb7d"]
    categories = [ "Hide", "Feed", "Search"]
    levels = [0,1,2,3]
    label_levels = levels .+ 0.5
    norm_levels = (levels .- minimum(levels))/maximum(levels)
    color_marks = [[norm_levels[1], color_list[1]]]
    for i in 2:length(levels)
        push!(color_marks, [norm_levels[i], color_list[i-1]])
        push!(color_marks, [norm_levels[i], color_list[i]])
    end


        data = decision_rule[:, :, temp, hum, time1]
        trace1=heatmap(z=data, y=1:200, x=1:20, autocolorscale=false, colorscale=color_marks, colorbar=attr(tickmode="array", tickvals=label_levels, ticktext=categories, ticksize=9), zmin=1,
        zmax=3, showscale=false)
        layout1=Layout(title="time step $time1")
        p1=plot(trace1, layout1)
        data = decision_rule[:, :, temp, hum, time2]
        trace2=heatmap(z=data, y=1:200, x=1:20, autocolorscale=false, colorscale=color_marks, colorbar=attr(tickmode="array", tickvals=label_levels, ticktext=categories, ticksize=9),  zmin=1,
        zmax=3, showscale=false)
        layout2=Layout(title="time step $time2")
        p2=plot(trace2, layout2)
        data = decision_rule[:, :, temp, hum, time3]
        trace3=heatmap(z=data, y=1:200, x=1:20, autocolorscale=false, colorscale=color_marks, colorbar=attr(tickmode="array", tickvals=label_levels, ticktext=categories, ticksize=9),  zmin=1,
        zmax=3, showscale=false)
        layout3=Layout(title="time step $time3")
        p3=plot(trace2, layout3)
        data = decision_rule[:, :, temp, hum, time4]
        trace4=heatmap(z=data, y=1:200, x=1:20, autocolorscale=false, colorscale=color_marks, colorbar=attr(tickmode="array", tickvals=label_levels, ticktext=categories, ticksize=9),  zmin=1,
        zmax=3, showscale=false)
        layout4=Layout(title="time step $time4")
        p4=plot(trace4, layout4)
        data = decision_rule[:, :, temp, hum, time5]
        trace5=heatmap(z=data, y=1:200, x=1:20, autocolorscale=false, colorscale=color_marks, colorbar=attr(tickmode="array", tickvals=label_levels, ticktext=categories, ticksize=9),  zmin=1,
        zmax=3, showscale=false)
        layout5=Layout(title="time step $time5")
        p5=plot(trace5, layout5)
        data = decision_rule[:, :, temp, hum, time6]
        trace6=heatmap(z=data, y=1:200, x=1:20, autocolorscale=false, colorscale=color_marks, colorbar=attr(tickmode="array", tickvals=label_levels, ticktext=categories, ticksize=9),  zmin=1,
        zmax=3, showscale=false)
        layout6=Layout(title="time step $time6")
        p6=plot(trace6, layout6)



    p=[p1 p2 p3; p4 p5 p6]
    relayout!(p, title_text="Baseline scenarop, decision rule for different timesteps", x_title="Energy", y_title="Water")
    return savefig(p, "Visualizations/$visualization_folder/decision_rule_through_time_$temp$hum.png") # Saves the plot at the specified location with name
end


function plot_it()
    for temp in 1:5
        for hum in 1:5
            plot_decision_rule_throug_time(1, 12, 24, 36, 48, 59, temp, hum)
        end
    end
end

plot_it()
