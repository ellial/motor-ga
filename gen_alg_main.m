pop_size = 10;
const_state_ratio = 2/3;
population = zeros(pop_size);
for i = 1:pop_size
    population(i) = myMotor(randomMotorinit);
end
while NOT terminated
   while new_ch < population * const_state_ratio
      sort(population); %according to fitness
      parent_1 = population(1);
      parent_2 = population(2);
      (child_1,child_2) = crossover(parent_1,parent_2);
      
      child1.mutate();
      child1.eval_fitness();
      child2.mutate();
      child2.eval_fitness();
      
      
      %++check fitness
      population(pop_size) = child_1;
      population(pop_size - 1) = child_2;
      
      
   end
end    