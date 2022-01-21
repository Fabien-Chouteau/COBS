package COBS.Decoder
with Preelaborate
is

   type Instance is abstract tagged private;

   procedure Push (This : in out Instance;
                   Data : Storage_Element);

   procedure Flush (This : in out Instance;
                    Data : Storage_Array)
   is abstract;

   procedure End_Of_Frame (This : in out Instance)
   is abstract;

private

   type Instance is abstract tagged record
      Buffer         : Storage_Array (1 .. 255);
      Out_Index      : Storage_Offset := 1;

      Start_Of_Frame : Boolean := True;
      Code           : Storage_Element;
      Last_Code      : Storage_Element := 0;
   end record;

   procedure Do_Flush (This : in out Instance);

end COBS.Decoder;
