with Ada.Unchecked_Deallocation;

with Test_Utils.Abstract_Decoder.COBS_Simple;
with Test_Utils.Abstract_Decoder.COBS_Stream;

with Testsuite.Decode.Basic_Tests;
with Testsuite.Decode.Multiframe_Tests;

package body Testsuite.Decode is

   Kind : Decoder_Kind := Decoder_Kind'First;

   ----------------------
   -- Set_Decoder_Kind --
   ----------------------

   procedure Set_Decoder_Kind (K : Decoder_Kind) is
   begin
      Kind := K;
   end Set_Decoder_Kind;

   ------------
   -- Set_Up --
   ------------

   overriding
   procedure Set_Up (Test : in out Decoder_Fixture) is
   begin
      Test.Kind := Kind;

      Test.Decoder := Create_Decoder (Kind);
   end Set_Up;

   ---------------
   -- Tear_Down --
   ---------------

   overriding
   procedure Tear_Down (Test : in out Decoder_Fixture) is
   begin
      Free_Decoder (Test.Decoder);
   end Tear_Down;

   ---------------
   -- Add_Tests --
   ---------------

   procedure Add_Tests (Suite : in out AUnit.Test_Suites.Test_Suite'Class) is
   begin
      Testsuite.Decode.Basic_Tests.Add_Tests (Suite);
      if False then
         Testsuite.Decode.Multiframe_Tests.Add_Tests (Suite);
      end if;
   end Add_Tests;

   --------------------
   -- Create_Decoder --
   --------------------

   function Create_Decoder (K : Decoder_Kind)
                            return not null Test_Utils.Abstract_Decoder.Any_Acc
   is
      use Test_Utils.Abstract_Decoder;
   begin
      case K is
         when Simple =>
            return new COBS_Simple.Instance;

         when Simple_In_Place =>
            return new COBS_Simple.Instance (True);

         when Stream =>
            return new COBS_Stream.Instance;
      end case;
   end Create_Decoder;

   ------------------
   -- Free_Decoder --
   ------------------

   procedure Free_Decoder (Dec : in out Test_Utils.Abstract_Decoder.Any_Acc) is
      use Test_Utils.Abstract_Decoder;

      procedure Free is new Ada.Unchecked_Deallocation
        (COBS_Simple.Instance,
         COBS_Simple.Acc);

      procedure Free is new Ada.Unchecked_Deallocation
        (COBS_Stream.Instance,
         COBS_Stream.Acc);

   begin
      if Dec.all in COBS_Simple.Instance'Class then
         Free (COBS_Simple.Acc (Dec));
      elsif Dec.all in COBS_Stream.Instance'Class then
         Free (COBS_Stream.Acc (Dec));
      else
         raise Program_Error;
      end if;
   end Free_Decoder;

end Testsuite.Decode;
