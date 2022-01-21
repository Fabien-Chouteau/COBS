package COBS.Encoder
with Preelaborate
is

   type Instance is abstract tagged private;

   procedure Push (This : in out Instance;
                   Data : Storage_Element);

   procedure End_Frame (This : in out Instance);

   procedure Flush (This : in out Instance;
                    Data : Storage_Array)
   is abstract;

private

   type Instance is abstract tagged record
      Buffer         : Storage_Array (1 .. 255);
      Code           : Storage_Element := 1;
      Prev_Code      : Storage_Element := 1;
      Code_Pointer   : Storage_Offset := 1;
      Encode_Pointer : Storage_Offset := 2;
   end record;

end COBS.Encoder;
