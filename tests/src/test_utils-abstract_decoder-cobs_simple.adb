with COBS;

package body Test_Utils.Abstract_Decoder.COBS_Simple is

   -------------
   -- Receive --
   -------------

   overriding
   procedure Receive (This : in out Instance; Data : Storage_Element)
   is
   begin
      if Data /= 0 then
         This.Input.Append (Data);

      else

         --  We reached the end of a frame so, decode and save the result
         declare
            Input  : Storage_Array_Access := To_Array_Access (This.Input);

            Output : Storage_Array
              (1 .. COBS.Max_Encoding_Length (Input'Length));

            Success : Boolean;
            Last    : Storage_Offset;
         begin
            if This.In_Place then
               COBS.Decode_In_Place (Input.all, Last, Success);
            else
               COBS.Decode (Input.all, Output, Last, Success);
            end if;

            if not Success then
               raise Program_Error;
            end if;

            if This.In_Place then
               for Elt of Input (Input'First .. Last) loop
                  This.Push_To_Frame (Elt);
               end loop;
            else
               for Elt of Output (Output'First .. Last) loop
                  This.Push_To_Frame (Elt);
               end loop;
            end if;

            This.Save_Frame;
            This.Start_New_Frame;
            This.Input.Clear;

            Free (Input);
         end;
      end if;
   end Receive;

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
      null;
   end End_Of_Test;

end Test_Utils.Abstract_Decoder.COBS_Simple;
