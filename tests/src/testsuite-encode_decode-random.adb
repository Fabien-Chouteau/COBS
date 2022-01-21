with System.Storage_Elements; use System.Storage_Elements;

with Ada.Containers.Indefinite_Vectors;
with Ada.Numerics.Discrete_Random;

with AUnit.Assertions; use AUnit.Assertions;

with Test_Utils; use Test_Utils;

with AAA.Strings;

package body Testsuite.Encode_Decode.Random is
   pragma Style_Checks ("gnatyM120-s");

   package Input_Frames_Package is new Ada.Containers.Indefinite_Vectors
     (Natural, Storage_Array);

   -------------------------------
   -- Make_Random_Test_Scenario --
   -------------------------------

   function Make_Random_Test_Scenario return Input_Frames_Package.Vector is
      type Frames_Number_Range is range 1 .. 100;
      subtype Frames_Length_Range is Storage_Count range 1 .. 1000;

      package Rand_Frames_Number
      is new Ada.Numerics.Discrete_Random (Frames_Number_Range);
      package Rand_Frames_Length
      is new Ada.Numerics.Discrete_Random (Frames_Length_Range);
      package Rand_Data
      is new Ada.Numerics.Discrete_Random (Storage_Element);

      Gen_Nbr  : Rand_Frames_Number.Generator;
      Gen_Len  : Rand_Frames_Length.Generator;
      Gen_Data : Rand_Data.Generator;

      Result : Input_Frames_Package.Vector;
   begin

      for Frame in 1 .. Rand_Frames_Number.Random (Gen_Nbr) loop
         declare
            Frame : Storage_Array (1 .. Rand_Frames_Length.Random (Gen_Len));
         begin
            for Elt of Frame loop
               Elt := Rand_Data.Random (Gen_Data);
            end loop;
            Result.Append (Frame);
         end;
      end loop;

      return Result;
   end Make_Random_Test_Scenario;

   -----------------
   -- Test_Random --
   -----------------

   procedure Test_Random (Fixture : in out Encoder_Decoder_Fixture) is
      Input : constant Input_Frames_Package.Vector := Make_Random_Test_Scenario;
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
              "Unexpected number of encode output frames: " &
                Fixture.Encoder.Number_Of_Frames'Img);

      for Elt of Fixture.Encoder.Get_Frame (0) loop
         Fixture.Decoder.Receive (Elt);
      end loop;

      Fixture.Decoder.End_Of_Test;

      Assert (Fixture.Decoder.Number_Of_Frames =
                Storage_Count (Input.Length),
              "Unexpected number of decode output frames: " &
                Fixture.Decoder.Number_Of_Frames'Img);

      for Index in 0 .. Fixture.Decoder.Number_Of_Frames - 1 loop
         declare
            Output_Frame : constant Data_Frame :=
              Fixture.Decoder.Get_Frame (Index);
            Expected_Frame : constant Data_Frame :=
              From_Array (Input.Element (Natural (Index)));
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

   end Test_Random;

   ---------------
   -- Add_Tests --
   ---------------

   procedure Add_Tests (Suite : in out AUnit.Test_Suites.Test_Suite'Class) is
   begin
      for X in 1 .. 10 loop
         Suite.Add_Test (Encoder_Decoder_Caller.Create ("Random" & X'Img,
                         Test_Random'Access));
      end loop;
   end Add_Tests;

end Testsuite.Encode_Decode.Random;
