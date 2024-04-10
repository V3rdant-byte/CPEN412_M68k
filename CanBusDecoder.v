module CanBusDecoder (
	input unsigned [31:0] Address,
	input CanBusSelect_H,
	input AS_L,
	output reg CAN_Enable0_H,
	output reg CAN_Enable1_H
);

always@(*) begin

	CAN_Enable0_H = (Address[15:9] == 7'h00) && (CanBusSelect_H == 1) && (AS_L == 0);
	CAN_Enable1_H = (Address[15:9] == 7'h01) && (CanBusSelect_H == 1) && (AS_L == 0);
end
endmodule