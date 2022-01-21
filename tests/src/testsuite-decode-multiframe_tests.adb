with System.Storage_Elements; use System.Storage_Elements;

with AUnit.Assertions; use AUnit.Assertions;

with AAA.Strings;

with Test_Utils; use Test_Utils;

with Ada.Containers.Indefinite_Vectors;

package body Testsuite.Decode.Multiframe_Tests is
   pragma Style_Checks ("gnatyM120-s");


   package Expect_Frames_Package is new Ada.Containers.Indefinite_Vectors
     (Natural, Storage_Array);

   ----------------
   -- Basic_Test --
   ----------------

   procedure Basic_Test (Fixture         : in out Decoder_Fixture;
                         Input           :        Storage_Array;
                         Expected        :        Expect_Frames_Package.Vector)
   is
   begin

      Fixture.Decoder.Clear;

      for Elt of Input loop
         Fixture.Decoder.Receive (Elt);
      end loop;
      Fixture.Decoder.End_Of_Test;

      Assert (Fixture.Decoder.Number_Of_Frames =
                Storage_Count (Expected.Length),
              "Unexpected number of output frames: " &
                Fixture.Decoder.Number_Of_Frames'Img);

      for Index in 0 .. Fixture.Decoder.Number_Of_Frames - 1 loop
         declare
            Output_Frame : constant Data_Frame :=
              Fixture.Decoder.Get_Frame (Index);
            Expected_Frame : constant Data_Frame :=
              From_Array (Expected.Element (Natural (Index)));
         begin
            if Output_Frame /= Expected_Frame then
               declare
                  Diff : constant AAA.Strings.Vector :=
                    Test_Utils.Diff (Expected_Frame,
                                     Output_Frame);
               begin
                  Assert (False, "Error in frame #" & Index'Img & ASCII.LF &
                          Diff.Flatten (ASCII.LF));
               end;
            end if;
         end;
      end loop;

   end Basic_Test;

   ---------------
   -- Test_Zero --
   ---------------

   procedure Test_Zero (Fixture : in out Decoder_Fixture) is
      Expect : Expect_Frames_Package.Vector;
   begin

      Expect.Append ((0 => 0));
      Expect.Append ((0 => 0));
      Expect.Append ((0 => 0));

      Basic_Test (Fixture,
                  Input    => (01, 01, 00,
                               01, 01, 00,
                               01, 01, 00),
                  Expected => Expect);
   end Test_Zero;

   ----------------
   -- Test_1_254 --
   ----------------

   procedure Test_1_254 (Fixture : in out Decoder_Fixture) is
      Long_Input : Storage_Array (0 .. 255);

      Expect : Expect_Frames_Package.Vector;
   begin
      for X in Long_Input'Range loop
         Long_Input (X) := Storage_Element (X);
      end loop;

      Expect.Append (Long_Input (1 .. 254));
      Expect.Append (Long_Input (1 .. 254));
      Expect.Append (Long_Input (1 .. 254));

      Basic_Test (Fixture,
                  Input    =>
                    (0 => 16#FF#) & Long_Input (1 .. 254) & (0 => 16#00#) &
                    (0 => 16#FF#) & Long_Input (1 .. 254) & (0 => 16#00#) &
                    (0 => 16#FF#) & Long_Input (1 .. 254) & (0 => 16#00#),
                  Expected => Expect);
   end Test_1_254;

   ----------------
   -- Test_0_254 --
   ----------------

   procedure Test_0_254 (Fixture : in out Decoder_Fixture) is
      Long_Input : Storage_Array (0 .. 255);

      Expect : Expect_Frames_Package.Vector;
   begin
      for X in Long_Input'Range loop
         Long_Input (X) := Storage_Element (X);
      end loop;

      Expect.Append (Long_Input (0 .. 254));
      Expect.Append (Long_Input (0 .. 254));
      Expect.Append (Long_Input (0 .. 254));

      Basic_Test (Fixture,
                  Input    =>
                    (16#01#, 16#FF#) & Long_Input (1 .. 254) & (0 => 16#00#) &
                    (16#01#, 16#FF#) & Long_Input (1 .. 254) & (0 => 16#00#) &
                    (16#01#, 16#FF#) & Long_Input (1 .. 254) & (0 => 16#00#),
                  Expected => Expect);
   end Test_0_254;

   ----------------
   -- Test_1_255 --
   ----------------

   procedure Test_1_255 (Fixture : in out Decoder_Fixture) is
      Long_Input : Storage_Array (0 .. 255);
      Expect : Expect_Frames_Package.Vector;
   begin
      for X in Long_Input'Range loop
         Long_Input (X) := Storage_Element (X);
      end loop;

      Expect.Append (Long_Input (1 .. 255));
      Expect.Append (Long_Input (1 .. 255));
      Expect.Append (Long_Input (1 .. 255));

      Basic_Test (Fixture,
                  Input    =>
                    (0 => 16#FF#) & Long_Input (1 .. 254) & (16#02#, 16#FF#, 16#00#) &
                    (0 => 16#FF#) & Long_Input (1 .. 254) & (16#02#, 16#FF#, 16#00#) &
                    (0 => 16#FF#) & Long_Input (1 .. 254) & (16#02#, 16#FF#, 16#00#),
                  Expected => Expect);
   end Test_1_255;

   ------------------
   -- Test_2_255_0 --
   ------------------

   procedure Test_2_255_0 (Fixture : in out Decoder_Fixture) is
      Long_Input : Storage_Array (0 .. 255);
      Expect : Expect_Frames_Package.Vector;
   begin
      for X in Long_Input'Range loop
         Long_Input (X) := Storage_Element (X);
      end loop;

      Expect.Append (Long_Input (2 .. 255) & (0 => 16#0#));
      Expect.Append (Long_Input (2 .. 255) & (0 => 16#0#));
      Expect.Append (Long_Input (2 .. 255) & (0 => 16#0#));

      Basic_Test (Fixture,
                  Input    =>
                    (0 => 16#FF#) & Long_Input (2 .. 255) & (16#01#, 16#01#, 16#00#) &
                    (0 => 16#FF#) & Long_Input (2 .. 255) & (16#01#, 16#01#, 16#00#) &
                    (0 => 16#FF#) & Long_Input (2 .. 255) & (16#01#, 16#01#, 16#00#),
                  Expected => Expect);

   end Test_2_255_0;

   --------------------
   -- Test_3_255_0_1 --
   --------------------

   procedure Test_3_255_0_1 (Fixture : in out Decoder_Fixture) is
      Long_Input : Storage_Array (0 .. 255);
      Expect : Expect_Frames_Package.Vector;
   begin
      for X in Long_Input'Range loop
         Long_Input (X) := Storage_Element (X);
      end loop;

      Expect.Append (Long_Input (3 .. 255) & (16#0#, 16#01#));
      Expect.Append (Long_Input (3 .. 255) & (16#0#, 16#01#));
      Expect.Append (Long_Input (3 .. 255) & (16#0#, 16#01#));

      Basic_Test (Fixture,
                  Input    =>
                    (0 => 16#FE#) & Long_Input (3 .. 255) & (16#02#, 16#01#, 16#00#) &
                    (0 => 16#FE#) & Long_Input (3 .. 255) & (16#02#, 16#01#, 16#00#) &
                    (0 => 16#FE#) & Long_Input (3 .. 255) & (16#02#, 16#01#, 16#00#),
                  Expected => Expect);

   end Test_3_255_0_1;

   ---------------
   -- Add_Tests --
   ---------------

   procedure Add_Tests (Suite : in out AUnit.Test_Suites.Test_Suite'Class) is
   begin
      Suite.Add_Test (Decoder_Caller.Create ("Multiframe zeroes", Test_Zero'Access));
      Suite.Add_Test (Decoder_Caller.Create ("Multiframe 1 .. 254", Test_1_254'Access));
      Suite.Add_Test (Decoder_Caller.Create ("Multiframe 0 .. 254", Test_0_254'Access));
      Suite.Add_Test (Decoder_Caller.Create ("Multiframe 1 .. 255", Test_1_255'Access));
      Suite.Add_Test (Decoder_Caller.Create ("Multiframe 2 .. 255 & 0", Test_2_255_0'Access));
      Suite.Add_Test (Decoder_Caller.Create ("Multiframe 3 .. 255 & 0 & 1", Test_3_255_0_1'Access));
   end Add_Tests;

end Testsuite.Decode.Multiframe_Tests;
