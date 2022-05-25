
//-----------------------------------------------------
// Universitatea Transilvania din Brasov
// Proiect     : Limbaje de descriere hardware
// Autor       : Ailenei Ioana
// Data        : Mai 16, 2022
//---------------------------------------------------------------------------------------
// Descriere   : Circuit de inmultire secventiala cu deplasare la dreapta
//-----------------------------------------------------------------

module inmultire_deplasare_dreapta #(
parameter REQDATA_WIDTH = 'd16, // Numar de biti ai datelor transferate simultan 
                               // cu cererea, de la master la slave, 
                               // cand req=1 (maximum 32)
parameter ACKDATA_WIDTH = 'd16, // Numar de biti ai datelor transferate simultan 
                               // cu confirmarea, de la slave la master, 
                               // cand ack=1 (maximum 32)
parameter IMEDIAT       = 'b0, // 1=cereri exclusiv back-to-back
parameter DISPERSION    = 'd25 // dispersia timpului dintre doua cereri ,(relevant doar daca IMEDIAT = 0)
)(
input [REQDATA_WIDTH/2-1:0] op1  ,
input [REQDATA_WIDTH/2-1:0] op2  ,
input                             req       , // cerere activa in 1
output reg                        ack       , // confirmare, puls activ 1
input       [REQDATA_WIDTH -1:0]  req_data  , // date transferate de la 
                                              // master la slave 
output reg  [ACKDATA_WIDTH -1:0]  ack_data,   // date transferate de la 
                                              // slave la master 
input             clk ,
input             rst_n,
input             start,

output reg [2*REQDATA_WIDTH/2-1:0] result,
output reg               valid 
);
reg       req_d   ; // cerere intarziata
reg       ack_d   ; // confirmare intarziata
integer   delay   ; // timp intre cerere si confirmare (in perioade de tact)

//starile automatului

parameter WAIT   = 3'b000;
parameter LOAD   = 3'b001;
parameter VERIFY = 3'b010;
parameter SUM    = 3'b011;
parameter SHIFT  = 3'b100;

//numarator
reg[REQDATA_WIDTH/2-1:0] NUM;
wire num = (NUM == REQDATA_WIDTH/2-1);

reg [2:0]       STATUS;
reg [REQDATA_WIDTH/2:0]   P;
reg [REQDATA_WIDTH/2-1:0] A;
reg [REQDATA_WIDTH/2-1:0] B;

always @(posedge clk or negedge clk) begin
	ack_d <= ack;
end
always @(posedge clk or negedge clk) begin
	req_d <= req;
end

always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		ack <=1'b0;
		ack_data <='bx;
	end
end

always @(*) begin
	if(result > 'b0) begin
		ack <=1'b1;
		ack_data <=result;
	end
	else begin
		ack <=1'b0;
		ack_data<='bx;
	end
end

//cale de control
always @(posedge clk or negedge rst_n)
if (~rst_n)
     NUM <= 0;
	     else
	         if (STATUS == WAIT)
		         NUM <= 0;
			         else
				         if (STATUS == SHIFT)
					             NUM <= NUM+1;
						  
always @(posedge clk or negedge rst_n) begin
if (~rst_n)
      valid <= 0;
	     else begin
	         valid <= (STATUS == WAIT);

		 	end
end
			
//tranzitiile automatului  
always @(posedge clk or negedge rst_n)
if (~rst_n)
     STATUS <= WAIT;
	     else
	         case(STATUS)
		         WAIT: if (start)
			                STATUS <= LOAD;
					             else
					                 STATUS <= WAIT;
				
			     LOAD: STATUS <= VERIFY;
			      
			     VERIFY: if (A[0] == 1)
			                 STATUS <= SUM;
						         else
						             STATUS <= SHIFT;
						
			     SUM: STATUS <= SHIFT;
			 
			     SHIFT: if (num)
			                 STATUS <= WAIT;
						         else
						             STATUS <= VERIFY;
		 endcase
		 

//cale de date

//il incarc pe op1 in registrul A si pe op2 in registrul B

always @(posedge clk or negedge rst_n)
if (~rst_n)
   A <= 0;
   else if (STATUS == LOAD)
             A <= op1;
			 else if (STATUS == SHIFT)
			          A <= {P[0],A[REQDATA_WIDTH/2-1:1]}; // MSB A = LSB P

always @(posedge clk or negedge rst_n)
if (~rst_n)
    B <= 0;
	else if (STATUS == LOAD)
	         B <= op2;
			 
always @(posedge clk or negedge rst_n)
if (~rst_n)
     P <= 0;
	 else if (STATUS == SUM)
	          P <= P + op2;
			  else if (STATUS == SHIFT)
			         P <= {1'b0, P[REQDATA_WIDTH/2-1:1]}; // MSB P = 0
					 
always @(posedge clk or negedge rst_n)
if (~rst_n)
     result <= 0;
	 else if (valid) begin
	         result <= 0;
	 end
			 else if (STATUS == WAIT) begin
			         result <= {P[REQDATA_WIDTH/2-1:0], A[REQDATA_WIDTH/2-1:0]}; 

					 end//MSB de result este P, iar LSB de  result este A
					 
endmodule