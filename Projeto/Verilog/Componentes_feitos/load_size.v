module load_size(
    input wire  [1:0]   load_size_control //renomeei de selector pra ficar mais fácil,
    input wire  [31:0]  mdr_input,
    output reg  [31:0]  load_size_out; // to usando "reg" ao invés de wire pq logo em seguida to usando always (tem no slide que é pra ser assim)
);
    // tem que perguntar ao monitor "sempre" que o que acontecer isso aqui vai rodar :)
    @always @(alguma coisa que eu não sei o que :3 ) begin
        if(selector[1] == 0 && selector[0] == 0)
            load_size_out <= mdr_input; // LW
        else if(selector[1] == 0 && selector[0] == 1) begin
            load_size_out <= {{16{0}}, mdr_input[15:0]}; // LH
        end
        else
            load_size_out <= {{24{0}}, mdr_input[7:0]}; // LB
    end

endmodule