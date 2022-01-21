with Testsuite.Encode_Decode.Random;

package body Testsuite.Encode_Decode is

   E_Kind : Testsuite.Encode.Encoder_Kind;
   D_Kind : Testsuite.Decode.Decoder_Kind;

   ---------------
   -- Set_Kinds --
   ---------------

   procedure Set_Kinds (E : Testsuite.Encode.Encoder_Kind;
                        D : Testsuite.Decode.Decoder_Kind)
   is
   begin
      E_Kind := E;
      D_Kind := D;
   end Set_Kinds;

   ---------------
   -- Add_Tests --
   ---------------

   procedure Add_Tests (Suite : in out AUnit.Test_Suites.Test_Suite'Class) is
   begin
      Testsuite.Encode_Decode.Random.Add_Tests (Suite);
   end Add_Tests;

   ------------
   -- Set_Up --
   ------------

   overriding
   procedure Set_Up (Test : in out Encoder_Decoder_Fixture) is
   begin
      Test.E_Kind := E_Kind;
      Test.D_Kind := D_Kind;
      Test.Decoder := Testsuite.Decode.Create_Decoder (D_Kind);
      Test.Encoder := Testsuite.Encode.Create_Encoder (E_Kind);
   end Set_Up;

   ---------------
   -- Tear_Down --
   ---------------

   overriding
   procedure Tear_Down (Test : in out Encoder_Decoder_Fixture) is
   begin
      Testsuite.Decode.Free_Decoder (Test.Decoder);
      Testsuite.Encode.Free_Encoder (Test.Encoder);
   end Tear_Down;

end Testsuite.Encode_Decode;
