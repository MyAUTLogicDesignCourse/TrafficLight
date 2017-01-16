module Cr(myHold, CrowdSignal, Clk);
	output myHold;
	reg myHold;
	
	input CrowdSignal;
	input Clk;	
	
	reg [3:0] num;
	
	initial
		begin
			myHold = 0;
			num = 4'b0000;
		end
	
	
	always @(posedge Clk)
		if(CrowdSignal == 1)
			begin
				if(num == 4'b1010)	myHold = 1;
				else num = num + 4'b0001;
			end
		else
			begin
				num = 4'b0000;
				myHold = 0;
			end
endmodule

module CrTest;
  wire hold;
  
  reg crsig;
  
  reg clock;
  
  
  Cr c(hold, crsig, clock);
  
  initial begin
      clock = 1;
      crsig = 0;
	  
	  #1000 crsig = 1;
	  #1000 crsig = 0;
	  #12000 crsig = 1;
	  #1000 crsig = 0;
	  
    end
	
	always
		begin
		#1000 clock = ~clock;
		end
endmodule