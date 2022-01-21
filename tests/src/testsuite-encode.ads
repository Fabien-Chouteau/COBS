with Test_Utils.Abstract_Encoder;

with AUnit.Test_Suites;
with AUnit.Test_Fixtures;
private with AUnit.Test_Caller;

package Testsuite.Encode is

   type Encoder_Kind is (Simple, Stream, Queue);

   procedure Set_Encoder_Kind (K : Encoder_Kind);

   procedure Add_Tests (Suite : in out AUnit.Test_Suites.Test_Suite'Class);

   function Create_Encoder (K : Encoder_Kind)
                            return not null Test_Utils.Abstract_Encoder.Any_Acc;

   procedure Free_Encoder (Dec : in out Test_Utils.Abstract_Encoder.Any_Acc);

private

   type Encoder_Fixture
   is new AUnit.Test_Fixtures.Test_Fixture with record
      Encoder : Test_Utils.Abstract_Encoder.Any_Acc;
      Kind : Encoder_Kind;
   end record;

   overriding
   procedure Set_Up (Test : in out Encoder_Fixture);

   overriding
   procedure Tear_Down (Test : in out Encoder_Fixture);

   package Encoder_Caller is new AUnit.Test_Caller (Encoder_Fixture);

end Testsuite.Encode;
