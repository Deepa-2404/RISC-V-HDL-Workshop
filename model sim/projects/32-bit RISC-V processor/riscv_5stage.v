
`timescale 1ns/1ps

module riscv_5stage(
    input wire clk,
    input wire reset
);

    // Memories and registers
    reg [31:0] pc;
    reg [31:0] instruction_mem [0:63];
    reg [31:0] data_mem [0:63];
    reg [31:0] registers [0:31];

    integer i;

    //================================================
    // PIPELINE REGISTERS
    //================================================

    // IF/ID
    reg [31:0] if_id_instruction;
    reg [31:0] if_id_pc;

    // ID/EX
    reg [31:0] id_ex_pc;
    reg [31:0] id_ex_a, id_ex_b;
    reg [31:0] id_ex_imm;
    reg [4:0] id_ex_rs1, id_ex_rs2, id_ex_rd;
    reg [2:0] id_ex_funct3;
    reg [6:0] id_ex_funct7, id_ex_opcode;
    reg id_ex_regwrite;
    reg id_ex_memread;
    reg id_ex_memwrite;
    reg id_ex_alusrc;

    // EX/MEM
    reg [31:0] ex_mem_alu;
    reg [31:0] ex_mem_store;
    reg [4:0] ex_mem_rd;
    reg ex_mem_regwrite;
    reg ex_mem_memread;
    reg ex_mem_memwrite;

    // MEM/WB
    reg [31:0] mem_wb_data;
    reg [4:0] mem_wb_rd;
    reg mem_wb_regwrite;

    //================================================
    // INSTRUCTION DECODE
    //================================================

    wire [6:0] opcode = if_id_instruction[6:0];
    wire [4:0] rd = if_id_instruction[11:7];
    wire [2:0] funct3 = if_id_instruction[14:12];
    wire [4:0] rs1 = if_id_instruction[19:15];
    wire [4:0] rs2 = if_id_instruction[24:20];
    wire [6:0] funct7 = if_id_instruction[31:25];

    wire [31:0] read_data1 =
        (rs1 == 0) ? 0 : registers[rs1];

    wire [31:0] read_data2 =
        (rs2 == 0) ? 0 : registers[rs2];

    // Immediate generation
    reg [31:0] imm;

    always @(*) begin
        case(opcode)

            7'b0010011,
            7'b0000011:
                imm = {{20{if_id_instruction[31]}},
                       if_id_instruction[31:20]};

            7'b0100011:
                imm = {{20{if_id_instruction[31]}},
                       if_id_instruction[31:25],
                       if_id_instruction[11:7]};

            7'b1100011:
                imm = {{19{if_id_instruction[31]}},
                       if_id_instruction[31],
                       if_id_instruction[7],
                       if_id_instruction[30:25],
                       if_id_instruction[11:8],
                       1'b0};

            default: imm = 0;

        endcase
    end

    // Write-back forwarding to decode stage
    wire [31:0] decode_a =
        (mem_wb_regwrite && mem_wb_rd != 0 &&
         mem_wb_rd == rs1) ?
         mem_wb_data : read_data1;

    wire [31:0] decode_b =
        (mem_wb_regwrite && mem_wb_rd != 0 &&
         mem_wb_rd == rs2) ?
         mem_wb_data : read_data2;

    // Control signals
    reg dec_regwrite;
    reg dec_memread;
    reg dec_memwrite;
    reg dec_alusrc;
    reg use_rs1, use_rs2;

    always @(*) begin

        dec_regwrite = 0;
        dec_memread = 0;
        dec_memwrite = 0;
        dec_alusrc = 0;
        use_rs1 = 0;
        use_rs2 = 0;

        case(opcode)

            7'b0110011: begin
                dec_regwrite = 1;
                use_rs1 = 1;
                use_rs2 = 1;
            end

            7'b0010011: begin
                dec_regwrite = 1;
                dec_alusrc = 1;
                use_rs1 = 1;
            end

            7'b0000011: begin
                dec_regwrite = 1;
                dec_memread = 1;
                dec_alusrc = 1;
                use_rs1 = 1;
            end

            7'b0100011: begin
                dec_memwrite = 1;
                dec_alusrc = 1;
                use_rs1 = 1;
                use_rs2 = 1;
            end

            7'b1100011: begin
                use_rs1 = 1;
                use_rs2 = 1;
            end

        endcase
    end

    //================================================
    // HAZARD DETECTION
    //================================================

    wire stall =
        id_ex_memread && id_ex_rd != 0 &&
        ((use_rs1 && id_ex_rd == rs1) ||
         (use_rs2 && id_ex_rd == rs2));

    //================================================
    // FORWARDING UNIT
    //================================================

    reg [31:0] forward_a, forward_b;

    always @(*) begin

        forward_a = id_ex_a;
        forward_b = id_ex_b;

        // Forward from MEM/WB
        if(mem_wb_regwrite && mem_wb_rd != 0 &&
           mem_wb_rd == id_ex_rs1)
            forward_a = mem_wb_data;

        if(mem_wb_regwrite && mem_wb_rd != 0 &&
           mem_wb_rd == id_ex_rs2)
            forward_b = mem_wb_data;

        // Newer EX/MEM result has priority
        if(ex_mem_regwrite && ex_mem_rd != 0 &&
           ex_mem_rd == id_ex_rs1 &&
           !ex_mem_memread)
            forward_a = ex_mem_alu;

        if(ex_mem_regwrite && ex_mem_rd != 0 &&
           ex_mem_rd == id_ex_rs2 &&
           !ex_mem_memread)
            forward_b = ex_mem_alu;

    end

    //================================================
    // STAGE 3: EXECUTE
    //================================================

    wire [31:0] alu_b =
        id_ex_alusrc ? id_ex_imm : forward_b;

    reg [31:0] alu_result;

    always @(*) begin

        alu_result = 0;

        case(id_ex_opcode)

            7'b0110011: begin

                case(id_ex_funct3)

                    3'b000:
                        if(id_ex_funct7 == 7'b0100000)
                            alu_result = forward_a - alu_b;
                        else
                            alu_result = forward_a + alu_b;

                    3'b111:
                        alu_result = forward_a & alu_b;

                    3'b110:
                        alu_result = forward_a | alu_b;

                    default: alu_result = 0;

                endcase
            end

            7'b0010011,
            7'b0000011,
            7'b0100011:
                alu_result = forward_a + alu_b;

            default: alu_result = 0;

        endcase
    end

    // Branch control
    wire branch_taken =
        (id_ex_opcode == 7'b1100011) &&
        (id_ex_funct3 == 3'b000) &&
        (forward_a == forward_b);

    wire [31:0] branch_target =
        id_ex_pc + id_ex_imm;

    //================================================
    // STAGE 4: MEMORY ACCESS
    //================================================

    wire [31:0] memory_data =
        data_mem[ex_mem_alu[7:2]];

    //================================================
    // PIPELINE EXECUTION
    //================================================

    always @(posedge clk or posedge reset) begin

        if(reset) begin

            pc <= 0;

            if_id_instruction <= 32'h00000013;
            if_id_pc <= 0;

            id_ex_pc <= 0;
            id_ex_a <= 0;
            id_ex_b <= 0;
            id_ex_imm <= 0;
            id_ex_rs1 <= 0;
            id_ex_rs2 <= 0;
            id_ex_rd <= 0;
            id_ex_funct3 <= 0;
            id_ex_funct7 <= 0;
            id_ex_opcode <= 0;

            id_ex_regwrite <= 0;
            id_ex_memread <= 0;
            id_ex_memwrite <= 0;
            id_ex_alusrc <= 0;

            ex_mem_alu <= 0;
            ex_mem_store <= 0;
            ex_mem_rd <= 0;
            ex_mem_regwrite <= 0;
            ex_mem_memread <= 0;
            ex_mem_memwrite <= 0;

            mem_wb_data <= 0;
            mem_wb_rd <= 0;
            mem_wb_regwrite <= 0;

            for(i=0;i<32;i=i+1)
                registers[i] <= 0;

            for(i=0;i<64;i=i+1)
                data_mem[i] <= 0;

        end
        else begin

            //========================================
            // STAGE 5: WRITE BACK
            //========================================

            if(mem_wb_regwrite && mem_wb_rd != 0)
                registers[mem_wb_rd] <= mem_wb_data;

            registers[0] <= 0;

            //========================================
            // STAGE 4: MEMORY ACCESS
            //========================================

            if(ex_mem_memwrite)
                data_mem[ex_mem_alu[7:2]] <= ex_mem_store;

            mem_wb_rd <= ex_mem_rd;
            mem_wb_regwrite <= ex_mem_regwrite;

            if(ex_mem_memread)
                mem_wb_data <= memory_data;
            else
                mem_wb_data <= ex_mem_alu;

            //========================================
            // STAGE 3: EXECUTE
            //========================================

            ex_mem_alu <= alu_result;
            ex_mem_store <= forward_b;
            ex_mem_rd <= id_ex_rd;
            ex_mem_regwrite <= id_ex_regwrite;
            ex_mem_memread <= id_ex_memread;
            ex_mem_memwrite <= id_ex_memwrite;

            //========================================
            // BRANCH FLUSH
            //========================================

            if(branch_taken) begin

                pc <= branch_target;

                if_id_instruction <= 32'h00000013;
                if_id_pc <= 0;

                id_ex_regwrite <= 0;
                id_ex_memread <= 0;
                id_ex_memwrite <= 0;
                id_ex_alusrc <= 0;
                id_ex_opcode <= 0;
                id_ex_rd <= 0;

            end

            //========================================
            // LOAD-USE HAZARD STALL
            //========================================

            else if(stall) begin

                // Hold PC and IF/ID
                // Insert bubble into ID/EX

                id_ex_regwrite <= 0;
                id_ex_memread <= 0;
                id_ex_memwrite <= 0;
                id_ex_alusrc <= 0;
                id_ex_opcode <= 0;
                id_ex_rd <= 0;

            end

            else begin

                //====================================
                // STAGE 1: INSTRUCTION FETCH
                //====================================

                if_id_instruction <=
                    instruction_mem[pc[7:2]];

                if_id_pc <= pc;
                pc <= pc + 4;

                //====================================
                // STAGE 2: INSTRUCTION DECODE
                //====================================

                id_ex_pc <= if_id_pc;
                id_ex_a <= decode_a;
                id_ex_b <= decode_b;
                id_ex_imm <= imm;

                id_ex_rs1 <= rs1;
                id_ex_rs2 <= rs2;
                id_ex_rd <= rd;

                id_ex_funct3 <= funct3;
                id_ex_funct7 <= funct7;
                id_ex_opcode <= opcode;

                id_ex_regwrite <= dec_regwrite;
                id_ex_memread <= dec_memread;
                id_ex_memwrite <= dec_memwrite;
                id_ex_alusrc <= dec_alusrc;

            end
        end
    end

endmodule
