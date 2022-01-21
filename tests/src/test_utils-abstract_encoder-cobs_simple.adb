with COBS;

package body Test_Utils.Abstract_Encoder.COBS_Simple is

   -------------
   -- Receive --
   -------------

   overriding
   procedure Receive (This : in out Instance; Data : Storage_Element)
   is
   begin
      This.Input.Append (Data);
   end Receive;

   ------------------
   -- End_Of_Frame --
   ------------------

   overriding
   procedure End_Of_Frame (This : in out Instance) is
   begin

      if not This.Input.Is_Empty then
         declare
            In_Arr : Storage_Array_Access := To_Array_Access (This.Input);

            Max_Out : constant Storage_Count :=
              COBS.Max_Encoding_Length (In_Arr'Length);

            Out_Arr : Storage_Array_Access := new Storage_Array (1 .. Max_Out);

            Success : Boolean;
            Last    : Storage_Offset;
         begin
            COBS.Encode (Data        => In_Arr.all,
                         Output      => Out_Arr.all,
                         Output_Last => Last,
                         Success     => Success);

            if Success then
               for Elt of Out_Arr (Out_Arr'First .. Last) loop
                  This.Push_To_Frame (Elt);
               end loop;
            end if;
            This.Push_To_Frame (0);
            This.Input.Clear;

            Free (In_Arr);
            Free (Out_Arr);
         end;
      end if;
   end End_Of_Frame;

   ------------
   -- Update --
   ------------

   overriding
   procedure Update (This : in out Instance) is
   begin
      null;
   end Update;

   -----------------
   -- End_Of_Test --
   -----------------

   overriding
   procedure End_Of_Test (This : in out Instance) is
   begin
      This.End_Of_Frame;
      This.Save_Frame;
   end End_Of_Test;

end Test_Utils.Abstract_Encoder.COBS_Simple;
