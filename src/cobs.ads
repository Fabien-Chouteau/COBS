with System.Storage_Elements; use System.Storage_Elements;

package COBS
with Preelaborate
is

   function Max_Encoding_Length (Data_Len : Storage_Count)
                                 return Storage_Count;

   procedure Encode (Data        :        Storage_Array;
                     Output      : in out Storage_Array;
                     Output_Last :    out Storage_Offset;
                     Success     :    out Boolean);

   procedure Decode (Data        :        Storage_Array;
                     Output      : in out Storage_Array;
                     Output_Last :    out Storage_Offset;
                     Success     :    out Boolean);

   procedure Decode_In_Place (Data    : in out Storage_Array;
                              Last    :    out Storage_Offset;
                              Success :    out Boolean);

end COBS;
