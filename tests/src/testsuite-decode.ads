with Test_Utils.Abstract_Decoder;

with AUnit.Test_Suites;
with AUnit.Test_Fixtures;
private with AUnit.Test_Caller;

package Testsuite.Decode is

   type Decoder_Kind is (Simple, Simple_In_Place, Stream);

   procedure Set_Decoder_Kind (K : Decoder_Kind);

   procedure Add_Tests (Suite : in out AUnit.Test_Suites.Test_Suite'Class);

   function Create_Decoder (K : Decoder_Kind)
                            return not null Test_Utils.Abstract_Decoder.Any_Acc;

   procedure Free_Decoder (Dec : in out Test_Utils.Abstract_Decoder.Any_Acc);

private

   type Decoder_Fixture
   is new AUnit.Test_Fixtures.Test_Fixture with record
      Decoder : Test_Utils.Abstract_Decoder.Any_Acc;
      Kind : Decoder_Kind;
   end record;

   overriding
   procedure Set_Up (Test : in out Decoder_Fixture);

   overriding
   procedure Tear_Down (Test : in out Decoder_Fixture);

   package Decoder_Caller is new AUnit.Test_Caller (Decoder_Fixture);

end Testsuite.Decode;
