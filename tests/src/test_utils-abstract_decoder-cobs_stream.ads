with COBS.Decoder;

package Test_Utils.Abstract_Decoder.COBS_Stream is

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

   type Test_Decoder is new COBS.Decoder.Instance with record
      Frames : Data_Frame_Vectors.Vector;
      Output : Data_Frame;
   end record;

   overriding
   procedure Flush (This : in out Test_Decoder;
                    Data : Storage_Array);

   overriding
   procedure End_Of_Frame (This : in out Test_Decoder);

   type Instance (In_Place : Boolean := False)
   is limited new Parent
   with record
      Decoder : Test_Decoder;
   end record;

end Test_Utils.Abstract_Decoder.COBS_Stream;
