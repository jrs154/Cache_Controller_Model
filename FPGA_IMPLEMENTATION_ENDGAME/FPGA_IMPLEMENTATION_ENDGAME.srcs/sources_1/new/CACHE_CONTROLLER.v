`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.10.2019 04:10:03
// Design Name: 
// Module Name: CACHE_CONTROLLER
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


module CACHE_CONTROLLER(address,clk,data,mode,output_data,hit1, hit2,Wait, clk2);

/********************************/
parameter no_of_address_bits=11;
parameter no_of_blkoffset_bits=2;
parameter byte_size=4;
/********************************/
parameter no_of_l2_ways=4;
parameter no_of_l2_ways_bits=2;
parameter no_of_l2_blocks=16;
parameter no_of_bytes_l2_block=16;
parameter l2_block_bit_size=64;
parameter no_of_l2_index_bits=4;
parameter no_of_l2_tag_bits=5;
/********************************/
parameter no_of_l1_blocks=8;
parameter no_of_bytes_l1_block=4;
parameter l1_block_bit_size=16;
parameter no_of_l1_index_bits=3;
parameter no_of_l1_tag_bits=6;
/********************************/
parameter no_of_main_memory_blocks=32; //2^5
parameter main_memory_block_size=16;
parameter no_of_bytes_main_memory_block=4;
parameter main_memory_byte_size=128;
/*************************************/
parameter l1_latency=1;
parameter l2_latency=2;
parameter main_memory_latency=5;
/*************************************/

/*************************************/

input [no_of_address_bits-1:0]address;
input clk;
input [byte_size-1:0]data;
input mode;
output reg[byte_size-1:0]output_data;
output reg hit1, hit2;
output reg Wait;
/********************************/

reg [no_of_address_bits-1:0]address_valid;
reg [no_of_address_bits-no_of_blkoffset_bits-1:0]main_memory_blk_id;
reg [no_of_l1_tag_bits-1:0]l1_tag;
reg [no_of_l1_index_bits-1:0]l1_index;
reg [no_of_l2_tag_bits-1:0]l2_tag;
reg [no_of_l2_index_bits-1:0]l2_index;
reg [no_of_blkoffset_bits-1:0]offset;

/********************************/
integer i;
integer j;
/********************************/
integer l2_check;
integer l2_check2;
integer l2_checka;
integer l2_check2a;
integer l2_mm_check;
integer l2_mm_check2;
integer l2_mm_iterator;
integer l2_iterator;

integer l1_l2_check;
integer l1_l2_check2;
integer l1_l2_checka;
integer l1_l2_check2a;
integer l1_l2_checkb;
integer l1_l2_check2b;
/********************************/
reg [no_of_l2_ways_bits-1:0]lru_value;
reg [no_of_l2_ways_bits-1:0]lru_value_dummy;

reg [no_of_l2_ways_bits-1:0]lru_value2;
reg [no_of_l2_ways_bits-1:0]lru_value_dummy2;

reg [no_of_l1_tag_bits-1:0]l1_evict_tag;
reg [no_of_l2_tag_bits-1:0]l1_to_l2_tag;
reg [no_of_l2_index_bits-1:0]l1_to_l2_index;

reg [no_of_l1_tag_bits-1:0]l1_evict_tag2;
reg [no_of_l2_tag_bits-1:0]l1_to_l2_tag2;
reg [no_of_l2_index_bits-1:0]l1_to_l2_index2;

reg [no_of_l1_tag_bits-1:0]l1_evict_tag3;
reg [no_of_l2_tag_bits-1:0]l1_to_l2_tag3;
reg [no_of_l2_index_bits-1:0]l1_to_l2_index3;

reg [no_of_l2_tag_bits-1:0]l2_evict_tag;
/********************************/
reg l1_to_l2_search;
reg l1_to_l2_search2;
reg l1_to_l2_search3;
/*********************************/
output reg clk2;
reg [31:0] counter=0;
/********************************/
reg [1:0]l2_delay_counter=0;
reg [3:0]main_memory_delay_counter=0;
reg dummy_hit;
reg is_L2_delay=0;
/********************************/
reg [1:0]l2_delay_counter_w=0;
reg [3:0]main_memory_delay_counter_w=0;
reg dummy_hit_w=0;
reg is_L2_delay_w=0;
/************************************/
reg [no_of_address_bits-1:0] stored_address;
reg stored_mode;
reg [byte_size-1:0]stored_data;
reg Ccount=0;

//MAIN_MEMORY main_memory_instance();
reg [main_memory_block_size-1:0]main_memory[0:no_of_main_memory_blocks-1];
initial 
begin: initialization_main_memory
    integer i;
    for (i=0;i<no_of_main_memory_blocks;i=i+1)
    begin
        main_memory[i]=i;
    end
end

//L1_CACHE_MEMORY l1_cache_memory_instance();
reg [l1_block_bit_size-1:0]l1_cache_memory[0:no_of_l1_blocks-1];
reg [no_of_l1_tag_bits-1:0]l1_tag_array[0:no_of_l1_blocks-1];
reg l1_valid[0:no_of_l1_blocks-1];

initial 
begin: initialization_l1
    integer i;
    for  (i=0;i<no_of_l1_blocks;i=i+1)
    begin
        l1_valid[i]=1'b0;
        l1_tag_array[i]=0;
    end
end

//L2_CACHE_MEMORY l2_cache_memory_instance();
reg [l2_block_bit_size-1:0]l2_cache_memory[0:no_of_l2_blocks-1];
reg [(no_of_l2_tag_bits*no_of_l2_ways)-1:0]l2_tag_array[0:no_of_l2_blocks-1];
reg [no_of_l2_ways-1:0]l2_valid[0:no_of_l2_blocks-1];
reg [no_of_l2_ways*no_of_l2_ways_bits-1:0]lru[0:no_of_l2_blocks-1];

initial 
begin: initialization
    integer i;
    for  (i=0;i<no_of_l2_blocks;i=i+1)
    begin
        l2_valid[i]=0;
        l2_tag_array[i]=0;
        lru[i]=8'b11100100;
    end
end


always @(posedge clk)
begin
    counter<=counter+1;
    if (counter==150000000)
    begin
        clk2<=~clk2;
        counter<=0;
    end
end


always @(posedge clk2)
begin
    if(Ccount==0 || Wait==0)
        begin
            stored_address=address;
            Ccount=1;
            stored_mode=mode;
            stored_data=data;
        end
    main_memory_blk_id=(stored_address>>no_of_blkoffset_bits)%no_of_main_memory_blocks;
    l2_index=(main_memory_blk_id)%no_of_l2_blocks;
    l2_tag=main_memory_blk_id>>no_of_l2_index_bits;
    l1_index=(main_memory_blk_id)%no_of_l1_blocks;
    l1_tag=main_memory_blk_id>>no_of_l1_index_bits;
    offset=stored_address%no_of_bytes_main_memory_block;
    if (stored_mode==0)
    begin
        $display("Check Started");
        /************************************************************************************************************************************/
        if (l1_valid[l1_index]&&l1_tag_array[l1_index]==l1_tag)
        begin
            //$display("Found in L1 Cache");
            output_data=l1_cache_memory[l1_index][((offset+1)*byte_size-1)-:byte_size];
            hit1=1;
            hit2=0;
            Wait=0;
        end
        /************************************************************************************************************************************/
        else
        begin
            /************************************************************************************************************************************/
            $display("Not Found in L1 Cache");
            hit1=0;
            if (l2_delay_counter<l2_latency && is_L2_delay==0)
            begin
                hit2=0;
                hit1=0;
                l2_delay_counter = l2_delay_counter+1;
                Wait=1;
            end
            else
            begin //c not found in l1
                l2_delay_counter=0;
                hit1=0;
                hit2=1;
                Wait=0;
                dummy_hit=0;
                for (l2_check=0;l2_check<no_of_l2_ways;l2_check=l2_check+1)
                begin
                    if (l2_valid[l2_index][l2_check]&&l2_tag_array[l2_index][((l2_check+1)*no_of_l2_tag_bits-1)-:no_of_l2_tag_bits]==l2_tag)
                    begin
                        dummy_hit=1;
                        l2_check2=l2_check;
                    end
                end
                if (dummy_hit==1) $display("Found in L2 Cache");
                else $display("Not Found in L2 Cache");
                if (dummy_hit==1)
                begin
                    lru_value2=lru[l2_index][((l2_check2+1)*no_of_l2_ways_bits-1)-:no_of_l2_ways_bits];
                    for (l2_iterator=0;l2_iterator<no_of_l2_ways;l2_iterator=l2_iterator+1)
                    begin
                       lru_value_dummy2=lru[l2_index][((l2_iterator+1)*no_of_l2_ways_bits-1)-:no_of_l2_ways_bits];
                       if (lru_value_dummy2>lru_value2)
                       begin
                           lru[l2_index][((l2_iterator+1)*no_of_l2_ways_bits-1)-:no_of_l2_ways_bits]=lru_value_dummy2-1;
                       end
                    end
                    lru[l2_index][((l2_check2+1)*no_of_l2_ways_bits-1)-:no_of_l2_ways_bits]=no_of_l2_ways-1;
                    
                    if (l1_valid[l1_index]==0)
                    begin
                        l1_cache_memory[l1_index]=l2_cache_memory[l2_index][((l2_check2+1)*l1_block_bit_size-1)-:l1_block_bit_size];
                        l1_valid[l1_index]=1;
                        l1_tag_array[l1_index]=l1_tag;
                        output_data=l1_cache_memory[l1_index][((offset+1)*byte_size-1)-:byte_size];
                        dummy_hit=1;
                    end
                    else
                    begin
                        l1_evict_tag2=l1_tag_array[l1_index];
                        l1_to_l2_tag2=l1_evict_tag2>>(no_of_l1_tag_bits-no_of_l2_tag_bits);
                        l1_to_l2_index2={l1_evict_tag2[no_of_l1_tag_bits-no_of_l2_tag_bits-1:0],l1_index};
                        l1_to_l2_search2=0;
                        for (l1_l2_checka=0;l1_l2_checka<no_of_l2_ways;l1_l2_checka=l1_l2_checka+1)
                        begin
                            if (l2_valid[l1_to_l2_index2][l1_l2_checka]&&l2_tag_array[l1_to_l2_index2][((l1_l2_checka+1)*no_of_l2_tag_bits-1)-:no_of_l2_tag_bits]==l1_to_l2_tag2)
                            begin
                                l1_to_l2_search2=1;
                                l1_l2_check2a=l1_l2_checka;
                            end
                        end
                        if (l1_to_l2_search2==1)
                        begin
                            //$display("found l1 eviction in l2");
                            l2_cache_memory[l1_to_l2_index2][((l1_l2_check2a+1)*l1_block_bit_size-1)-:l1_block_bit_size]=l1_cache_memory[l1_index];
                            //$display("%B",l2_cache_memory[l1_to_l2_index][((l1_l2_check2+1)*l1_block_bit_size-1)-:l1_block_bit_size]);
                            l1_cache_memory[l1_index]=l2_cache_memory[l2_index][((l2_check2+1)*l1_block_bit_size-1)-:l1_block_bit_size];
                            //$display("%B",l1_cache_memory[l1_index]);
                            l1_valid[l1_index]=1;
                            l1_tag_array[l1_index]=l1_tag;
                            //$display("%B",l1_tag_array[l1_index]);
                            output_data=l1_cache_memory[l1_index][((offset+1)*byte_size-1)-:byte_size];
                            dummy_hit=1;
                        end
                        else
                        begin
                            main_memory[{l1_evict_tag2,l1_index}]=l1_cache_memory[l1_index];
                            l1_cache_memory[l1_index]=l2_cache_memory[l2_index][((l2_check2+1)*l1_block_bit_size-1)-:l1_block_bit_size];
                            //$display("%B",l1_cache_memory[l1_index]);
                            l1_valid[l1_index]=1;
                            l1_tag_array[l1_index]=l1_tag;
                            //$display("%B",l1_tag_array[l1_index]);
                            output_data=l1_cache_memory[l1_index][((offset+1)*byte_size-1)-:byte_size];
                            dummy_hit=1;
                        end
                    end
                end
                /************************************************************************************************************************************/
                else
                begin //a not found in l2
                    hit1=0;
                    hit2=0;
                    Wait=1;
                    /************************************************************************************************************************************/
                    $display("Not found in L2 cache, Extracting from main memory");
                    
                    if (main_memory_delay_counter<main_memory_latency)
                    begin
                        hit1=0;
                        hit2=0;
                        main_memory_delay_counter = main_memory_delay_counter+1;
                        Wait=1;
                        is_L2_delay=1;
                    end
                    else
                    begin //d
                        main_memory_delay_counter=0;
                        is_L2_delay=0;
                        hit1=0;
                        hit2=0;
                        Wait=0;
                        l2_delay_counter=0;
                        main_memory_delay_counter=0;
                        for (l2_mm_check=0;l2_mm_check<no_of_l2_ways;l2_mm_check=l2_mm_check+1)
                        begin
                            if (lru[l2_index][((l2_mm_check+1)*no_of_l2_ways_bits-1)-:no_of_l2_ways_bits]==0)
                            begin
                                l2_mm_check2=l2_mm_check;
                            end
                        end
                        $display("%D",l2_mm_check2);
                        lru_value=lru[l2_index][((l2_mm_check2+1)*no_of_l2_ways_bits-1)-:no_of_l2_ways_bits];
                        //$display("%D",lru_value);
                        for (l2_mm_iterator=0;l2_mm_iterator<no_of_l2_ways;l2_mm_iterator=l2_mm_iterator+1)
                        begin
                            //$display("Initial");
                            lru_value_dummy=lru[l2_index][((l2_mm_iterator+1)*no_of_l2_ways_bits-1)-:no_of_l2_ways_bits];
                            //$display("%D",lru_value_dummy);
                           if ((lru[l2_index][((l2_mm_iterator+1)*no_of_l2_ways_bits-1)-:no_of_l2_ways_bits])>lru_value)
                           begin
                               //$display("bigger");
                               lru[l2_index][((l2_mm_iterator+1)*no_of_l2_ways_bits-1)-:no_of_l2_ways_bits]=lru_value_dummy-1;
                               lru_value_dummy=lru[l2_index][((l2_mm_iterator+1)*no_of_l2_ways_bits-1)-:no_of_l2_ways_bits];
                               //$display("%D",lru_value_dummy);
                           end
                        end
                        lru[l2_index][((l2_mm_check2+1)*no_of_l2_ways_bits-1)-:no_of_l2_ways_bits]=(no_of_l2_ways-1);
                        $display("%D",lru[l2_index]);
                        
                        if (l2_valid[l2_index][l2_mm_check2]==0)
                        begin
                            $display("Initially not present in l2");
                            l2_cache_memory[l2_index][((l2_mm_check2+1)*l1_block_bit_size-1)-:l1_block_bit_size]=main_memory[main_memory_blk_id];
                            $display("%B",l2_cache_memory[l2_index][((l2_mm_check2+1)*byte_size-1)-:byte_size]);
                            l2_valid[l2_index][l2_mm_check2]=1;
                            $display("%B",l2_valid[l2_index][l2_mm_check2]);
                            l2_tag_array[l2_index][((l2_mm_check2+1)*no_of_l2_tag_bits-1)-:no_of_l2_tag_bits]=l2_tag;
                            $display("%B",l2_tag_array[l2_index][((l2_mm_check2+1)*no_of_l2_tag_bits-1)-:no_of_l2_tag_bits]);
                            ///
                            if (l1_valid[l1_index]==0)
                            begin
                                $display("Initially not present in l1");
                                l1_cache_memory[l1_index]=main_memory[main_memory_blk_id];
                                $display("%B",l1_cache_memory[l1_index]);
                                l1_valid[l1_index]=1;
                                $display("%B",l1_valid[l1_index]);
                                l1_tag_array[l1_index]=l1_tag;
                                $display("%B",l1_tag_array[l1_index]);
                                output_data=l1_cache_memory[l1_index][((offset+1)*byte_size-1)-:byte_size];
                                dummy_hit=0; 
                            end
                            else
                            begin
                                $display("Initially present in l1");
                                l1_evict_tag=l1_tag_array[l1_index];
                                $display("%B",l1_evict_tag);
                                l1_to_l2_tag=l1_evict_tag>>(no_of_l1_tag_bits-no_of_l2_tag_bits);
                                $display("%B",l1_to_l2_tag);
                                l1_to_l2_index={l1_evict_tag[no_of_l1_tag_bits-no_of_l2_tag_bits-1:0],l1_index};
                                $display("%B",l1_to_l2_index);
                                l1_to_l2_search=0;
                                for (l1_l2_check=0;l1_l2_check<no_of_l2_ways;l1_l2_check=l1_l2_check+1)
                                begin
                                    if (l2_valid[l1_to_l2_index][l1_l2_check]&&l2_tag_array[l1_to_l2_index][((l1_l2_check+1)*no_of_l2_tag_bits-1)-:no_of_l2_tag_bits]==l1_to_l2_tag)
                                    begin
                                        l1_to_l2_search=1;
                                        l1_l2_check2=l1_l2_check;
                                    end
                                end
                                if (l1_to_l2_search==1)
                                begin
                                    $display("found l1 eviction in l2");
                                    l2_cache_memory[l1_to_l2_index][((l1_l2_check2+1)*l1_block_bit_size-1)-:l1_block_bit_size]=l1_cache_memory[l1_index];
                                    $display("%B",l2_cache_memory[l1_to_l2_index][((l1_l2_check2+1)*l1_block_bit_size-1)-:l1_block_bit_size]);
                                    l1_cache_memory[l1_index]=l2_cache_memory[l2_index][((l2_mm_check2+1)*l1_block_bit_size-1)-:l1_block_bit_size];
                                    $display("%B",l1_cache_memory[l1_index]);
                                    l1_valid[l1_index]=1;
                                    l1_tag_array[l1_index]=l1_tag;
                                    $display("%B",l1_tag_array[l1_index]);
                                    output_data=l1_cache_memory[l1_index][((offset+1)*byte_size-1)-:byte_size];
                                    dummy_hit=0;
                                end
                                else
                                begin
                                    main_memory[{l1_evict_tag,l1_index}]=l1_cache_memory[l1_index];
                                    l1_cache_memory[l1_index]=l2_cache_memory[l2_index][((l2_mm_check2+1)*l1_block_bit_size-1)-:l1_block_bit_size];
                                    $display("%B",l1_cache_memory[l1_index]);
                                    l1_valid[l1_index]=1;
                                    l1_tag_array[l1_index]=l1_tag;
                                    $display("%B",l1_tag_array[l1_index]);
                                    output_data=l1_cache_memory[l1_index][((offset+1)*byte_size-1)-:byte_size];
                                    dummy_hit=0;
                                end
                            end
                        end
                        /************************************************************************************************************************************/
                        else
                        begin
                            /************************************************************************************************************************************/
                            $display("Initially valid data present in l2");
                            l2_evict_tag=l2_tag_array[l2_index][((l2_mm_check2+1)*no_of_l2_tag_bits-1)-:no_of_l2_tag_bits];
                            main_memory[{l2_evict_tag,l2_index}]=l2_cache_memory[l2_index][((l2_mm_check2+1)*l1_block_bit_size-1)-:l1_block_bit_size];
                            
                            l2_cache_memory[l2_index][((l2_mm_check2+1)*l1_block_bit_size-1)-:l1_block_bit_size]=main_memory[main_memory_blk_id];
                            l2_valid[l2_index][l2_mm_check2]=1;
                            l2_tag_array[l2_index][((l2_mm_check2+1)*no_of_l2_tag_bits-1)-:no_of_l2_tag_bits]=l2_tag;
                            /************************************************************************************************************************************/
                            
                            if (l1_valid[l1_index]==0)
                            begin
                                l1_cache_memory[l1_index]=l2_cache_memory[l2_index][((l2_mm_check2+1)*l1_block_bit_size-1)-:l1_block_bit_size];
                                l1_valid[l1_index]=1;
                                l1_tag_array[l1_index]=l1_tag;
                                output_data=l1_cache_memory[l1_index][((offset+1)*byte_size-1)-:byte_size];
                                dummy_hit=0;
                            end
                            else
                            begin
                                l1_evict_tag3=l1_tag_array[l1_index];
                                l1_to_l2_tag3=l1_evict_tag3>>(no_of_l1_tag_bits-no_of_l2_tag_bits);
                                l1_to_l2_index3={l1_evict_tag3[no_of_l1_tag_bits-no_of_l2_tag_bits-1:0],l1_index};
                                l1_to_l2_search3=0;
                                for (l1_l2_checkb=0;l1_l2_checkb<no_of_l2_ways;l1_l2_checkb=l1_l2_checkb+1)
                                begin
                                    if (l2_valid[l1_to_l2_index3][l1_l2_checkb]&&l2_tag_array[l1_to_l2_index3][((l1_l2_checkb+1)*no_of_l2_tag_bits-1)-:no_of_l2_tag_bits]==l1_to_l2_tag3)
                                    begin
                                        l1_to_l2_search3=1;
                                        l1_l2_check2b=l1_l2_checkb;
                                    end
                                end
                                if (l1_to_l2_search3==1)
                                begin
                                    //$display("found l1 eviction in l2");
                                    l2_cache_memory[l1_to_l2_index3][((l1_l2_check2b+1)*l1_block_bit_size-1)-:l1_block_bit_size]=l1_cache_memory[l1_index];
                                    //$display("%B",l2_cache_memory[l1_to_l2_index][((l1_l2_check2+1)*l1_block_bit_size-1)-:l1_block_bit_size]);
                                    l1_cache_memory[l1_index]=l2_cache_memory[l2_index][((l2_mm_check2+1)*l1_block_bit_size-1)-:l1_block_bit_size];
                                    //$display("%B",l1_cache_memory[l1_index]);
                                    l1_valid[l1_index]=1;
                                    l1_tag_array[l1_index]=l1_tag;
                                    //$display("%B",l1_tag_array[l1_index]);
                                    output_data=l1_cache_memory[l1_index][((offset+1)*byte_size-1)-:byte_size];
                                    dummy_hit=0;
                                end
                                else
                                begin
                                    main_memory[{l1_evict_tag3,l1_index}]=l1_cache_memory[l1_index];
                                    l1_cache_memory[l1_index]=l2_cache_memory[l2_index][((l2_mm_check2+1)*l1_block_bit_size-1)-:l1_block_bit_size];
                                    //$display("%B",l1_cache_memory[l1_index]);
                                    l1_valid[l1_index]=1;
                                    l1_tag_array[l1_index]=l1_tag;
                                    //$display("%B",l1_tag_array[l1_index]);
                                    output_data=l1_cache_memory[l1_index][((offset+1)*byte_size-1)-:byte_size];
                                    dummy_hit=0;
                                end
                            end
                        end
                    end    
                end //a.
            end //c.      
        end
    end
    else
    begin
        output_data=0;
        if (l1_valid[l1_index]&& l1_tag_array[l1_index]==l1_tag)
        begin
            //$display("Found in L1 Cache");
            l1_cache_memory[l1_index][((offset+1)*byte_size-1)-:byte_size]=stored_data;
            Wait=0;
            hit1=1;
            hit2=0;
        end
        else
        begin  /*else not found in L1 starts here*/
            if((l2_delay_counter_w < l2_latency) && is_L2_delay_w==0)
            begin 
                l2_delay_counter_w=l2_delay_counter_w+1;
                hit1=0;
                hit2=0;
                Wait=1;
            end
            else
            begin /*searching in L2 and main memory starts here */
                l2_delay_counter_w=0;
                dummy_hit_w=0;
                hit1=0;
                hit2=0;
                for (l2_checka=0;l2_checka<no_of_l2_ways;l2_checka=l2_checka+1)
                begin
                    if (l2_valid[l2_index][l2_checka]&&l2_tag_array[l2_index][((l2_checka+1)*no_of_l2_tag_bits-1)-:no_of_l2_tag_bits]==l2_tag)
                    begin
                        dummy_hit_w=1;
                        hit2=1;
                        hit1=0;
                        Wait=0;
                        l2_cache_memory[l2_index][(l2_checka*l1_block_bit_size+(offset+1)*byte_size-1)-:byte_size]=stored_data;
                    end
                end
                if (dummy_hit_w==0) 
                begin
                    hit1=0;
                    hit2=0;
                    if(main_memory_delay_counter_w < main_memory_latency)
                    begin
                        main_memory_delay_counter_w=main_memory_delay_counter_w+1;
                        hit1=0;
                        hit2=0;
                        Wait=1;
                        is_L2_delay_w=1;
                    end
                    else
                    begin
                        main_memory_delay_counter_w=0;
                        hit1=0;
                        hit2=0;
                        Wait=0;
                        is_L2_delay_w=0;
                        main_memory[main_memory_blk_id][((offset+1)*byte_size-1)-:byte_size]=stored_data;
                    end
                end
            end /*searching in L2 and Main ends here */
        end    /*else not found in L1 ends here*/
    end
end
endmodule
