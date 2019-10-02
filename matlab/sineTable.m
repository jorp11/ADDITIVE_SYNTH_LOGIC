function sine_table = sineTable(ADDR_WIDTH,DATA_WIDTH,quarter_table)

pi_phase = 2^(ADDR_WIDTH-1);

num_points = 2^ADDR_WIDTH;
t = [0:num_points-1];

sine_table = round((2^DATA_WIDTH-1)*sin((t+.5)/(num_points)*2*pi));
if quarter_table == true
    sine_table = sine_table(1:num_points/4);
else
     sine_table = sine_table(1:num_points);
end

%TEST
