with Ada.Text_IO; use Ada.Text_IO;

package body Drone_Control is

function HW_CB (Request : AWS.Status.Data) return AWS.Response.Data is
    pragma Unreferenced (Request);
    Position_X : Float;
    Position_Y : Float;
    Position_Z : Float;
begin
    
    Position_X := Float'Value (AWS.Parameters.Get (AWS.Status.Parameters (Request), "position_x"));
    Position_Y := Float'Value (AWS.Parameters.Get (AWS.Status.Parameters (Request), "position_y"));
    Position_Z := Float'Value (AWS.Parameters.Get (AWS.Status.Parameters (Request), "position_z"));

    Put_Line ("Height: " & AWS.Parameters.Get (AWS.Status.Parameters (Request), "position_y"));

    if Position_Y > 11.0 then
        return AWS.Response.Build ("text/html", "{""force"":[0,9.5,0]}");
    elsif Position_Y > 10.0 then
        return AWS.Response.Build ("text/html", "{""force"":[0,9.7,0]}");
    elsif Position_Y > 9.0 then
        return AWS.Response.Build ("text/html", "{""force"":[0,9.85,0]}");
    else
        return AWS.Response.Build ("text/json", "{""force"":[0,10.0,0]}");
    end if;
end HW_CB;

end Drone_Control;