package Test_Utils.Abstract_Decoder.COBS_Simple is

   subtype Parent is Test_Utils.Abstract_Decoder.Instance;

   type Instance (In_Place : Boolean := False)
   is limited new Parent
   with private;

   type Acc is access all Instance;
   type Any_Acc is access all Instance'Class;

   overriding
   procedure Receive (This : in out Instance;
                      Data :        Storage_Element);

   overriding
   procedure Update (This : in out Instance);

   overriding
   procedure End_Of_Test (This : in out Instance);

private

   type Instance (In_Place : Boolean := False)
   is limited new Parent
   with record
      Input : Data_Frame;
   end record;

end Test_Utils.Abstract_Decoder.COBS_Simple;
