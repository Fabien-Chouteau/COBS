with AUnit.Test_Suites;
with AUnit.Test_Fixtures;
with AUnit.Test_Caller;

with Testsuite.Encode;
with Testsuite.Decode;

private with Test_Utils.Abstract_Decoder;
private with Test_Utils.Abstract_Encoder;

package Testsuite.Encode_Decode is

   procedure Set_Kinds (E : Testsuite.Encode.Encoder_Kind;
                        D : Testsuite.Decode.Decoder_Kind);

   procedure Add_Tests (Suite : in out AUnit.Test_Suites.Test_Suite'Class);

private

   type Encoder_Decoder_Fixture
   is new AUnit.Test_Fixtures.Test_Fixture with record
      Encoder : Test_Utils.Abstract_Encoder.Any_Acc;
      E_Kind : Testsuite.Encode.Encoder_Kind;
      Decoder : Test_Utils.Abstract_Decoder.Any_Acc;
      D_Kind : Testsuite.Decode.Decoder_Kind;
   end record;

   overriding
   procedure Set_Up (Test : in out Encoder_Decoder_Fixture);

   overriding
   procedure Tear_Down (Test : in out Encoder_Decoder_Fixture);

   package Encoder_Decoder_Caller
   is new AUnit.Test_Caller (Encoder_Decoder_Fixture);

end Testsuite.Encode_Decode;
