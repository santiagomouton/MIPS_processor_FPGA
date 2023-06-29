`timescale 1ns / 1ps

module interface_uart
#(
    /** numero de bits - datos*/
    parameter NB_DATA   = 8,                        // cantidad de bits de la trama
    parameter NB_STATE  = 5                         // catnidad de estados de la interface
)
(
    /* DATO */
    input   wire                    wr,             // habilitador para leer la entrada provista por rx uart
    input   wire                    rd,             // habilitador para saber que se ha realizado la transmision correctamente
    input   wire    [NB_DATA - 1:0] in_rx,          // Se presenta los bit provistos por rx uart
    input   wire    [NB_DATA - 1:0] in_alu,         // Se presenta los bits provistos por la salida de la ALU (resultado de la alu)
    input   wire                    read_tx,
    /* SALIDA*/
    output  reg   [NB_DATA - 1:0] o_data_A,       // Se presenta el dato A a la alu
    output  reg    [NB_DATA - 1:0] o_data_B,       // Se presenta el dato B a la Alu
    output  reg    [NB_DATA - 3:0] o_data_Op,      // Se presenta el dato OP a la Alu
    output  wire    [NB_DATA - 1:0] o_tx,           // Se presenta el resutlado a tx
    output  reg                    empty,           // bit para avisar a tx que puede leer
    /* CLOCK */
    input wire                      clock,                                // clock que alimenta el sistema,
    input   wire                    reset

    /* DE PRUEBA */
//    output reg [NB_STATE-1 :0] VER_ESTADOS
);

  // estados de la fsm
  localparam [NB_STATE-1 :0]
        STATE_DATA_A    = 5'b00001,
        STATE_DATA_B    = 5'b00010,
        STATE_DATA_OP   = 5'b00100,
        STATE_READ_TX   = 5'b01000,
        STATE_TX        = 5'b10000;

    reg [NB_STATE - 1:0] current_state  ;
    reg [NB_STATE - 1:0] next_state     ;
    reg [NB_DATA - 1:0] o_tx_reg;
    reg [NB_DATA - 1:0] o_tx_next;
    reg [NB_DATA - 1:0]  data_A_reg;         // Se presenta el dato OP a la Alu
    reg [NB_DATA - 1:0]  data_A_next;         // Se presenta el dato OP a la Alu    reg [NB_DATA - 1:0]  data_A_reg;         // Se presenta el dato OP a la Alu
    reg [NB_DATA - 1:0]  data_B_reg;          
    reg [NB_DATA - 1:0]  data_B_next;         
    reg [NB_DATA - 3:0]  data_Op_reg;             
    reg [NB_DATA - 3:0]  data_Op_next;       

    reg empty_next  ;
    reg empty_reg     ;
   
   reg  write;
   reg  entrada;
   always @(posedge clock) 
   begin
        if (reset) begin
            write <= 0;
            entrada <= 0;
        end
        else if(wr)begin
            write <= 1'b1;
            entrada <= in_rx; 
        end
        else begin
            write <= 0;
        end
   end
   
   always @(posedge clock) 
   begin
        if (reset) begin
            current_state   <= STATE_DATA_A; 
            empty           <= 1;
            empty_reg       <= 1;
            o_tx_reg        <= 0;
            o_data_A        <= 0;
            o_data_B        <= 0;
            o_data_Op       <= 0;
            data_A_reg      <= 0;
            data_B_reg      <= 0;
            data_Op_reg     <= 0;
            
//            VER_ESTADOS<=STATE_DATA_A;
        end
        else begin
            current_state   <= next_state;
//            VER_ESTADOS<=current_state;
            empty_reg       <= empty_next;
            empty           <= empty_reg;
         
            o_tx_reg        <= o_tx_next;
            
            data_A_reg      <= data_A_next;
            data_B_reg      <= data_B_next;
            data_Op_reg     <= data_Op_next;
    
            o_data_A        <= data_A_reg;
            o_data_B        <= data_B_reg;
            o_data_Op       <= data_Op_reg;
        end
   end
   
   always @(*)
   begin
        next_state  = current_state;
        empty_next  = empty_reg;
        o_tx_next   = o_tx_reg;
        data_A_next = data_A_reg;
        data_B_next = data_B_reg;
        data_Op_next= data_Op_reg;
        
        case (current_state)
            STATE_DATA_A:
                begin
                    case(write)
                        1'b1: begin
                            data_A_next = in_rx;
                            next_state = STATE_DATA_B;
                        end
                        default: next_state = STATE_DATA_A;
                    endcase 
            
                empty_next = 1'b1;
                end
            // -------------------------------------------------------------------------- //
            STATE_DATA_B:
            begin
                case(write)
                    1'b1: begin
                        data_B_next = in_rx;
                        next_state = STATE_DATA_OP;
                    end
                    default: next_state = STATE_DATA_B;
                endcase 
                empty_next = 1'b1;
            end
            // -------------------------------------------------------------------------- //
            STATE_DATA_OP:
            begin
                case(write)
                    1'b1: begin
                        data_Op_next = in_rx[5:0];
                        next_state = STATE_READ_TX;
                    end 
                    default: next_state = STATE_DATA_OP;
                endcase
                empty_next = 1'b1;
            end
            // -------------------------------------------------------------------------- //
            STATE_READ_TX:
            begin
                o_tx_next     = in_alu;
                case(read_tx)
                    1'b1: begin
                        empty_next = 1'b1;
                        next_state = STATE_TX;
                    end
                    default: begin
                        next_state = STATE_READ_TX;
                        empty_next = 1'b0;
                    end
                endcase        
            end
            // -------------------------------------------------------------------------- //
            STATE_TX:
            begin
                case (rd)
                    1'b1: begin
                        next_state = STATE_DATA_A;
                    end
                    default: next_state = STATE_TX;
                endcase
            empty_next = 1'b1;
            end  
        endcase
   
   end
   assign o_tx = o_tx_reg;
//   assign o_data_A  = data_A_reg;
endmodule