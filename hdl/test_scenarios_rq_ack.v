//------------------------------------------------------------------------------
// Universitatea Transilvania din Brasov
// Departamentul de Electronica si Calculatoare
// Proiect     : Laborator HDL
// Modul       : test_scenarios_rq_ack.v
---------------------------------------------------------------------------

module test_scenarios_rq_ack #(
parameter REQDATA_WIDTH = 'd16, // Numar de biti ai datelor transferate simultan 
                               // cu cererea, de la master la slave, 
                               // cand req=1 (maximum 32)
parameter ACKDATA_WIDTH = 'd16,  // Numar de biti ai datelor transferate simultan 
                               // cu confirmarea, de la slave la master, 
                               // cand ack=1 (maximum 32)
parameter IMEDIAT       = 'b1,
parameter DISPERSION    = 'd10
);

wire                             clk      ;
wire                             rst_n    ;
wire                             req      ;
wire                             ack      ;
wire       [REQDATA_WIDTH -1:0]  req_data ;
wire       [ACKDATA_WIDTH -1:0]  ack_data ;
wire                             valid    ;
wire       [ACKDATA_WIDTH -1:0]  result   ; 
wire                             start;

ck_rst_tb #(
.CK_SEMIPERIOD ('d10)
) i_ck_rst_tb (
.clk    (clk   ),
.rst_n  (rst_n )
);

master_rq_ack #(
    .REQDATA_WIDTH(REQDATA_WIDTH),
    .ACKDATA_WIDTH(ACKDATA_WIDTH),
    .IMEDIAT(IMEDIAT),
    .DISPERSION(DISPERSION)
) MASTER(
    .clk     (clk     ),  
    .rst_n   (rst_n   ),
    .start   (start   ),
    .req     (req     ),
    .ack     (ack     ),
    .req_data(req_data),  
    .ack_data(result)
);

inmultire_deplasare_dreapta #(
    .REQDATA_WIDTH(REQDATA_WIDTH),
    .ACKDATA_WIDTH(ACKDATA_WIDTH),
    .IMEDIAT(IMEDIAT),
    .DISPERSION(DISPERSION)
) SLAVE (
	.clk(clk),
	.rst_n(rst_n),
	.start(start),
    .req     (req     ),
    .ack     (ack     ),
    .req_data(req_data),  
    .ack_data(ack_data),
	.op1(req_data[REQDATA_WIDTH-1:REQDATA_WIDTH/2]),
	.op2(req_data[(REQDATA_WIDTH/2-1):0]),
	.result(result),
	.valid(valid)
);

endmodule // test_scenarios_rq_ack
