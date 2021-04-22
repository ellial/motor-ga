preamble;
openfemm(2)

a = myMotor();
a.setget_tqdes(22);

pop_size = 3;
const_state_ratio = 2/3;
for i = 1:pop_size
    individual = myMotor(); % no params means random init
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



function t = terminated(i, total) 
    if i<total
        t = 0;
    else
        t = 1;
    end
end