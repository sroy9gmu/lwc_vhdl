----------------------------------------------------------------------------------
-- Company: George Mason University
-- Engineer: Sunanda Roy
-- 
-- Create Date: 11/27/2021 10:06:20 PM
-- Design Name: 
-- Module Name: EK_tb - Behavioral
-- Project Name: SAEAES LWC
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.EK_pkg.all;
use work.AES_pkg.all;

entity EK_tb is
end EK_tb;

-------------------------------------------------------------------------------
--! @brief  Architecture definition of EK_tb
-------------------------------------------------------------------------------

architecture sim of EK_tb is
    signal rst          : std_logic := '0';
    signal clk          : std_logic := '0';
    signal init         : std_logic := '0';
    signal is_lambda     : std_logic := '0';
    signal ad_start : std_logic := '0';
    signal ad_last : std_logic := '0';
    signal ptct_start : std_logic := '0';
   
    signal start, ready, done, done_init : std_logic;
    signal dih, dil, doh, dol  : std_logic_vector(63 downto 0);
    signal key : std_logic_vector(127 downto 0);

    signal   enClock    : boolean := TRUE;
    constant numTVs     : integer := 1;
    signal do: std_logic_vector(EK_BLOCK_SIZE - 1 downto 0);
  
    type tTestVector is record
        N    : std_logic_vector(NONCE_SIZE - 1 downto 0);
        A    : std_logic_vector(DIH_MAX_SIZE - 1 downto 0);
        key    : std_logic_vector(EK_BLOCK_SIZE - 1 downto 0);
        EKsa    : std_logic_vector(EK_BLOCK_SIZE - 1 downto 0);
        Last_sa    : std_logic_vector(EK_BLOCK_SIZE - 1 downto 0);
        IV    : std_logic_vector(EK_BLOCK_SIZE - 1 downto 0);
        EKIV    : std_logic_vector(EK_BLOCK_SIZE - 1 downto 0);
        PT  : std_logic_vector(EK_BLOCK_SIZE - 1 downto 0);
        exp_CT  : std_logic_vector(EK_BLOCK_SIZE - 1 downto 0);
        exp_Tag  : std_logic_vector(EK_BLOCK_SIZE - 1 downto 0);
    end record tTestVector;
    
    type tTestVectorArray is array (0 to numTVs-1) of tTestVector; 
    
    constant TV_0 : tTestVector := (
        N         => (others => '0'),
        A         => (others => '0'),
        key       => (others => '0'),
        EKsa      => (others => '0'), 
        Last_sa    => (others => '0'),
        IV         => (others => '0'),
        EKIV      => (others => '0'), 
        PT      => (others => '0'),
        exp_CT     => (others => '0'),
        exp_Tag     => (others => '0')
    );
      
    --! Currently only 1 test vector can be verified at a time due to timing constraints.     
    constant tv : tTestVectorArray := (
        --! From SAEAES implementation TV 1
--        0 => (  N         => x"000102030405060708090A0B0C0D0E",
--                A         => (others => '0'),
--                key       => x"000102030405060708090A0B0C0D0E0F",
--                EKsa      => x"F13BD64EF89A3E7164479C0EEB78DE7B",
--                Last_sa   => (others => '0'), 
--                IV        => x"F13AD44DFC9F38766C4E9605E775D078",
--                EKIV      => x"593DBB7788993B124AC20200DF77D99D",
--                PT      => (others => '0'),
--                exp_CT    => x"33F72C1AECA709664CABAA3D9EAE02D1",
--                exp_Tag     => (others => '0')),
        
        --! From SAEAES implementation TV 17        
--        0 => (  N         => x"000102030405060708090A0B0C0D0E",
--                A         => padEK_DATA(x"000102030405060708090A0B0C0D0E0F", DIH_MAX_SIZE),
--                key       => x"000102030405060708090A0B0C0D0E0F", 
--                EKsa      => x"9DC28337D6D3B4BE380DD72D8E5CC1A5",
--                Last_sa   => x"7AB7C3818991C7D3EBA0B81394B44702",
--                IV        => x"7AB6C1828D94C1D4E3A9B21898B94901",
--                EKIV      => x"60134B47F4FFECFA288C2C3884CEA1FA", 
--                PT      => (others => '0'),
--                exp_CT    => x"1AD923A7B577F998CFDC6FACEAA9081D",
--                exp_Tag     => (others => '0')),
                
        --! From SAEAES implementation TV 529        
--        0 => (  N         => x"000102030405060708090A0B0C0D0E",
--                A         => (others => '0'),
--                key       => x"000102030405060708090A0B0C0D0E0F", 
--                EKsa      => x"F13BD64EF89A3E7164479C0EEB78DE7B",
--                Last_sa   => (others => '0'), 
--                IV        => x"F13AD44DFC9F38766C4E9605E775D078",
--                EKIV      => x"593DBB7788993B124AC20200DF77D99D",
--                PT        => x"000102030405060708090A0B0C0D0E0F",
--                exp_CT    => x"593CB9748C9C3D15798CA8B952CC8DCB",
--                exp_Tag    => x"A575997A44F665A5CAF5713A1F5D1384"),
                
        --! From SAEAES implementation TV 545        
        0 => (  N         => x"000102030405060708090A0B0C0D0E",
                A         => padEK_DATA(x"000102030405060708090A0B0C0D0E0F", DIH_MAX_SIZE),
                key       => x"000102030405060708090A0B0C0D0E0F", 
                EKsa      => x"9DC28337D6D3B4BE380DD72D8E5CC1A5",
                Last_sa   => x"7AB7C3818991C7D3EBA0B81394B44702",
                IV        => x"7AB6C1828D94C1D4E3A9B21898B94901",
                EKIV      => x"60134B47F4FFECFA288C2C3884CEA1FA", 
                PT        => x"000102030405060708090A0B0C0D0E0F",
                exp_CT    => x"60124944F0FAEAFDC38FE8BA5B48EE8C",
                exp_Tag    => x"6A3117A9112807527D2B6D7CB0BC269A"),
        
        others => TV_0
    );


begin   
    uut:
    entity work.EK
    port map (
        rst       => rst,
        clk       => clk,
        start     => start,
        ready     => ready,
        init      => init,
        done      => done,
        done_init => done_init,
        dinh       => dih,
        dinl       => dil,
        douth      => doh,
        doutl      => dol,
        key       => key,
        is_lambda => is_lambda,
        ad_start => ad_start,
        ad_last => ad_last,
        ptct_start => ptct_start
    );
    
    u_ctrl: entity work.EK_Control(Behavioral)
    port map ( 
              clk => clk, 
              rst => rst,
              ad_start => ad_start,
              ptct_start => ptct_start
    );
    
    pClk:
    process
    begin
        while enClock = TRUE loop
            wait for clk_period/2;
            clk <= not clk;
        end loop;
        wait;
    end process;

    
    pSimHash:
    process
        variable is_init         : boolean;
        variable cnt_test        : integer := 0;
        variable cnt_test_failed : integer := 0;
        variable cnt_test_passed : integer := 0;
        variable padhigh, padlow : std_logic_vector(EK_BUS_SIZE - 1 downto 0);
        variable do_tmp : std_logic_vector(EK_BLOCK_SIZE - 1 downto 0);
        variable doh_tmp : std_logic_vector(EK_BUS_SIZE - 1 downto 0);
        variable dol_tmp : std_logic_vector(EK_BUS_SIZE - 1 downto 0);
        variable a, p : integer := 0;
        variable ad_left, ad_right, pt_left, pt_right: integer;
        
    begin  
        for i in 0 to numTVs-1 loop
            report "    Initializing circuit...";
            rst   <= '1';
            start <= '0';
            wait for clk_period;
            rst   <= '0';
            wait for 4*clk_period;
            report "    Performing test...";
            
            padhigh := tv(i).N(NONCE_SIZE - 1 downto NONCE_SIZE - EK_BUS_SIZE);
            padlow := tv(i).N(NONCE_SIZE - EK_BUS_SIZE - 1 downto 0) & x"03";
            ad_left := tv(i).A'length - 1;
            ad_right := ad_left - DIH_BLOCK_SIZE + 1;
            pt_left := tv(i).PT'length - 1;
            pt_right := pt_left - DIH_BLOCK_SIZE + 1;
            a := getNumBlocks(tv(i).A, DIH_BLOCK_SIZE); 
            p := getNumBlocks(tv(i).PT, DIH_BLOCK_SIZE);           
                     
            report "    [Start] SAEAES - Test Vector: " & integer'image(i + 1);
            report "    Number of AD blocks = " & integer'image(a);
            report "    Number of PT blocks = " & integer'image(p);
            
            if i = 0 then                       --! First key
                is_init := TRUE;
            elsif tv(i).key /= tv(i-1).key then --! Subsequent key is the same
                is_init := TRUE;
            else
                is_init := FALSE;
            end if;

            --! Perform initialization
            if is_init = TRUE then
                report "    [Start] Key Setup: " & time'image(now);
                init <= '1';
                key  <= tv(i).key;
                report "    [Start] Test number: " & integer'image(i);
                wait for clk_period;
                init <= '0';
                key  <= (others => '0');
                wait until done_init = '1';
                wait for clk_period*3/4;
                report "    [Done] Key Setup: " & time'image(now);
            end if;

            report "    [Start] Hash: " & time'image(now);
            --! Calculate Hash 
            if a = 0 then
                --!base case
                dih <= (others => '0');
                is_lambda <= '1'; 
            else
                dih <= tv(i).A(ad_left downto ad_right);
                is_lambda <= '0';
            end if;
            dil <= (others => '0');
            start   <= '1';
            ad_start <= '1';                    
            wait for clk_period;
            start   <= '0';            

            wait until done = '1';
            wait for clk_period*3/4;
            if a = 0 then 
                do_tmp := doh & dol;
                if do_tmp = tv(i).EKsa then
                    report "    Encryption of sa passed";
                else
                    report "    Encryption of sa failed: actual = " & to_hstring(do_tmp);
                end if;
            else
                do <= doh & dol;
                if do = tv(i).EKsa then
                    report "    Encryption of sa passed";
                else
                    report "    Encryption of sa failed: actual = " & to_hstring(do);
                end if;
                do_tmp := do;
            end if;
            
            --! Yet to be verified for more than 2 consecutive blocks of AD.
            if a > 2 then 
                for j in 1 to a - 2 loop            
                    dih <= doh xor tv(i).A(ad_left downto ad_right); 
                    dil <= dol; 
                    ad_start <= not ad_start;             
                    start   <= '1';            
                    wait for clk_period;
                    start   <= '0';
    
                    wait until done = '1';
                    wait for clk_period*3/4;
                    ad_left := ad_left - DIH_BLOCK_SIZE;
                    ad_right := ad_right - DIH_BLOCK_SIZE;                                
                end loop;
            end if; 
            
            if a > 0 then
                ad_left := ad_left - DIH_BLOCK_SIZE;
                ad_right := ad_right - DIH_BLOCK_SIZE;        
                dih <= do_tmp(EK_BLOCK_SIZE - 1 downto EK_BUS_SIZE) xor tv(i).A(ad_left downto ad_right);
                dil <= do_tmp(EK_BUS_SIZE - 1 downto 0) xor lpad1;                
                wait for clk_period;
                ad_last <= not ad_start;
                ad_start <= ad_last;
                wait for clk_period;            
                start   <= '1';            
                wait for clk_period;
                start   <= '0';

                wait until done = '1';
                wait for clk_period;
                do_tmp := doh & dol;
                if do_tmp = tv(i).Last_sa then
                    report "    Calculation of last sa passed";
                else
                    report "    Calculation of last sa failed: actual = " & to_hstring(do);
                end if;   
            end if;                  
                
            --! Feeding nonce segments 
            if a > 1 then           
                do_tmp := doh & dol;
            end if;
            do_tmp := do_tmp xor (padhigh & padlow);
            if do_tmp = tv(i).IV then
                report "    Generation of IV passed";
            else
                report "    Generation of IV failed: actual = " & to_hstring(do_tmp);
            end if; 
            report "    [End] Hash: " & time'image(now);         
                            
            dih <= do_tmp(EK_BLOCK_SIZE - 1 downto EK_BUS_SIZE);         
            dil <= do_tmp(EK_BUS_SIZE - 1 downto 0);          
            wait for clk_period;
            ad_start <= not ad_start;
            report "    [Start] Encryption: " & time'image(now);
            start   <= '1';            
            wait for clk_period;
            start   <= '0';

            wait until done = '1';
            wait for clk_period*3/4;
            do <= doh & dol;            
            if a = 0 then
                if do = tv(i).EKIV then
                    report "    Encryption of IV passed";                    
                else
                    report "    Encryption of IV failed: actual = " & to_hstring(do);
                end if; 
            else                
                dih <= doh;
                dil <= dol;
                wait for clk_period;--! Need to reflect chanages                
                start   <= '1';
                ptct_start <= '1';        
                wait for clk_period;
                start   <= '0';    
                wait until done = '1';            
                wait for clk_period; 
                
                if doh & dol = tv(i).EKIV then
                    report "    Encryption of IV passed";                    
                else
                    report "    Encryption of IV failed: actual = " & to_hstring(do);
                end if;
                doh_tmp := doh;
                dol_tmp := dol;
            end if;
            
            --! Obtain input for getting ciphertext as output
            if p > 0 then
                dih <= doh xor tv(i).PT(EK_BLOCK_SIZE - 1 downto EK_BUS_SIZE);
                dil <= dol;
                --! Verifying output 
                wait for clk_period;
                if dih = tv(i).exp_CT(EK_BLOCK_SIZE - 1 downto EK_BUS_SIZE) then
                    report "    Ciphertext high calculation passed";
                else
                    report "    Ciphertext high calculation failed: actual = " & to_hstring(dih);
                end if;
                
                --! Yet to be verified for more than 2 consecutive blocks of PT.
                if p > 2 then 
                    for j in 1 to p - 2 loop            
                        dih <= doh xor tv(i).PT(pt_left downto pt_right); 
                        dil <= dol; 
                        ptct_start <= not ptct_start;             
                        start   <= '1';            
                        wait for clk_period;
                        start   <= '0';
        
                        wait until done = '1';
                        wait for clk_period*3/4;
                        pt_left := pt_left - DIH_BLOCK_SIZE;
                        pt_right := pt_right - DIH_BLOCK_SIZE;                                
                    end loop;
                end if; 
                
                --! As per simulation waveform, desired output is achieved in the second 'done' signal.
                ptct_start <= not ptct_start;
                start   <= '1';    
                wait for clk_period;
                start   <= '0';                        
                wait until done = '1';            
                wait for clk_period*3/4;
                
                ptct_start <= not ptct_start;
                start   <= '1';    
                wait for clk_period;
                start   <= '0';                        
                wait until done = '1';            
                wait for clk_period*3/4;

                dih <= doh xor tv(i).PT(EK_BUS_SIZE - 1 downto 0);
                dil <= dol xor lpad1;
                
                --! Verifying output 
                wait for clk_period;
                if dih = tv(i).exp_CT(EK_BUS_SIZE - 1 downto 0) then
                    report "    Ciphertext low calculation passed";
                else
                    report "    Ciphertext low calculation failed: actual = " & to_hstring(dih);
                end if;
                
                --! Calculate tag. As per simulation waveform, desired output is achieved in the second 'done' signal.
                ptct_start <= not ptct_start;
                start   <= '1';    
                wait for clk_period;
                start   <= '0';                        
                wait until done = '1';            
                wait for clk_period*3/4;
                
                ptct_start <= not ptct_start;
                start   <= '1';    
                wait for clk_period;
                start   <= '0';                        
                wait until done = '1';            
                wait for clk_period*3/4;
                
                if doh & dol = tv(i).exp_Tag then
                    report "    Tag calculation passed";
                else
                    report "    Tag calculation failed: actual = " & to_hstring(dih);
                end if;
            else
                doh_tmp := padEK_DATA(ONE, EK_BUS_SIZE);
                dih <= doh xor doh_tmp;
                dil <= dol xor lpad2;
                wait for clk_period*3/4;--! Needed to reflect chanages  
                  
                --! As per simulation waveform, desired output is achieved in the second 'done' signal.            
                start   <= '1';
                ptct_start <= not ptct_start;    
                wait for clk_period*3/4;
                start   <= '0';    
                wait until done = '1';            
                wait for clk_period*3/4;
                
                start   <= '1';
                ptct_start <= not ptct_start;    
                wait for clk_period*3/4;
                start   <= '0';    
                wait until done = '1';            
                wait for clk_period*3/4;
                
                --! Verifying output 
                if doh & dol = tv(i).exp_CT then
                    report "    Ciphertext calculation passed";
                else
                    report "    Ciphertext calculation failed: actual = " & to_hstring(doh & dol);
                end if;
            end if; 
            
            report "    [End] Encryption: " & time'image(now);
            
            report "    [Start] Decryption: " & time'image(now);            
         
            if p > 0 then
                if a = 0 then
                    doh_tmp := do(EK_BLOCK_SIZE - 1 downto EK_BUS_SIZE) xor tv(i).exp_CT(EK_BLOCK_SIZE - 1 downto EK_BUS_SIZE);
                else
                    doh_tmp := doh_tmp xor tv(i).exp_CT(EK_BLOCK_SIZE - 1 downto EK_BUS_SIZE);
                end if;
                if doh_tmp = tv(i).PT(EK_BLOCK_SIZE - 1 downto EK_BUS_SIZE) then 
                    report "    Plaintext high calculation passed";
                else
                    report "    Plaintext high calculation failed: actual = " & to_hstring(doh_tmp);
                end if;
                
                 --! Yet to be verified for more than 2 consecutive blocks of PT.
                if p > 2 then 
                    for j in 1 to p - 2 loop            
                        dih <= doh xor tv(i).PT(pt_left downto pt_right); 
                        dil <= dol; 
                        ptct_start <= not ptct_start;             
                        start   <= '1';            
                        wait for clk_period;
                        start   <= '0';
        
                        wait until done = '1';
                        wait for clk_period*3/4;
                        pt_left := pt_left - DIH_BLOCK_SIZE;
                        pt_right := pt_right - DIH_BLOCK_SIZE;                                
                    end loop;
                end if;
                
                dih <= tv(i).exp_CT(EK_BLOCK_SIZE - 1 downto EK_BUS_SIZE);
                if a = 0 then
                    dil <= do(EK_BUS_SIZE - 1 downto 0);
                else
                    dil <= dol_tmp;
                end if;
                wait for clk_period;
                
                ptct_start <= not ptct_start;
                start   <= '1';    
                wait for clk_period;
                start   <= '0';                        
                wait until done = '1';            
                wait for clk_period*3/4;
                
                ptct_start <= not ptct_start;
                start   <= '1';    
                wait for clk_period;
                start   <= '0';                        
                wait until done = '1';            
                wait for clk_period*3/4;

                doh_tmp := doh xor tv(i).exp_CT(EK_BUS_SIZE - 1 downto 0);
                wait for clk_period;
                
                if doh_tmp = tv(i).PT(EK_BUS_SIZE - 1 downto 0) then 
                    report "    Plaintext low calculation passed";
                else
                    report "    Plaintext low calculation failed: actual = " & to_hstring(doh_tmp);
                end if;
                
                dih <= tv(i).exp_CT(EK_BUS_SIZE - 1 downto 0);
                dil <= dol xor lpad1;                
                wait for clk_period;
                
                --! As per simulation waveform, desired output is achieved in the second 'done' signal.
                ptct_start <= not ptct_start;
                start   <= '1';    
                wait for clk_period*3/4;
                start   <= '0';                        
                wait until done = '1';            
                wait for clk_period*3/4;
                
                ptct_start <= not ptct_start;
                start   <= '1';    
                wait for clk_period;
                start   <= '0';                        
                wait until done = '1';            
                wait for clk_period*3/4;
                
                if doh & dol = tv(i).exp_Tag then 
                    report "    Decryption tag calculation passed";
                else
                    report "    Decryption tag calculation failed: actual = " & to_hstring(doh & dol);
                end if;                
            end if;

            report "    [End] Decryption: " & time'image(now);     
            
            --! Reset control signals 
            start   <= '1';
            ad_start <= '0';            
            ptct_start <= '0';
            wait for clk_period;
            start   <= '0';    
            wait until done = '1';            
            wait for clk_period;
        end loop;
    end process;

    pCounter:
    process(clk)
        variable is_proc        : boolean;
        variable is_init        : boolean;
        variable procCounter    : integer;
        variable initCounter    : integer;
    begin
        --! Check start signal at the rising edge
        if rising_edge(clk) then
            if init = '1' then
                initCounter := 0;
                is_init     := TRUE;
            elsif start = '1' then
                procCounter := 0;
                is_proc     := TRUE;
            end if;
        end if;

        --! Check output status at the falling edge
        if falling_edge(clk) then
            if is_proc = TRUE then
                procCounter := procCounter + 1;
                if done = '1' then
                    is_proc := FALSE;
                    report "    [info] Processing latency = " & integer'image(procCounter);
                end if;
            end if;
            if is_init = TRUE then
                initCounter := initCounter + 1;
                if done_init = '1' then
                    is_init := FALSE;
                    report "    [info] Initialization latency = " & integer'image(initCounter);
                end if;
            end if;
        end if;
    end process;

end architecture sim;