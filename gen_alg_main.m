addpath('c:\\femm42\\mfiles'); % linux (not working) => '/home/c/.wine/drive_c/femm42/mfiles'
savepath; % sudo chmod 666 /usr/local/MATLAB/R2020b/toolbox/local/pathdef.m
openfemm(2)

pop_size = 10;
const_state_ratio = 2/3;
population = zeros(1,pop_size);
for i = 1:pop_size
    population(i) = myMotor(); % no params means random init
end
while ~terminated()
   while new_ch < population * const_state_ratio
      sort(population); %according to fitness
      parent_1 = population(1);
      parent_2 = population(2);
      ll = crossover(parent_1, parent_2);
      child_1 = ll(1);
      child_2 = ll(2);
      
      child_1.mutate();
      child_2.mutate();
      child_1.eval_fitness();
      child_2.eval_fitness();
      
      %++check fitness
      population(pop_size) = child_1;
      population(pop_size - 1) = child_2;
      
      
   end
end    