function sample =readSineTable(sine_table, index,ADDR_WIDTH,quarter)
if quarter==true
    if index > 2^ADDR_WIDTH
        index = mod(index,2^ADDR_WIDTH);
    end
    bin_phase = de2bi(index,ADDR_WIDTH,'right-msb');
    MSB = bin_phase(ADDR_WIDTH);
    MSB_minus_1  = bin_phase(ADDR_WIDTH-1);
    switch num2str(bin_phase(ADDR_WIDTH-1:ADDR_WIDTH))
        case '0  0'
            sample = sine_table(bi2de(bin_phase(1:ADDR_WIDTH-2))+1);
        case '1  1'
            sample = -1*sine_table(bi2de(~bin_phase(1:ADDR_WIDTH-2))+1);
            
        case '0  1'
            sample = -1*sine_table(bi2de(bin_phase(1:ADDR_WIDTH-2))+1);
            
        case '1  0'
            sample = sine_table(bi2de(~bin_phase(1:ADDR_WIDTH-2))+1);
            
        otherwise
            num2str(bin_phase(ADDR_WIDTH-1:ADDR_WIDTH));
    end
else
    sample = sine_table(index+1);
end

