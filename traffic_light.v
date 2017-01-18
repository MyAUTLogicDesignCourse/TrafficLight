module AOs(numInp,loadOut,fiveFinished,muxOut,countFiveOut);
    //---------------------------— input
    input[6:0] numInp;
    //---------------------------— outputs
    output loadOut, fiveFinished, muxOut, countFiveOut;
    //---------------------------— wires
    wire z,h;
    //---------------------------— connections
    assign z = ~numInp[0] & ~numInp[1] & ~numInp[2] & ~numInp[3] & ~numInp[4] & ~numInp[5] & ~numInp[6];
    assign h = ~numInp[0] & ~numInp[1] & ~numInp[2] & numInp[3] & numInp[4] & numInp[5] & numInp[6];
    assign fiveFinished = ~numInp[0] & numInp[1] & numInp[2] & numInp[3] & numInp[4] & numInp[5] & numInp[6];
    or o1(countFiveOut,z,h);
    or o2 (loadOut , countFiveOut , fiveFinished);
    and a1(muxOut , ~fiveFinished , countFiveOut);
endmodule

module BCDConv(Q, A_L,A_H);
    input [6:0] Q;
  
    output  [3:0] A_L;
    output  [3:0] A_H;

    reg [3:0] A_L;
    reg [3:0] A_H;

    integer i;

  
    always @(Q)
        begin
            $display("QQQ%b",Q);
            A_L=4'b0000;
            A_H=4'b0000;
      
            for(i=6;i>=0;i=i-1)
                begin
                
                    if(A_L>=5) A_L =A_L +3;
                    if(A_H>=5) A_H =A_H +3;
      
                    A_H = A_H << 1;
                    A_H[0]= A_L[3];
                    A_L = A_L << 1;
                    A_L[0]= Q[i];

                end
                
                $display("LLL%b",A_L);
        end
endmodule

module DLatch (Q,D,control);
    output Q;
    input D, control;
    reg Q;
    always @ (control or D)  
        if (control == 1) Q = D;  //Same as: if (control)
endmodule

module TLatch (Q,control);
   output Q;
   input control;
   reg Q;
   initial 
      Q = 1;
   always @ (control)  
      if (control) 
        Q = ~Q;
endmodule

// Counter with mux
module myCounter (out,data0,data1,inp,up_down,load,hold,clk);
    //----------Output Ports------------?
    output [6:0] out;
    //------------Input Ports------------? 
    input hold, load;
    input [6:0] data0;
    input [6:0] data1;
    reg [6:0] data;
    input up_down, clk;
    input inp;
    //------------Internal Variables------?
    reg [6:0] out;
    //-------------Code Starts Here-------
    always @(posedge clk)
        begin
            if (load) 
                begin
                    if (inp)  data = data1;
                    else data = data0;
                    
                    out <= data;
                end
    else if (hold) // do nothing
      ;
    else if (up_down)
      out <= out + 1;
    else if (~(up_down))
      out <= out - 1;
  end
 endmodule
 
// Crowd checker module
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
                if(num == 4'b1010)  myHold = 1;
                else num = num + 4'b0001;
            end
        else
            begin
                num = 4'b0000;
                myHold = 0;
            end
endmodule


module InterfaceToLight
  (Number, // The number of timer
   UDState, // State of UpDown number
  PoliceA,
  PoliceB,
  BCD_H,
  BCD_L,
  LightA,
  LightB);
  input [6:0]Number;
  input UDState;
  input PoliceA;
  input PoliceB;
  
  output [3:0]BCD_H;
  output [3:0]BCD_L;
  output LightA;
  output LightB;
  
  wire [3:0]BCD_H;
  wire [3:0]BCD_L;
  reg LightA;
  reg LightB;
  
  reg [6:0]CorrectNum;
  
  BCDConv conv(CorrectNum, BCD_L, BCD_H);
  
  always @(Number or UDState or PoliceA or PoliceB)
    begin
      if(PoliceA == 1)
        begin
          CorrectNum = 7'b0000000;
          LightA = 1;
          LightB = 0;
        end
      
      else if(PoliceB == 1)
        begin
          CorrectNum = 7'b0000000;
          LightA = 0;
          LightB = 1;
        end
        
      else
        begin
          if(Number > 120)
            begin
              CorrectNum = 7'b0000000;
              LightA = 0;
              LightB = 0;
            end
          else
            begin
              if(Number == 30)
                begin
                  if(UDState == 1)
                    begin
                      CorrectNum = 7'b0000000;
                      LightA = 1;
                      LightB = 0;
                    end
                  else
                    begin
                      CorrectNum = 7'b00011110;
                      LightA = 0;
                      LightB = 1;
                    end
                end
              else if(Number > 30)
                begin
                  CorrectNum = 120 - Number;
                  LightA = 1;
                  LightB = 0;
                end
              else    // Number < 30
                begin
                  CorrectNum = Number;
                  LightA = 0;
                  LightB = 1;
                end
            end
        end
    end
endmodule

module Test;
  wire hold;
  reg [6:0] data0;
  reg [6:0] data1;
  reg clock;
  wire load, inp;
  wire fiveFinished;
  wire countFive;
  wire [6:0] out;
  wire qd, qt;
  wire cd;
  wire CFive;
  wire updown;
  wire crowdSignal;
  reg reset;
  wire LightA,LightB;
  reg PoA,PoB,A_Traffic,B_Traffic;
  wire [3:0]NumH;
  wire [3:0]NumL;
  assign updown = qt | qd;
  initial begin
      //crowdSignal = 0;
      //PoA = 0;
      //PoB = 0;
      data0 = 7'd30;
      data1 = 7'd121;
      reset = 1;
      clock = 1;
	  PoA=0;	
	  PoB=0;	
	  A_Traffic=0;	
	  B_Traffic=0;	// A_Time_H -> 9	A_Time_L -> 0	B_Time_H -> 9	B_Time_L -> 5	A_Light -> 1	B_Light -> 0
	  
      #(200)
      reset = 0;
      
		//Test Case For Project1///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

		#500		reset=1;	PoA=0;	PoB=0;	A_Traffic=0;	B_Traffic=0;	// A_Time_H -> 9	A_Time_L -> 0	B_Time_H -> 9	B_Time_L -> 5	A_Light -> 1	B_Light -> 0


		#500		reset=0;
		// Releasing Reset Timers Should Start Counting Down


		#15000	PoB=1;
		#100		PoB=0;

		// During this period:  A_Light = 0 B_Light=1 A_Time=FF B_Time=FF

		#15000	reset=1;	PoA=0;	PoB=0;

		// Resetting 

		#500		reset=0;	PoA=0;	PoB=0;

		// Counting down

		#10000	reset=0;	PoA=1;	PoB=0;
		#100		PoA=0;




		////////////////////////////////////////////////////////////////END OF BASIC FEATURES 


		////////////////////////////////////////////////////////////////START OF TESTING FEATURES_2

		#500 reset=1;		PoA=0;	PoB=0; 	A_Traffic = 0;	B_Traffic = 0;

		// Resetting

		#500 reset=0;

		// Counting Down

		#500   A_Traffic = 1;



		#1500  A_Traffic = 0;



		#100   A_Traffic = 1;// Timer Starts Again
		#2000  A_Traffic = 0;
		#10000 B_Traffic = 1;

		#1500  B_Traffic = 0;
		#100   B_Traffic = 1;// Timer Starts Again
//////////////////////////////////////////////////////////////////////////////////////////////
    end
	or o10(crowdSignal, A_Traffic, B_Traffic);
    Cr cr(hold, crowdSignal,clock);
    AOs ao(out, load, fiveFinished, inp, countFive);
    assign inpu = inp & ~reset;
    assign loadu = load | reset;
    myCounter c(out,data0,data1,inpu,updown,loadu,hold,clock);
    or #7 o1(CFive, countFive,countFive);
    or o2(cd, fiveFinished,countFive);
    DLatch dl(qd, CFive, cd);
    TLatch tl(qt, fiveFinished);
    InterfaceToLight i(out, updown, PoA, PoB, NumH, NumL,LightA,LightB);
  always
    begin
      #100
       clock = ~clock;
    end
endmodule