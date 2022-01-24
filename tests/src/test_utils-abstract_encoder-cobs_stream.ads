private with COBS.Stream.Encoder;

package Test_Utils.Abstract_Encoder.COBS_Stream is

   subtype Parent is Abstract_Encoder.Instance;

   type Instance is new Parent with private;
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

   type Test_Instance is new COBS.Stream.Encoder.Instance with record
      Output : Data_Frame;
   end record;

   overriding
   procedure Flush (This : in out Test_Instance;
                    Data : Storage_Array);

   type Instance is new Parent with record
      Encoder : Test_Instance;
   end record;

end Test_Utils.Abstract_Encoder.COBS_Stream;
