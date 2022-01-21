with AUnit; use AUnit;
with AUnit.Test_Suites;
with AUnit.Run;
with AUnit.Reporter.Text;

with GNAT.OS_Lib;
with Ada.Text_IO;
with Testsuite.Encode;
with Testsuite.Decode;
with Testsuite.Encode_Decode;

procedure Tests is
   Failures : Natural := 0;
begin

   for Kind in Testsuite.Encode.Encoder_Kind
   loop
      declare
         Suite : aliased AUnit.Test_Suites.Test_Suite;

         function Get_Suite return AUnit.Test_Suites.Access_Test_Suite
         is (Suite'Unchecked_Access);

         function Runner is new AUnit.Run.Test_Runner_With_Status (Get_Suite);

         Reporter : AUnit.Reporter.Text.Text_Reporter;
      begin

         Ada.Text_IO.New_Line;
         Ada.Text_IO.New_Line;
         Ada.Text_IO.Put_Line ("Testing " & Kind'Img & " encoder:");
         Testsuite.Encode.Set_Encoder_Kind (Kind);
         Testsuite.Encode.Add_Tests (Suite);

         Reporter.Set_Use_ANSI_Colors (True);

         if Runner (Reporter,
                    (Global_Timer     => True,
                     Test_Case_Timer  => True,
                     Report_Successes => True,
                     others           => <>))
           /= AUnit.Success
         then
            Failures := Failures + 1;
         end if;
      end;
   end loop;

   for Kind in Testsuite.Decode.Decoder_Kind
   loop
      declare
         Suite : aliased AUnit.Test_Suites.Test_Suite;

         function Get_Suite return AUnit.Test_Suites.Access_Test_Suite
         is (Suite'Unchecked_Access);

         function Runner is new AUnit.Run.Test_Runner_With_Status (Get_Suite);

         Reporter : AUnit.Reporter.Text.Text_Reporter;
      begin

         Ada.Text_IO.New_Line;
         Ada.Text_IO.New_Line;
         Ada.Text_IO.Put_Line ("Testing " & Kind'Img & " decoder:");
         Testsuite.Decode.Set_Decoder_Kind (Kind);
         Testsuite.Decode.Add_Tests (Suite);

         Reporter.Set_Use_ANSI_Colors (True);

         if Runner (Reporter,
                    (Global_Timer     => True,
                     Test_Case_Timer  => True,
                     Report_Successes => True,
                     others           => <>))
           /= AUnit.Success
         then
            Failures := Failures + 1;
         end if;
      end;
   end loop;

   for D_Kind in Testsuite.Decode.Decoder_Kind loop
      for E_Kind in Testsuite.Encode.Encoder_Kind loop
         declare
            Suite : aliased AUnit.Test_Suites.Test_Suite;

            function Get_Suite return AUnit.Test_Suites.Access_Test_Suite
            is (Suite'Unchecked_Access);

            function Runner is new AUnit.Run.Test_Runner_With_Status
              (Get_Suite);

            Reporter : AUnit.Reporter.Text.Text_Reporter;
         begin

            Ada.Text_IO.New_Line;
            Ada.Text_IO.New_Line;
            Ada.Text_IO.Put_Line ("Testing " & E_Kind'Img & " encoder" &
                                 " with " & D_Kind'Img & " decoder");
            Testsuite.Encode_Decode.Set_Kinds (E_Kind, D_Kind);
            Testsuite.Encode_Decode.Add_Tests (Suite);

            Reporter.Set_Use_ANSI_Colors (True);

            if Runner (Reporter,
                       (Global_Timer     => True,
                        Test_Case_Timer  => True,
                        Report_Successes => True,
                        others           => <>))
              /= AUnit.Success
            then
               Failures := Failures + 1;
            end if;
         end;
      end loop;
   end loop;

   if Failures /= 0 then
      GNAT.OS_Lib.OS_Exit (1);
   end if;
end Tests;
