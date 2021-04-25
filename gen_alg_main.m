clear;
preamble;
openfemm(2)

global id; id = 1;
global total_ch_calls; total_ch_calls = 0;
global failed_ch_calls; failed_ch_calls = 0;
global acceptRange; acceptRange = goodAcceptRange()

pop_size = 4;
assert(mod(pop_size,2)==0); %fill by adding 2 children at a time
numOfIter = 5;

%% Randomly initialize first gen
global epoch; epoch = 1;
for i = 1:pop_size
    individual = myMotor(); % no params means random init
    individual.tqdes = 22;
    individual.eval_fitness();
    population(i) = individual;
    population_log(1, i) = individual;
end

%% Start evolving
prCross = 1;
prMut = 1;
optimize = ["rso","rsi","dm","dc","ds","fm","fp","ft","fb"];

while ~terminated(epoch, numOfIter)
    epoch = epoch+1;
    fprintf("starting epoch %d\n", epoch);
    
    new_population = myMotor.empty();
    new_ch = 0;
    while (new_ch ~= pop_size)
        %parent_1 = rank_selection(population); 
        %parent_2 = rank_selection(population); 
        % OR
        parent_1 = roulette_selection(population);
        parent_2 = roulette_selection(population);
        
        [child_1, child_2] = crossover(parent_1, parent_2, prCross, optimize);

        child_1.mutate(prMut, optimize);
        child_2.mutate(prMut, optimize);
        child_1.eval_fitness();
        child_2.eval_fitness();
        
        new_population(new_ch+1) = child_1; 
        new_ch = new_ch + 1;
        new_population(new_ch+1) = child_2;
        new_ch = new_ch + 1;
    end
    population = new_population;
    population_log(epoch,:) = new_population;
end    
       
%% plot results
i = 1;
for gen = 1:numOfIter
    for mindex = 1:pop_size
        x(i) = gen;
        y(i) = population_log(gen, mindex).mass;
        i = i+1;
    end
end

scatter(x,y,'filled');
xticks(1:numOfIter)
title("Evolutionary progress");
ylabel("mass (kg)");
xlabel("generations");
%fprintf("%d out of %d random initializations failed due to contraints\n", failed_ch_calls, total_ch_calls);

%% function declarations
function [ch1,ch2] = crossover(parent1, parent2 ,p_c, prop_arr)
    %crossover ellis
    pos = randi([1,length(prop_arr)]);
    crossprint(pos, prop_arr);
    ch1 = copy(parent1);  
    ch2 = copy(parent2);
    %child1 crossover
    if(randi([1,100])< 100*p_c)
        while ~(ch1.check_constraints())
            for i=1:pos
               ch1.(prop_arr(i)) = parent1.(prop_arr(i)); 
            end   
            for i = pos:len(prop_arr)
               ch1.(prop_arr(i)) = parent2.(prop_arr(i)); 
            end
        end
    end
    %child2 crossover
    if(randi([1,100])< 100*p_c)
        while ~(ch2.check_constraints())
            for i=1:pos
               ch2.(prop_arr(i)) = parent2.(prop_arr(i)); 
            end   
            for i = pos:len(prop_arr)
               ch2.(prop_arr(i)) = parent1.(prop_arr(i)); 
            end
        end
    end
    %return list ch1,ch2
    
    function crossprint(pos, prop_arr)
        fprintf("        crossover: ");
        for i=1:pos
            fprintf("%s ",prop_arr(i));
        end
        fprintf("~~~ ");
        for i=pos+1:length(prop_arr)
            fprintf("%s ",prop_arr(i));
        end
        fprintf("\n");
    end
end
 
function individual = roulette_selection(population)
    % note: minimization problems need to turn into maximization
    
    % calculate sum of fitnesses - na to kanw DP
    sum = 0;
    for i=1:length(population)
        sum = sum + population(i).fitness; 
    end
    
    % normalize
    for i=1:length(population)
        normfitness(i) = population(i).fitness/sum;
    end
    randnum = rand;
    % calculate cumulative probability distribution
    level = 0;
    for i=1:length(population)
        level = level + normfitness(i);
        %if i==length(population) fprintf("level====%d\n", level); end
        if randnum < level
            individual = population(i);
            return;
        end
    end
end

function bigger = rank_selection(population)
    % return max and pop
    sorted_pop = fitness_sort(population); % ascending
    bigger = sorted_pop(length(population));
    population(population == bigger) = []; % pop
    
    function sorted = fitness_sort(pop)
        [~, ind] = sort([pop.fitness]);
        sorted = pop(ind);
    end

end

function t = terminated(i, total) 
    if i<total
        t = 0;
    else
        t = 1;
    end
end