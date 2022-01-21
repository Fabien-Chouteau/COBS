with System.Storage_Elements; use System.Storage_Elements;

with AUnit.Assertions; use AUnit.Assertions;

with AAA.Strings;

with Test_Utils; use Test_Utils;

with Ada.Containers.Indefinite_Vectors;

package body Testsuite.Encode.Multiframe_Tests is
   pragma Style_Checks ("gnatyM120-s");


   package Input_Frames_Package is new Ada.Containers.Indefinite_Vectors
     (Natural, Storage_Array);

   ----------------
   -- Basic_Test --
   ----------------

   procedure Basic_Test (Fixture         : in out Encoder_Fixture;
                         Input           :        Input_Frames_Package.Vector;
                         Expected        :        Storage_Array)
   is
      Expected_Frame : constant Data_Frame := From_Array (Expected);
   begin

      Fixture.Encoder.Clear;

      for Frame of Input loop
         for Elt of Frame loop
            Fixture.Encoder.Receive (Elt);
         end loop;
         Fixture.Encoder.End_Of_Frame;
      end loop;
      Fixture.Encoder.End_Of_Test;

      Assert (Fixture.Encoder.Number_Of_Frames = 1,
              "Unexpected number of output frames: " &
                Fixture.Encoder.Number_Of_Frames'Img);

      declare
         Output_Frame : constant Data_Frame := Fixture.Encoder.Get_Frame (0);
      begin
         if Output_Frame /= Expected_Frame then
            declare
               Diff : constant AAA.Strings.Vector :=
                 Test_Utils.Diff (From_Array (Expected),
                                  Fixture.Encoder.Get_Frame (0));
            begin
               Assert (False, Diff.Flatten (ASCII.LF));
            end;
         end if;
      end;

   end Basic_Test;

   ---------------
   -- Test_Zero --
   ---------------

   procedure Test_Zero (Fixture : in out Encoder_Fixture) is
      Input : Input_Frames_Package.Vector;
   begin

      Input.Append ((0 => 0));
      Input.Append ((0 => 0));
      Input.Append ((0 => 0));
      Basic_Test (Fixture,
                  Input    => Input,
                  Expected => (01, 01, 00,
                               01, 01, 00,
                               01, 01, 00));
   end Test_Zero;

   ----------------
   -- Test_1_254 --
   ----------------

   procedure Test_1_254 (Fixture : in out Encoder_Fixture) is
      Long_Input : Storage_Array (0 .. 255);

      Input : Input_Frames_Package.Vector;
   begin
      for X in Long_Input'Range loop
         Long_Input (X) := Storage_Element (X);
      end loop;

      Input.Append (Long_Input (1 .. 254));
      Input.Append (Long_Input (1 .. 254));
      Input.Append (Long_Input (1 .. 254));

      Basic_Test (Fixture,
                  Input    => Input,
                  Expected =>
                    (0 => 16#FF#) & Long_Input (1 .. 254) & (0 => 16#00#) &
                    (0 => 16#FF#) & Long_Input (1 .. 254) & (0 => 16#00#) &
                    (0 => 16#FF#) & Long_Input (1 .. 254) & (0 => 16#00#));
   end Test_1_254;

   ----------------
   -- Test_0_254 --
   ----------------

   procedure Test_0_254 (Fixture : in out Encoder_Fixture) is
      Long_Input : Storage_Array (0 .. 255);

      Input : Input_Frames_Package.Vector;
   begin
      for X in Long_Input'Range loop
         Long_Input (X) := Storage_Element (X);
      end loop;

      Input.Append (Long_Input (0 .. 254));
      Input.Append (Long_Input (0 .. 254));
      Input.Append (Long_Input (0 .. 254));

      Basic_Test (Fixture,
                  Input    => Input,
                  Expected =>
                    (16#01#, 16#FF#) & Long_Input (1 .. 254) & (0 => 16#00#) &
                    (16#01#, 16#FF#) & Long_Input (1 .. 254) & (0 => 16#00#) &
                    (16#01#, 16#FF#) & Long_Input (1 .. 254) & (0 => 16#00#));
   end Test_0_254;

   ----------------
   -- Test_1_255 --
   ----------------

   procedure Test_1_255 (Fixture : in out Encoder_Fixture) is
      Long_Input : Storage_Array (0 .. 255);
      Input : Input_Frames_Package.Vector;
   begin
      for X in Long_Input'Range loop
         Long_Input (X) := Storage_Element (X);
      end loop;

      Input.Append (Long_Input (1 .. 255));
      Input.Append (Long_Input (1 .. 255));
      Input.Append (Long_Input (1 .. 255));

      Basic_Test (Fixture,
                  Input    => Input,
                  Expected =>
                    (0 => 16#FF#) & Long_Input (1 .. 254) & (16#02#, 16#FF#, 16#00#) &
                    (0 => 16#FF#) & Long_Input (1 .. 254) & (16#02#, 16#FF#, 16#00#) &
                    (0 => 16#FF#) & Long_Input (1 .. 254) & (16#02#, 16#FF#, 16#00#));
   end Test_1_255;



   ------------------
   -- Test_2_255_0 --
   ------------------

   procedure Test_2_255_0 (Fixture : in out Encoder_Fixture) is
      Long_Input : Storage_Array (0 .. 255);
      Input : Input_Frames_Package.Vector;
   begin
      for X in Long_Input'Range loop
         Long_Input (X) := Storage_Element (X);
      end loop;

      Input.Append (Long_Input (2 .. 255) & (0 => 16#0#));
      Input.Append (Long_Input (2 .. 255) & (0 => 16#0#));
      Input.Append (Long_Input (2 .. 255) & (0 => 16#0#));

      Basic_Test (Fixture,
                  Input    => Input,
                  Expected =>
                    (0 => 16#FF#) & Long_Input (2 .. 255) & (16#01#, 16#01#, 16#00#) &
                    (0 => 16#FF#) & Long_Input (2 .. 255) & (16#01#, 16#01#, 16#00#) &
                    (0 => 16#FF#) & Long_Input (2 .. 255) & (16#01#, 16#01#, 16#00#));

   end Test_2_255_0;

   --------------------
   -- Test_3_255_0_1 --
   --------------------

   procedure Test_3_255_0_1 (Fixture : in out Encoder_Fixture) is
      Long_Input : Storage_Array (0 .. 255);
      Input : Input_Frames_Package.Vector;
   begin
      for X in Long_Input'Range loop
         Long_Input (X) := Storage_Element (X);
      end loop;

      Input.Append (Long_Input (3 .. 255) & (16#0#, 16#01#));
      Input.Append (Long_Input (3 .. 255) & (16#0#, 16#01#));
      Input.Append (Long_Input (3 .. 255) & (16#0#, 16#01#));

      Basic_Test (Fixture,
                  Input    => Input,
                  Expected =>
                    (0 => 16#FE#) & Long_Input (3 .. 255) & (16#02#, 16#01#, 16#00#) &
                    (0 => 16#FE#) & Long_Input (3 .. 255) & (16#02#, 16#01#, 16#00#) &
                    (0 => 16#FE#) & Long_Input (3 .. 255) & (16#02#, 16#01#, 16#00#));

   end Test_3_255_0_1;

   ---------------
   -- Add_Tests --
   ---------------

   procedure Add_Tests (Suite : in out AUnit.Test_Suites.Test_Suite'Class) is
   begin
      Suite.Add_Test (Encoder_Caller.Create ("Multiframe zeroes", Test_Zero'Access));
      Suite.Add_Test (Encoder_Caller.Create ("Multiframe 1 .. 254", Test_1_254'Access));
      Suite.Add_Test (Encoder_Caller.Create ("Multiframe 0 .. 254", Test_0_254'Access));
      Suite.Add_Test (Encoder_Caller.Create ("Multiframe 1 .. 255", Test_1_255'Access));
      Suite.Add_Test (Encoder_Caller.Create ("Multiframe 2 .. 255 & 0", Test_2_255_0'Access));
      Suite.Add_Test (Encoder_Caller.Create ("Multiframe 3 .. 255 & 0 & 1", Test_3_255_0_1'Access));
   end Add_Tests;

end Testsuite.Encode.Multiframe_Tests;
