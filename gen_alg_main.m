preamble;
openfemm(2)





pop_size = 3;
const_state_ratio = 2/3;
for i = 1:pop_size
    individual = myMotor(); % no params means random init
    individual.tqdes = 22;
    individual.eval_fitness();
    population(i) = individual;
end

prCross = 0.5;
prMut = 0.4;
optimize = ["rso","rsi","dm","dc","ds","fm","fp","ft","fb","go","hh","Jpk"];

numOfIter = 5;
epoch = 1;
while ~terminated(epoch, numOfIter)
    new_ch = 2*(epoch-1);
    while new_ch < pop_size * const_state_ratio
      [~, ind] = sort([population.fitness]); %according to fitness
      population = population(ind);
      parent_1 = population(1);
      parent_2 = population(2);
      [child1,child2] = crossover(parent_1, parent_2, prCross, optimize);
      
      child_1.mutate(prMut, optimize);
      child_2.mutate(prMut, optimize);
      child_1.eval_fitness();
      child_2.eval_fitness();
      
      %++check fitness
      population(pop_size) = child_1;
      population(pop_size - 1) = child_2;
   end
   epoch = epoch+1;
end    


function [ch1,ch2] = crossover(parent1, parent2 ,p_c, prop_arr)
    %crossover ellis
    pos = randi([1,length(prop_arr)]);
    
    ch1 = myMotor();  
    ch2 = myMotor();
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
end
 
function t = terminated(i, total) 
    if i<total
        t = 0;
    else
        t = 1;
    end
end