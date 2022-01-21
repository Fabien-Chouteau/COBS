with BBqueue;

package COBS.Queue.Encoder
with Preelaborate
is

   Min_Buf_Size : constant := 255;

   subtype Buffer_Size
     is BBqueue.Buffer_Size range 2 * Min_Buf_Size ..
       BBqueue.Buffer_Size'Last;
   --  The idea behin "2 * Min_Buf_Size" is to make sure we can get a grant for
   --  the worst case COBS frame, but I'm not 100% sure it makes sens...

   type Instance (Size : Buffer_Size) is limited private;

   procedure Push (This    : in out Instance;
                   Data    :        Storage_Element;
                   Success :    out Boolean);

   procedure End_Frame (This    : in out Instance;
                        Success :    out Boolean);

   type Slice_Rec is record
      Length : BBqueue.Count;
      Addr   : System.Address;
   end record;

   function Read_Slice (This : in out Instance) return Slice_Rec;

   procedure Release (This : in out Instance);

   generic
      with procedure Process_Read (Data : Storage_Array;
                                   To_Release : out BBqueue.Count);
   procedure Read_CB (This   : in out Instance;
                      Result :    out BBqueue.Result_Kind);

private

   type Instance (Size : Buffer_Size) is limited record
      Buffer : Storage_Array (1 .. Size);
      Queue  : BBqueue.Offsets_Only (Size);
      WG     : BBqueue.Write_Grant := BBqueue.Empty;
      RG     : BBqueue.Read_Grant := BBqueue.Empty;

      Code           : Storage_Element := 1;
      Prev_Code      : Storage_Element := 1;
      Code_Pointer   : Storage_Offset;
      Encode_Pointer : Storage_Offset;
   end record;

end COBS.Queue.Encoder;
