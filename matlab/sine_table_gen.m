function output = sineTable(ADDR_WIDTH,DATA_WIDTH)

ADDR_WIDTH = 6;
DATA_WIDTH = 4;
quarter_table = true;
pi_phase = 2^(ADDR_WIDTH-1);

num_points = 2^ADDR_WIDTH;
t = [0:num_points-1];

sine_table = round(2^DATA_WIDTH*sin((t+.5)/(num_points)*2*pi));
if quarter_table == true
    sine_table = sine_table(1:num_points/4);
end

%TEST

%phase accumulator
fs = 22.1E3;
freq = 350;
delta = round(freq/fs*2^ADDR_WIDTH);
actual_freq = delta*fs/2^ADDR_WIDTH;
freq_error = actual_freq-freq;
time = 1; %second
num_samples= round(time*fs);
phase = zeros(1,num_samples);
output = zeros(1,num_samples);
MSB = zeros(1,num_samples);
MSB_minus_1 = zeros(1,num_samples);

for i=2:num_samples
    phase (i) = mod(phase(i-1)+delta,2^ADDR_WIDTH);
end
for i=2:num_samples
    bin_phase = de2bi(phase(i),ADDR_WIDTH,'right-msb');
    MSB(i) = bin_phase(ADDR_WIDTH);
    MSB_minus_1(i)  = bin_phase(ADDR_WIDTH-1);
    switch num2str(bin_phase(ADDR_WIDTH-1:ADDR_WIDTH))
        case '0  0' 
            output(i) = sine_table(bi2de(bin_phase(1:ADDR_WIDTH-2))+1);
        case '1  1'
            output(i) = -1*sine_table(bi2de(~bin_phase(1:ADDR_WIDTH-2))+1);

        case '0  1'
            output(i) = -1*sine_table(bi2de(bin_phase(1:ADDR_WIDTH-2))+1);

        case '1  0'
            output(i) = sine_table(bi2de(~bin_phase(1:ADDR_WIDTH-2))+1);
            
        otherwise
            num2str(bin_phase(ADDR_WIDTH-1:ADDR_WIDTH));
    end
           
    

end


