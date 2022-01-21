with System.Storage_Elements; use System.Storage_Elements;

with AUnit.Assertions; use AUnit.Assertions;

with AAA.Strings;

with Test_Utils; use Test_Utils;

package body Testsuite.Encode.Basic_Tests is
   pragma Style_Checks ("gnatyM120-s");

   ----------------
   -- Basic_Test --
   ----------------

   procedure Basic_Test (Fixture         : in out Encoder_Fixture;
                         Input, Expected :        Storage_Array)
   is
      Expected_Frame : constant Data_Frame := From_Array (Expected);
   begin

      Fixture.Encoder.Clear;

      for Elt of Input loop
         Fixture.Encoder.Receive (Elt);
      end loop;
      Fixture.Encoder.End_Of_Frame;
      Fixture.Encoder.End_Of_Test;

      Assert (Fixture.Encoder.Number_Of_Frames = 1,
              "Unexpected number of output frames: " &
                Fixture.Encoder.Number_Of_Frames'Img & ASCII.LF &
                "Input   : " & Image (Input));

      declare
         Output_Frame : constant Data_Frame := Fixture.Encoder.Get_Frame (0);
      begin
         if Output_Frame /= Expected_Frame then
            declare
               Diff : constant AAA.Strings.Vector :=
                 Test_Utils.Diff (From_Array (Expected),
                                  Fixture.Encoder.Get_Frame (0));
            begin
               Assert (False,
                       "Input   : " & Image (Input) & ASCII.LF &
                         Diff.Flatten (ASCII.LF));
            end;
         end if;
      end;

   end Basic_Test;

   ---------------
   -- Test_Zero --
   ---------------

   procedure Test_Zero (Fixture : in out Encoder_Fixture) is
   begin
      --  Basic tests from the wikipedia COBS page...

      Basic_Test (Fixture,
                  Input    => (0 => 0),
                  Expected => (1, 1, 0));

      Basic_Test (Fixture,
                  Input    => (0, 0),
                  Expected => (1, 1, 1, 0));

      Basic_Test (Fixture,
                  Input    => (1, 2, 0, 3),
                  Expected => (3, 1, 2, 2, 3, 0));
   end Test_Zero;

   ----------------
   -- Test_1_254 --
   ----------------

   procedure Test_1_254 (Fixture : in out Encoder_Fixture) is
      Long_Input : Storage_Array (0 .. 255);
   begin
      for X in Long_Input'Range loop
         Long_Input (X) := Storage_Element (X);
      end loop;

      Basic_Test (Fixture,
                  Input    => Long_Input (1 .. 254),
                  Expected =>
                    (0 => 16#FF#) & Long_Input (1 .. 254) & (0 => 16#00#));
   end Test_1_254;

   ----------------
   -- Test_0_254 --
   ----------------

   procedure Test_0_254 (Fixture : in out Encoder_Fixture) is
      Long_Input : Storage_Array (0 .. 255);
   begin
      for X in Long_Input'Range loop
         Long_Input (X) := Storage_Element (X);
      end loop;

      Basic_Test (Fixture,
                  Input    => Long_Input (0 .. 254),
                  Expected =>
                    (16#01#, 16#FF#) & Long_Input (1 .. 254) & (0 => 16#00#));
   end Test_0_254;

   ----------------
   -- Test_1_255 --
   ----------------

   procedure Test_1_255 (Fixture : in out Encoder_Fixture) is
      Long_Input : Storage_Array (0 .. 255);
   begin
      for X in Long_Input'Range loop
         Long_Input (X) := Storage_Element (X);
      end loop;

      Basic_Test (Fixture,
                  Input    => Long_Input (1 .. 255),
                  Expected =>
                    (0 => 16#FF#) & Long_Input (1 .. 254) &
                  (16#02#, 16#FF#, 16#00#));
   end Test_1_255;

   ------------------
   -- Test_2_255_0 --
   ------------------

   procedure Test_2_255_0 (Fixture : in out Encoder_Fixture) is
      Long_Input : Storage_Array (0 .. 255);
   begin
      for X in Long_Input'Range loop
         Long_Input (X) := Storage_Element (X);
      end loop;

      Basic_Test (Fixture,
                  Input    => Long_Input (2 .. 255) & (0 => 16#0#),
                  Expected =>
                    (0 => 16#FF#) & Long_Input (2 .. 255) &
                  (16#01#, 16#01#, 16#00#));

   end Test_2_255_0;

   --------------------
   -- Test_3_255_0_1 --
   --------------------

   procedure Test_3_255_0_1 (Fixture : in out Encoder_Fixture) is
      Long_Input : Storage_Array (0 .. 255);
   begin
      for X in Long_Input'Range loop
         Long_Input (X) := Storage_Element (X);
      end loop;

      Basic_Test (Fixture,
                  Input    => Long_Input (3 .. 255) & (16#0#, 16#01#),
                  Expected =>
                    (0 => 16#FE#) & Long_Input (3 .. 255) &
                  (16#02#, 16#01#, 16#00#));

   end Test_3_255_0_1;

   ---------------
   -- Add_Tests --
   ---------------

   procedure Add_Tests (Suite : in out AUnit.Test_Suites.Test_Suite'Class) is
   begin
      Suite.Add_Test (Encoder_Caller.Create ("Basics", Test_Zero'Access));
      Suite.Add_Test (Encoder_Caller.Create ("1 .. 254", Test_1_254'Access));
      Suite.Add_Test (Encoder_Caller.Create ("0 .. 254", Test_0_254'Access));
      Suite.Add_Test (Encoder_Caller.Create ("1 .. 255", Test_1_255'Access));
      Suite.Add_Test (Encoder_Caller.Create ("2 .. 255 & 0", Test_2_255_0'Access));
      Suite.Add_Test (Encoder_Caller.Create ("3 .. 255 & 0 & 1", Test_3_255_0_1'Access));
   end Add_Tests;

end Testsuite.Encode.Basic_Tests;
