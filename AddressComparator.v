module AddressComparaotr (
		input [22:0] AddressBus,
        input [22:0] TagData,
        output reg Hit_H
);
always@(*) begin
    if (AddressBus == TagData) 
        Hit_H = 1'b1;
    else
        Hit_H = 1'b0;
end
endmodule