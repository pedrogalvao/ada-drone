with Ada.Text_IO;

with AWS.Default;
with AWS.Server;

with Drone_Control;

procedure Main is

   WS : AWS.Server.HTTP;

begin
   Ada.Text_IO.Put_Line
     ("Call me on port"
      & Positive'Image (AWS.Default.Server_Port)
      & ", I will stop in 60 seconds...");

   AWS.Server.Start (WS, "Hello World",
                     Max_Connection => 1,
                     Callback       => Drone_Control.HW_CB'Access);

   delay 600.0;

   AWS.Server.Shutdown (WS);
end Main;