// PIPELINED PROCESSOR

module processor_arm #(parameter N = 64)
                            (input logic CLOCK_50, reset,
                            output logic [N-1:0] DM_writeData, DM_addr,
                            output logic DM_writeEnable,
                            input	logic dump,
                            output logic [10:0] current_inst,
                            output logic Zero_Flag,
                            output logic [1:0] branchOp,
                            output logic [N-1:0] PCBranch_db,
                            output logic [1:0] fwA_db,fwB_db,
                            output logic hazard);
                            
    logic [31:0] q;		
    logic [3:0] AluControl;
    logic reg2loc, regWrite, AluSrc, memtoReg, memRead, memWrite, Branch, BranchZero;
    logic [N-1:0] DM_readData, IM_address;  //DM_addr, DM_writeData
    logic DM_readEnable; //DM_writeEnable
    logic [10:0] instr;
    logic IF_ID_writeEnable;
    assign current_inst = instr;

    controller 		c 			(.instr(instr), 
                                 .AluControl(AluControl), 
                                 .reg2loc(reg2loc), 
                                 .regWrite(regWrite), 
                                 .AluSrc(AluSrc), 
                                 .Branch(Branch),
                                 .BranchZero(BranchZero),
                                 .memtoReg(memtoReg), 
                                 .memRead(memRead), 
                                 .memWrite(memWrite));
                                                        
                    
    datapath #(64) dp 		(.reset(reset), 
                             .clk(CLOCK_50), 
                             .reg2loc(reg2loc), 
                             .AluSrc(AluSrc), 
                             .AluControl(AluControl), 
                             .Branch(Branch), 
                             .BranchZero(BranchZero),
                             .memRead(memRead),
                             .memWrite(memWrite), 
                             .regWrite(regWrite), 
                             .memtoReg(memtoReg), 
                             .IM_readData(q), 
                             .DM_readData(DM_readData), 
                             .IM_addr(IM_address), 
                             .DM_addr(DM_addr), 
                             .DM_writeData(DM_writeData), 
                             .DM_writeEnable(DM_writeEnable), 
                             .DM_readEnable(DM_readEnable),
                             .Zero_Flag(Zero_Flag),
                             .branchOp(branchOp),
                             .PCBranch_db(PCBranch_db),
                             .fwA_db(fwA_db),
                             .fwB_db(fwB_db),
                             .hazard(hazard),
                             .IF_ID_writeEnable(IF_ID_writeEnable)
                             );				
             
                    
    imem 				instrMem (.addr(IM_address[7:2]),
                                  .q(q));
                                    
    
    dmem 				dataMem 	(.clk(CLOCK_50), 
                                     .memWrite(DM_writeEnable), 
                                     .memRead(DM_readEnable), 
                                     .address(DM_addr[8:3]), 
                                     .writeData(DM_writeData), 
                                     .readData(DM_readData), 
                                     .dump(dump)); 							
         
                            
    flopre #(11)		IF_ID_TOP(.clk(CLOCK_50),
                              .reset(reset),
                              .enable(IF_ID_writeEnable),
                              .d(q[31:21]), 
                              .q(instr));
     
endmodule
