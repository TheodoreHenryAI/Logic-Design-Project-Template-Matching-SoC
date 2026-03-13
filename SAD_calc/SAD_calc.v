`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/24/2025 10:53:24 AM
// Design Name: 
// Module Name: SAD_calc
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module SAD_calc #(
    parameter IW = 32,
    parameter IH = 32,
    parameter TW = 8,
    parameter TH = 8,
    parameter PixelBits = 8,
    parameter SADBits = 20
    )(
    input  wire clk,
    input  wire rst_n,
    input  wire start,
    input  wire [SADBits-1:0] threshold,
    
    output reg busy,
    output reg done,
    output reg match_valid,
    output reg [15:0] match_x,
    output reg [15:0] match_y,
    output reg [SADBits-1:0] match_sad
);

    localparam IMG_SIZE = IW * IH;
    localparam T_SIZE   = TW * TH;
    localparam X_MAX    = IW - TW + 1;
    localparam Y_MAX    = IH - TH + 1;

    // Memories (for simulation demo)
    reg [PixelBits-1:0] image_ram [0:IMG_SIZE-1];
    reg [PixelBits-1:0] template_ram [0:T_SIZE-1];

    // Initialize image + template
    integer i,j;
    initial begin
        // Fill image with constant value
        for (i=0; i<IMG_SIZE; i=i+1) image_ram[i] = 8'd50;
        // Template with a pattern
        for (i=0; i<T_SIZE; i=i+1) template_ram[i] = 8'd100 + (i % TW);
        // Insert template into image at (5,4)
        for (i=0; i<TH; i=i+1)
            for (j=0; j<TW; j=j+1)
                image_ram[(30+i)*IW + (50+j)] = template_ram[i*TW + j];
    end

    // FSM
    reg [15:0] cur_x, cur_y;
    reg [$clog2(T_SIZE+1)-1:0] idx;
    reg [SADBits-1:0] sad_acc;
    reg [1:0] state;
    localparam IDLE=0, SCAN=1, DONE_STATE=2;
    
    integer img_addr;
    reg [PixelBits-1:0] ip, tp;
    integer ti, tj;

    always @(posedge clk) begin
        if (!rst_n) begin
            busy <= 0; done <= 0; match_valid <= 0;
            cur_x <= 0; cur_y <= 0; idx <= 0; sad_acc <= 0;
            state <= IDLE;
        end else begin
            match_valid <= 0;
            case (state)
                IDLE: begin
                    if (start) begin
                        busy <= 1; done <= 0;
                        cur_x <= 0; cur_y <= 0;
                        idx <= 0; sad_acc <= 0;
                        state <= SCAN;
                    end
                end
                SCAN: begin
                    if (idx < T_SIZE) begin
                    ti = idx / TW;
                    tj = idx % TW;
                    img_addr = (cur_y + ti) * IW + (cur_x + tj);
                    ip = image_ram[img_addr];
                    tp = template_ram[idx];
                    if (ip >= tp) sad_acc <= sad_acc + (ip - tp);
                    else sad_acc <= sad_acc + (tp - ip);
                    idx <= idx + 1;
                   end else begin
                        if (sad_acc <= threshold) begin
                            match_valid <= 1;
                            match_x <= cur_x;
                            match_y <= cur_y;
                            match_sad <= sad_acc;
                        end
                        sad_acc <= 0;
                        idx <= 0;
                        if (cur_x + 1 < X_MAX) cur_x <= cur_x + 1;
                        else begin
                            cur_x <= 0;
                            if (cur_y + 1 < Y_MAX) cur_y <= cur_y + 1;
                            else begin
                                busy <= 0; done <= 1;
                                state <= DONE_STATE;
                            end
                        end
                    end
                end
                DONE_STATE: begin
                    if (!start) state <= IDLE;
                end
            endcase
        end
    end

endmodule

