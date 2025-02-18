/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_MAC_Accelerator_OnSachinSharma 
(
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

// All output pins must be assigned. If not used, assign to 0.
    assign uio_out[7:2]=0;
    assign uio_in [7:0]=0;
    assign uio_oe=0;
    assign ena =0;
    
    mac_vedicmul_adder DUT ( .a(ui_in[3:0]), .b(ui_in[7:4]), .C(uo_out), .X(ui_out[0]), .Y(ui_out[1]), .rst(rst_n), .clk(clk));
    
// List all unused inputs to prevent warnings
module mac_vedicmul_adder(input clk,rst, input [3:0] a,b,output [7:0] C,output [3:0] X,Y);
wire [7:0] S;
wire [7:0] vedic_out;           
wire co,ci;
assign ci= 0;
pipo_1 u1 (.din(a), .clk(clk),.rst(rst),.pipo_out_1(X));
pipo_1 u2 (.din(b), .clk(clk),.rst(rst),.pipo_out_1(Y));
vedic_4x4 u3(.a(a),.b(b),.result(vedic_out));
assign {co,S} = vedic_out + C + ci;
//Brent_kung_8_bit u4 (.A(vedic_out), .B(C), .Ci(ci), .S(S),.Co(co));
pipo U4(.din(S), .clk(clk),.rst(rst),.pipo_out(C));
endmodule
  ////////////////vedic_mul////////////
  module vedic_4x4(
a, b, result);
    input  [3:0] a,b;
    output [7:0] result;
    wire [7:0] result;

//wire [3:0] w;
wire [3:0] temp1;
wire [5:0] temp2;
wire [5:0] temp3;
wire [5:0] temp4;
wire [3:0] q0;
wire [3:0] q1;
wire [3:0] q2;
wire [3:0] q3;
wire [3:0] q4;
wire [5:0] q5;
wire [5:0] q6;

vedic_2x2 V1(a[1:0], b[1:0], q0[3:0]);
vedic_2x2 V2(a[3:2], b[1:0], q1[3:0]);
vedic_2x2 V3(a[1:0], b[3:2], q2[3:0]);
vedic_2x2 V4(a[3:2], b[3:2], q3[3:0]);

assign temp1= {2'b00, q0[3:2]};
adder4 A0(q1[3:0], temp1, q4);

assign temp2= {2'b00, q2[3:0]};
assign temp3= {q3[3:0], 2'b00};
adder6 A1(temp2, temp3, q5);
assign temp4= {2'b00, q4[3:0]};

adder6 A2(temp4, q5, q6);


assign result[1:0] = q0[1:0];
assign result[7:2] = q6[5:0];
   
endmodule

module vedic_2x2 (a, b, result);
    input [1:0] a,b;
    output [3:0] result;

    wire [3:0] w;
   
   
    assign result[0]= a[0]&b[0];
    assign w[0]     = a[1]&b[0];
    assign w[1]     = a[0]&b[1];
    assign w[2]     = a[1]&b[1];

    halfAdder H0(w[0], w[1], result[1], w[3]);
    halfAdder H1(w[2], w[3], result[2], result[3]);    
   
endmodule

module halfAdder(a,b,sum,carry);
    input a,b;
    output sum, carry;

assign sum   = a ^ b;
assign carry = a & b;

endmodule

module adder4(a,b,sum);

input [3:0] a,b;
output [3:0] sum;
wire [3:0] sum;

assign sum = a + b;

endmodule

module adder6(a,b,sum);

input [5:0] a,b;
output [5:0] sum;
wire [5:0] sum;

assign sum = a + b;
endmodule

///////registers//////////////////////////////////////////
module  pipo(din,clk,rst,pipo_out);
input [7:0] din;
input clk,rst;
output [7:0] pipo_out;
wire [7:0] din;
wire clk,rst;
reg [7:0] pipo_out;
always @(posedge clk or posedge rst)
begin
if(rst)
begin
pipo_out <= 8'b0;
end
else
begin
pipo_out <= din;
end
end  
endmodule


module  pipo_1(din,clk,rst,pipo_out_1);
input [3:0] din;
input clk,rst;
output [3:0] pipo_out_1;
wire [3:0] din;
wire clk,rst;
reg [3:0] pipo_out_1;
always @(posedge clk or posedge rst)
begin
if(rst)
begin
pipo_out_1 <= 4'b0;
end
else
begin
pipo_out_1 <= din;
end
end  
endmodule
