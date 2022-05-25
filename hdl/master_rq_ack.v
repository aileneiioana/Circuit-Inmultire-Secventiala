//------------------------------------------------------------------------------
// Universitatea Transilvania din Brasov
// Departamentul de Electronica si Calculatoare
// Proiect     : Laborator HDL
// Modul       : master_rq_ack

//`define WITH_TASK

module master_rq_ack #(
parameter REQDATA_WIDTH = 'd16, // Numar de biti ai datelor transferate simultan 
                               // cu cererea, de la master la slave, 
                               // cand req=1 (maximum 32)
parameter ACKDATA_WIDTH = 'd16, // Numar de biti ai datelor transferate simultan 
                               // cu confirmarea, de la slave la master, 
                               // cand ack=1 (maximum 32)
parameter IMEDIAT       = 'b1, // 1=cereri exclusiv back-to-back
parameter DISPERSION    = 'd10 // dispersia timpului dintre doua cereri
                               // (relevant doar daca IMEDIAT = 0)
)(
input                             clk       , // semnal de ceas, 
                                              // activ pe frontul crescator
input                             rst_n     , // reset asincron activ 0
output reg                        req       , // cerere activa in 1
input                             ack       , // confirmare, puls activ 1
output reg                             start     ,
output reg  [REQDATA_WIDTH -1:0]  req_data  , // date transferate de la 
                                              // master la slave 
input       [ACKDATA_WIDTH -1:0]  ack_data    // date transferate de la 
                                              // slave la master 
);

integer   delay   ; // timp intre cerere si confirmare (in perioade de tact)

initial begin
  req <= 1'b0;
  req_data <= 'bx;
  start <=1'b0;
  @(negedge rst_n);
  @(posedge rst_n);
  @(posedge clk);
  
  while(1) begin
    
    req <= 1'b1;
    
    req_data <='b00000111_00001010; //op1=7   op2=10
    start <=1'b1;
    repeat(2)@(posedge clk);
    start <=1'b0;
    
    
    while (~ack) @(posedge clk);
    req  <= 'b0;
    if (~IMEDIAT) begin
      delay = $random % DISPERSION;
      if (delay != 'd0) begin
        req <= 1'b0;
        req_data <= 'bx;
        repeat (delay) @(posedge clk);  
      end
    end
  end
end    


endmodule // master_rq_ack
