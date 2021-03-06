/**
 * This ADC interface provides an serial to parallel interface for
 * a ADC chip. 
 * After reset the interface just loops collecting 1 reading from the
 * ADC chip every 16 sclk cycles and stores them into its internal memory
 * at one of 4 address spaces.  The data will be refreshed every 4x16 (64 cycles)
 * So a consumer should be setup to read the data before its gone. 
 */
module adc_interface  (
  addr, data,
  din, dout,
  sclk, rst);

input [2:0]    addr;
output [11:0]  data;
input          sclk;
input          rst;
input          din;
output         dout;
      
reg [11:0]    data;
reg           dout;

reg [3:0]     sclk_count;
reg [2:0]     dout_addr; 
wire          addr_inc;
reg  [11:0]   din_ff;
reg  [11:0]   data_ram [0:7];

assign addr_inc = (sclk_count == 4'b0001);

/* Handle clock counting */
always @ (posedge sclk or posedge rst)
  if (rst) 
    sclk_count <= 4'b0000;
  else
    sclk_count <= sclk_count + 1'b1;

/* Handle address incrementing to cycle through reading
   bytes from the ADC device input pins */
always @ (posedge sclk)
  if (rst) 
    dout_addr <= 2'b00;
  else
	if (sclk_count == 4'b1111)
    dout_addr <= dout_addr + 1'b1;
   
/* Serial DOUT, based on sclk count, send the current address bit MSB first. 
 * Note: since we are only selecting 4 Analog ports we just have 2 bits to send
 * during the 2nd clock cycle we went a zero by defualt. 
 */
always @ (negedge sclk)
  case (sclk_count)
	 4'd2: dout = dout_addr[2];
    4'd3: dout = dout_addr[1];
    4'd4: dout = dout_addr[0];
    default: dout = 1'b0;
  endcase
     
/* DeSerialize DIN, use a shift register to move DIN into a 12 bit register during
 * clock cycles 4 -> 15
 */
always @ (posedge sclk) begin
  if (rst)
      din_ff <= 12'd0;
  else 
  if (sclk_count < 4'b0011)
		din_ff <= 12'd0;
	 else
		din_ff <= {din_ff[10:0],din};
end
     
/* Return static ram on read interface
 * Write shift register to static ram on first clock
 */ 
always @ (negedge sclk) begin
  if (sclk_count == 4'b0000) begin
     data_ram[dout_addr] <= din_ff;
  end
  data <= data_ram[addr];
end

endmodule