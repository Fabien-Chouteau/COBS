with Ada.Unchecked_Deallocation;

with Test_Utils.Abstract_Encoder.COBS_Simple;
with Test_Utils.Abstract_Encoder.COBS_Stream;
with Test_Utils.Abstract_Encoder.COBS_Queue;

with Testsuite.Encode.Basic_Tests;
with Testsuite.Encode.Multiframe_Tests;

package body Testsuite.Encode is

   Kind : Encoder_Kind := Encoder_Kind'First;

   ----------------------
   -- Set_Encoder_Kind --
   ----------------------

   procedure Set_Encoder_Kind (K : Encoder_Kind) is
   begin
      Kind := K;
   end Set_Encoder_Kind;

   ------------
   -- Set_Up --
   ------------

   overriding
   procedure Set_Up (Test : in out Encoder_Fixture) is
   begin
      Test.Kind := Kind;
      Test.Encoder := Create_Encoder (Kind);
   end Set_Up;

   ---------------
   -- Tear_Down --
   ---------------

   overriding
   procedure Tear_Down (Test : in out Encoder_Fixture) is
   begin
      Free_Encoder (Test.Encoder);
   end Tear_Down;

   ---------------
   -- Add_Tests --
   ---------------

   procedure Add_Tests (Suite : in out AUnit.Test_Suites.Test_Suite'Class) is
   begin
      Testsuite.Encode.Basic_Tests.Add_Tests (Suite);
      Testsuite.Encode.Multiframe_Tests.Add_Tests (Suite);
   end Add_Tests;

   --------------------
   -- Create_Encoder --
   --------------------

   function Create_Encoder (K : Encoder_Kind)
                            return not null Test_Utils.Abstract_Encoder.Any_Acc
   is
      use Test_Utils.Abstract_Encoder;
   begin
      case K is
         when Simple =>
            return new COBS_Simple.Instance;

         when Stream =>
            return new COBS_Stream.Instance;

         when Queue =>
            return new COBS_Queue.Instance (2048);
      end case;
   end Create_Encoder;

   ------------------
   -- Free_Encoder --
   ------------------

   procedure Free_Encoder (Dec : in out Test_Utils.Abstract_Encoder.Any_Acc) is
      use Test_Utils.Abstract_Encoder;

      procedure Free is new Ada.Unchecked_Deallocation
        (COBS_Simple.Instance,
         COBS_Simple.Acc);

      procedure Free is new Ada.Unchecked_Deallocation
        (COBS_Stream.Instance,
         COBS_Stream.Acc);

      procedure Free is new Ada.Unchecked_Deallocation
        (COBS_Queue.Instance,
         COBS_Queue.Acc);

   begin
      if Dec.all in COBS_Simple.Instance'Class then
         Free (COBS_Simple.Acc (Dec));
      elsif Dec.all in COBS_Stream.Instance'Class then
         Free (COBS_Stream.Acc (Dec));
      elsif Dec.all in COBS_Queue.Instance'Class then
         Free (COBS_Queue.Acc (Dec));
      else
         raise Program_Error;
      end if;
   end Free_Encoder;
end Testsuite.Encode;
