%scatter([x1,x2,x3...], [y1,y2,y3...])

pop_size = 3;
numOfIter = 5; %total generations

i = 1;
for gen = 1:numOfIter
    for mindex = 1:pop_size
        x(i) = gen;
        y(i) = population(gen, mindex).fitness;
        i = i+1;
    end
end

scatter(x,y,'filled');
ylabel("mass");
xlabel("generations");