with COBS.Queue.Encoder;

package Test_Utils.Abstract_Encoder.COBS_Queue is

   subtype Parent is Abstract_Encoder.Instance;

   type Instance (Size : COBS.Queue.Encoder.Buffer_Size)
   is limited new Parent with private;
   type Acc is access all Instance;
   type Any_Acc is access all Instance'Class;

   overriding
   procedure Receive (This : in out Instance;
                      Data :        Storage_Element);

   overriding
   procedure End_Of_Frame (This : in out Instance);

   overriding
   procedure Update (This : in out Instance);

   overriding
   procedure End_Of_Test (This : in out Instance);

private

   type Instance (Size : COBS.Queue.Encoder.Buffer_Size)
   is limited new Parent with record
      Encoder : COBS.Queue.Encoder.Instance (Size);
   end record;

end Test_Utils.Abstract_Encoder.COBS_Queue;
